import '../entities/enums.dart';
import '../entities/interview_session.dart';
import '../entities/parsed_resume.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class InterviewRepository {
  /// Start a new interview session
  Future<Either<Failure, InterviewSession>> startInterview({
    required String targetRole,
    required InterviewType type,
    String? resumeId,
  });

  /// Generate interview questions
  Future<Either<Failure, List<String>>> generateQuestions({
    required String targetRole,
    required InterviewType type,
    required QuestionCategory category,
    ParsedResume? resume,
    int count,
  });

  /// Submit an answer and get feedback
  Future<Either<Failure, QuestionResponse>> submitAnswer({
    required String sessionId,
    required String question,
    required QuestionCategory category,
    required String transcript,
    String? audioPath,
  });

  /// Get AI feedback for an answer
  Future<Either<Failure, ResponseScore>> getFeedback({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  });

  /// Generate follow-up question
  Future<Either<Failure, String>> getFollowUpQuestion({
    required String previousQuestion,
    required String previousAnswer,
    required QuestionCategory category,
    required String targetRole,
  });

  /// Get model answer for a question
  Future<Either<Failure, String>> getModelAnswer({
    required String question,
    required QuestionCategory category,
    required String targetRole,
    ParsedResume? resume,
  });

  /// Complete an interview session
  Future<Either<Failure, InterviewSession>> completeInterview(String sessionId);

  /// Get interview session by ID
  Future<Either<Failure, InterviewSession>> getSession(String sessionId);

  /// Get all interview sessions
  Future<Either<Failure, List<InterviewSession>>> getAllSessions();

  /// Get recent interview sessions
  Future<Either<Failure, List<InterviewSession>>> getRecentSessions({int limit = 10});

  /// Delete interview session
  Future<Either<Failure, void>> deleteSession(String sessionId);

  /// Transcribe audio to text
  Future<Either<Failure, String>> transcribeAudio(String audioPath);

  /// Convert text to speech
  Future<Either<Failure, String>> textToSpeech({
    required String text,
    TTSVoice voice,
  });
}
