import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/parsed_resume.dart';
import '../../../domain/entities/interview_session.dart';
import 'ai_prompts.dart';

class GeminiApiService {
  final Dio _dio;
  String? _apiKey;

  GeminiApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          return handler.next(_handleError(error));
        },
      ),
    );
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String get _endpoint =>
      '/models/${AppConstants.geminiModel}:generateContent?key=$_apiKey';

  /// Generate interview questions based on resume and target role
  Future<List<String>> generateInterviewQuestions({
    required String targetRole,
    required InterviewType interviewType,
    required QuestionCategory category,
    ParsedResume? resume,
    int count = 5,
  }) async {
    final systemPrompt = AIPrompts.getInterviewerSystemPrompt(
      targetRole: targetRole,
      interviewType: interviewType,
      resume: resume,
    );

    final userPrompt = AIPrompts.getQuestionGenerationPrompt(
      category: category,
      count: count,
      targetRole: targetRole,
    );

    final response = await _generateContent(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return _parseQuestions(response);
  }

  /// Generate a single follow-up question based on the previous answer
  Future<String> generateFollowUpQuestion({
    required String previousQuestion,
    required String previousAnswer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    const systemPrompt = AIPrompts.followUpSystemPrompt;
    final userPrompt = AIPrompts.getFollowUpPrompt(
      previousQuestion: previousQuestion,
      previousAnswer: previousAnswer,
      category: category,
      targetRole: targetRole,
    );

    final response = await _generateContent(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return response.trim();
  }

  /// Evaluate the user's answer and provide feedback
  Future<GeminiEvaluationResult> evaluateAnswer({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    const systemPrompt = AIPrompts.evaluatorSystemPrompt;
    final userPrompt = AIPrompts.getEvaluationPrompt(
      question: question,
      answer: answer,
      category: category,
      targetRole: targetRole,
    );

    final response = await _generateContent(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return _parseEvaluation(response);
  }

  /// Generate a model answer for comparison
  Future<String> generateModelAnswer({
    required String question,
    required QuestionCategory category,
    required String targetRole,
    ParsedResume? resume,
  }) async {
    const systemPrompt = AIPrompts.modelAnswerSystemPrompt;
    final userPrompt = AIPrompts.getModelAnswerPrompt(
      question: question,
      category: category,
      targetRole: targetRole,
      resume: resume,
    );

    final response = await _generateContent(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return response.trim();
  }

  /// Parse resume text using AI
  Future<Map<String, dynamic>> parseResumeWithAI(String resumeText) async {
    const systemPrompt = AIPrompts.resumeParserSystemPrompt;
    final userPrompt = '''Parse the following resume and extract structured information:

$resumeText

Return the information in JSON format with the following fields:
- fullName
- email
- phone
- location
- education (array of {degree, institution, startDate, endDate, gpa, field})
- workExperience (array of {company, role, startDate, endDate, descriptions[], location, isCurrent})
- skills (array of strings)
- certifications (array of strings)
- projects (array of {name, description, technologies[]})
- summary''';

    final response = await _generateContent(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );

    return _parseJsonResponse(response);
  }

  /// General chat completion for custom prompts
  Future<String> chat({
    required String prompt,
    String? systemInstruction,
  }) async {
    return await _generateContent(
      systemPrompt: systemInstruction ?? 'You are a helpful assistant.',
      userPrompt: prompt,
    );
  }

  /// Chat with conversation history
  Future<String> chatWithHistory({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    final contents = <Map<String, dynamic>>[];

    for (final message in messages) {
      final role = message['role'] == 'assistant' ? 'model' : 'user';
      contents.add({
        'role': role,
        'parts': [
          {'text': message['content']}
        ],
      });
    }

    final response = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      data: {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
        },
      },
    );

    return _extractText(response.data);
  }

  /// Core content generation method
  Future<String> _generateContent({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.7,
    int maxOutputTokens = 2048,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw AuthException(message: 'Gemini API key not set');
    }

    developer.log('GeminiApiService: Making request to $_endpoint', name: 'GeminiApiService');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: {
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': userPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxOutputTokens,
          },
        },
      );

      developer.log('GeminiApiService: Response status: ${response.statusCode}', name: 'GeminiApiService');
      return _extractText(response.data);
    } on DioException catch (e) {
      developer.log('GeminiApiService: DioException type: ${e.type}', name: 'GeminiApiService');
      developer.log('GeminiApiService: DioException message: ${e.message}', name: 'GeminiApiService');
      developer.log('GeminiApiService: Response status: ${e.response?.statusCode}', name: 'GeminiApiService');
      developer.log('GeminiApiService: Response data: ${e.response?.data}', name: 'GeminiApiService');
      developer.log('GeminiApiService: Underlying error: ${e.error}', name: 'GeminiApiService');
      developer.log('GeminiApiService: Stack trace: ${e.stackTrace}', name: 'GeminiApiService');
      throw _handleError(e);
    } catch (e, stackTrace) {
      developer.log('GeminiApiService: Non-Dio error: $e', name: 'GeminiApiService');
      developer.log('GeminiApiService: Stack: $stackTrace', name: 'GeminiApiService');
      rethrow;
    }
  }

  String _extractText(Map<String, dynamic>? data) {
    if (data == null) {
      throw ServerException(message: 'Empty response from Gemini API');
    }

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw ServerException(message: 'No candidates in Gemini response');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    if (content == null) {
      throw ServerException(message: 'No content in Gemini response');
    }

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw ServerException(message: 'No parts in Gemini response');
    }

    return parts[0]['text'] as String? ?? '';
  }

  List<String> _parseQuestions(String response) {
    final lines = response.split('\n');
    final questions = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Remove numbering like "1.", "1)", "-", "•"
      final cleaned = trimmed
          .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
          .replaceFirst(RegExp(r'^[-•]\s*'), '')
          .trim();

      if (cleaned.isNotEmpty && cleaned.endsWith('?')) {
        questions.add(cleaned);
      }
    }

    return questions;
  }

  GeminiEvaluationResult _parseEvaluation(String response) {
    try {
      final json = _parseJsonResponse(response);
      return GeminiEvaluationResult(
        contentScore: (json['contentScore'] as num?)?.toDouble() ?? 5.0,
        structureScore: (json['structureScore'] as num?)?.toDouble() ?? 5.0,
        communicationScore:
            (json['communicationScore'] as num?)?.toDouble() ?? 5.0,
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 5.0,
        feedback: json['feedback'] as String? ?? '',
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
        modelAnswer: json['modelAnswer'] as String?,
      );
    } catch (e) {
      return GeminiEvaluationResult(
        contentScore: 5.0,
        structureScore: 5.0,
        communicationScore: 5.0,
        confidenceScore: 5.0,
        feedback: response,
        strengths: [],
        improvements: [],
        modelAnswer: null,
      );
    }
  }

  Map<String, dynamic> _parseJsonResponse(String response) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch != null) {
      try {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      } catch (e) {
        // Fall through to empty map
      }
    }
    return {};
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        throw NetworkException(message: 'No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response);

        if (statusCode == 401 || statusCode == 403) {
          throw AuthException(message: message);
        } else if (statusCode == 429) {
          throw RateLimitException(message: message);
        } else {
          throw ServerException(message: message, statusCode: statusCode);
        }
      default:
        throw ServerException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final error = response!.data['error'];
      if (error is Map) {
        return error['message'] ?? 'Unknown error';
      }
      return error?.toString() ?? 'Unknown error';
    }
    return 'Server error occurred';
  }
}

class GeminiEvaluationResult {
  final double contentScore;
  final double structureScore;
  final double communicationScore;
  final double confidenceScore;
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;
  final String? modelAnswer;

  GeminiEvaluationResult({
    required this.contentScore,
    required this.structureScore,
    required this.communicationScore,
    required this.confidenceScore,
    required this.feedback,
    required this.strengths,
    required this.improvements,
    this.modelAnswer,
  });

  double get overallScore {
    return (contentScore * 0.40) +
        (structureScore * 0.25) +
        (communicationScore * 0.20) +
        (confidenceScore * 0.15);
  }

  ResponseScore toResponseScore() {
    return ResponseScore(
      content: contentScore,
      structure: structureScore,
      communication: communicationScore,
      confidence: confidenceScore,
      overall: overallScore,
    );
  }
}
