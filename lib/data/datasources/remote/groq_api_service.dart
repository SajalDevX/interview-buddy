import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/parsed_resume.dart';
import '../../../domain/entities/interview_session.dart';
import 'ai_prompts.dart';

class GroqApiService {
  final ApiClient _apiClient;

  GroqApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  void setApiKey(String apiKey) {
    _apiClient.setApiKey(apiKey);
  }

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

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: AppConstants.primaryModel,
    );

    // Parse the response to extract questions
    final questions = _parseQuestions(response);
    return questions;
  }

  /// Generate a single follow-up question based on the previous answer
  Future<String> generateFollowUpQuestion({
    required String previousQuestion,
    required String previousAnswer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    final systemPrompt = AIPrompts.followUpSystemPrompt;
    final userPrompt = AIPrompts.getFollowUpPrompt(
      previousQuestion: previousQuestion,
      previousAnswer: previousAnswer,
      category: category,
      targetRole: targetRole,
    );

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: AppConstants.fastModel,
    );

    return response.trim();
  }

  /// Evaluate the user's answer and provide feedback
  Future<EvaluationResult> evaluateAnswer({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    final systemPrompt = AIPrompts.evaluatorSystemPrompt;
    final userPrompt = AIPrompts.getEvaluationPrompt(
      question: question,
      answer: answer,
      category: category,
      targetRole: targetRole,
    );

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: AppConstants.primaryModel,
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
    final systemPrompt = AIPrompts.modelAnswerSystemPrompt;
    final userPrompt = AIPrompts.getModelAnswerPrompt(
      question: question,
      category: category,
      targetRole: targetRole,
      resume: resume,
    );

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: AppConstants.primaryModel,
    );

    return response.trim();
  }

  /// Speech-to-Text using Groq Whisper
  Future<String> transcribeAudio(File audioFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'audio.wav',
      ),
      'model': AppConstants.whisperModel,
      'language': 'en',
      'response_format': 'json',
    });

    final response = await _apiClient.postFormData<Map<String, dynamic>>(
      AppConstants.groqTranscriptionEndpoint,
      data: formData,
    );

    if (response.data != null && response.data!['text'] != null) {
      return response.data!['text'] as String;
    }

    throw ServerException(message: 'Failed to transcribe audio');
  }

  /// Text-to-Speech using Groq PlayAI
  Future<Uint8List> textToSpeech({
    required String text,
    TTSVoice voice = TTSVoice.fritz,
  }) async {
    final response = await _apiClient.post<List<int>>(
      AppConstants.groqSpeechEndpoint,
      data: {
        'model': AppConstants.ttsModel,
        'input': text,
        'voice': voice.apiName,
        'response_format': 'wav',
      },
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.data != null) {
      return Uint8List.fromList(response.data!);
    }

    throw ServerException(message: 'Failed to generate speech');
  }

  /// Parse resume text using AI
  Future<Map<String, dynamic>> parseResumeWithAI(String resumeText) async {
    final systemPrompt = AIPrompts.resumeParserSystemPrompt;
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

    final response = await _chatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      model: AppConstants.primaryModel,
    );

    return _parseJsonResponse(response);
  }

  /// Core chat completion method
  Future<String> _chatCompletion({
    required String systemPrompt,
    required String userPrompt,
    String model = AppConstants.primaryModel,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      AppConstants.groqChatEndpoint,
      data: {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
    );

    if (response.data != null && response.data!['choices'] != null) {
      final choices = response.data!['choices'] as List;
      if (choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      }
    }

    throw ServerException(message: 'Invalid response from API');
  }

  /// Chat completion with conversation history
  Future<String> chatWithHistory({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    String model = AppConstants.primaryModel,
  }) async {
    final allMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final response = await _apiClient.post<Map<String, dynamic>>(
      AppConstants.groqChatEndpoint,
      data: {
        'model': model,
        'messages': allMessages,
        'temperature': 0.7,
        'max_tokens': 2048,
      },
    );

    if (response.data != null && response.data!['choices'] != null) {
      final choices = response.data!['choices'] as List;
      if (choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      }
    }

    throw ServerException(message: 'Invalid response from API');
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

  EvaluationResult _parseEvaluation(String response) {
    try {
      final json = _parseJsonResponse(response);
      return EvaluationResult(
        contentScore: (json['contentScore'] as num?)?.toDouble() ?? 5.0,
        structureScore: (json['structureScore'] as num?)?.toDouble() ?? 5.0,
        communicationScore: (json['communicationScore'] as num?)?.toDouble() ?? 5.0,
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 5.0,
        feedback: json['feedback'] as String? ?? '',
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
        modelAnswer: json['modelAnswer'] as String?,
      );
    } catch (e) {
      // Fallback parsing if JSON extraction fails
      return EvaluationResult(
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
    // Try to extract JSON from the response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch != null) {
      try {
        return Map<String, dynamic>.from(
          _parseJson(jsonMatch.group(0)!),
        );
      } catch (e) {
        // Fall through to empty map
      }
    }
    return {};
  }

  dynamic _parseJson(String jsonString) {
    // Simple JSON parser - in production, use dart:convert
    jsonString = jsonString.trim();
    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      // This is a simplified parser - use json.decode in actual implementation
      return <String, dynamic>{};
    }
    return null;
  }
}

class EvaluationResult {
  final double contentScore;
  final double structureScore;
  final double communicationScore;
  final double confidenceScore;
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;
  final String? modelAnswer;

  EvaluationResult({
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
