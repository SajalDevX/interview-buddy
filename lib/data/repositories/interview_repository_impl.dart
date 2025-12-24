import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/parsed_resume.dart';
import '../../domain/repositories/interview_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/groq_api_service.dart';
import '../models/interview_session_model.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final GroqApiService groqApiService;
  final HiveService hiveService;
  final Connectivity connectivity;
  final _uuid = const Uuid();

  InterviewRepositoryImpl({
    required this.groqApiService,
    required this.hiveService,
    required this.connectivity,
  });

  Future<bool> _isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, InterviewSession>> startInterview({
    required String targetRole,
    required InterviewType type,
    String? resumeId,
  }) async {
    try {
      final session = InterviewSession(
        id: _uuid.v4(),
        resumeId: resumeId,
        targetRole: targetRole,
        type: type,
        startedAt: DateTime.now(),
      );

      await hiveService.saveInterviewSession(
        InterviewSessionModel.fromEntity(session),
      );

      return Right(session);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateQuestions({
    required String targetRole,
    required InterviewType type,
    required QuestionCategory category,
    ParsedResume? resume,
    int count = 5,
  }) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final questions = await groqApiService.generateInterviewQuestions(
        targetRole: targetRole,
        interviewType: type,
        category: category,
        resume: resume,
        count: count,
      );

      return Right(questions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuestionResponse>> submitAnswer({
    required String sessionId,
    required String question,
    required QuestionCategory category,
    required String transcript,
    String? audioPath,
  }) async {
    try {
      final sessionModel = hiveService.getInterviewSession(sessionId);
      if (sessionModel == null) {
        return const Left(CacheFailure(message: 'Session not found'));
      }

      final session = sessionModel.toEntity();

      // Get feedback from AI
      final feedbackResult = await getFeedback(
        question: question,
        answer: transcript,
        category: category,
        targetRole: session.targetRole,
      );

      ResponseScore? score;
      String? feedback;

      feedbackResult.fold(
        (failure) {
          // Use default score if AI feedback fails
          score = ResponseScore.calculate(
            content: 5.0,
            structure: 5.0,
            communication: 5.0,
            confidence: 5.0,
          );
        },
        (responseScore) {
          score = responseScore;
        },
      );

      final response = QuestionResponse(
        id: _uuid.v4(),
        question: question,
        category: category,
        audioPath: audioPath,
        transcript: transcript,
        score: score,
        feedback: feedback,
        answeredAt: DateTime.now(),
        responseDuration: Duration.zero,
      );

      // Update session with new response
      final updatedSession = session.copyWith(
        responses: [...session.responses, response],
      );

      await hiveService.saveInterviewSession(
        InterviewSessionModel.fromEntity(updatedSession),
      );

      return Right(response);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResponseScore>> getFeedback({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final result = await groqApiService.evaluateAnswer(
        question: question,
        answer: answer,
        category: category,
        targetRole: targetRole,
      );

      return Right(result.toResponseScore());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getFollowUpQuestion({
    required String previousQuestion,
    required String previousAnswer,
    required QuestionCategory category,
    required String targetRole,
  }) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final followUp = await groqApiService.generateFollowUpQuestion(
        previousQuestion: previousQuestion,
        previousAnswer: previousAnswer,
        category: category,
        targetRole: targetRole,
      );

      return Right(followUp);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getModelAnswer({
    required String question,
    required QuestionCategory category,
    required String targetRole,
    ParsedResume? resume,
  }) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final modelAnswer = await groqApiService.generateModelAnswer(
        question: question,
        category: category,
        targetRole: targetRole,
        resume: resume,
      );

      return Right(modelAnswer);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewSession>> completeInterview(String sessionId) async {
    try {
      final sessionModel = hiveService.getInterviewSession(sessionId);
      if (sessionModel == null) {
        return const Left(CacheFailure(message: 'Session not found'));
      }

      final session = sessionModel.toEntity();

      // Calculate overall score
      ResponseScore? overallScore;
      if (session.responses.isNotEmpty) {
        double totalContent = 0;
        double totalStructure = 0;
        double totalCommunication = 0;
        double totalConfidence = 0;

        for (final response in session.responses) {
          if (response.score != null) {
            totalContent += response.score!.content;
            totalStructure += response.score!.structure;
            totalCommunication += response.score!.communication;
            totalConfidence += response.score!.confidence;
          }
        }

        final count = session.responses.length;
        overallScore = ResponseScore.calculate(
          content: totalContent / count,
          structure: totalStructure / count,
          communication: totalCommunication / count,
          confidence: totalConfidence / count,
        );
      }

      final completedSession = session.copyWith(
        completedAt: DateTime.now(),
        overallScore: overallScore,
      );

      await hiveService.saveInterviewSession(
        InterviewSessionModel.fromEntity(completedSession),
      );

      return Right(completedSession);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InterviewSession>> getSession(String sessionId) async {
    try {
      final sessionModel = hiveService.getInterviewSession(sessionId);
      if (sessionModel == null) {
        return const Left(CacheFailure(message: 'Session not found'));
      }
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InterviewSession>>> getAllSessions() async {
    try {
      final sessions = hiveService.getAllInterviewSessions()
          .map((m) => m.toEntity())
          .toList();
      return Right(sessions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InterviewSession>>> getRecentSessions({int limit = 10}) async {
    try {
      final sessions = hiveService.getRecentSessions(limit: limit)
          .map((m) => m.toEntity())
          .toList();
      return Right(sessions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await hiveService.deleteInterviewSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> transcribeAudio(String audioPath) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final file = File(audioPath);
      if (!await file.exists()) {
        return const Left(AudioFailure(message: 'Audio file not found'));
      }

      final transcript = await groqApiService.transcribeAudio(file);
      return Right(transcript);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(AudioFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> textToSpeech({
    required String text,
    TTSVoice voice = TTSVoice.fritz,
  }) async {
    try {
      if (!await _isConnected()) {
        return const Left(NetworkFailure());
      }

      final audioData = await groqApiService.textToSpeech(
        text: text,
        voice: voice,
      );

      // Save audio to temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File(filePath);
      await file.writeAsBytes(audioData);

      return Right(filePath);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(AudioFailure(message: e.toString()));
    }
  }
}
