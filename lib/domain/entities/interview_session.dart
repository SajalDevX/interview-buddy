import 'package:equatable/equatable.dart';
import 'enums.dart';

class InterviewSession extends Equatable {
  final String id;
  final String? resumeId;
  final String targetRole;
  final InterviewType type;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<QuestionResponse> responses;
  final ResponseScore? overallScore;
  final String? feedback;

  const InterviewSession({
    required this.id,
    this.resumeId,
    required this.targetRole,
    required this.type,
    required this.startedAt,
    this.completedAt,
    this.responses = const [],
    this.overallScore,
    this.feedback,
  });

  bool get isCompleted => completedAt != null;

  Duration get duration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  int get questionsAnswered => responses.length;

  int get totalQuestions => type.questionCount;

  double get progress => totalQuestions > 0 ? questionsAnswered / totalQuestions : 0;

  double get averageScore {
    if (responses.isEmpty) return 0;
    final totalScore = responses.fold<double>(
      0,
      (sum, response) => sum + (response.score?.overall ?? 0),
    );
    return totalScore / responses.length;
  }

  InterviewSession copyWith({
    DateTime? completedAt,
    List<QuestionResponse>? responses,
    ResponseScore? overallScore,
    String? feedback,
  }) {
    return InterviewSession(
      id: id,
      resumeId: resumeId,
      targetRole: targetRole,
      type: type,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      responses: responses ?? this.responses,
      overallScore: overallScore ?? this.overallScore,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        resumeId,
        targetRole,
        type,
        startedAt,
        completedAt,
        responses,
        overallScore,
        feedback,
      ];
}

class QuestionResponse extends Equatable {
  final String id;
  final String question;
  final QuestionCategory category;
  final String? audioPath;
  final String transcript;
  final ResponseScore? score;
  final String? feedback;
  final String? modelAnswer;
  final DateTime answeredAt;
  final Duration responseDuration;

  const QuestionResponse({
    required this.id,
    required this.question,
    required this.category,
    this.audioPath,
    required this.transcript,
    this.score,
    this.feedback,
    this.modelAnswer,
    required this.answeredAt,
    required this.responseDuration,
  });

  @override
  List<Object?> get props => [
        id,
        question,
        category,
        audioPath,
        transcript,
        score,
        feedback,
        modelAnswer,
        answeredAt,
        responseDuration,
      ];
}

class ResponseScore extends Equatable {
  final double content;
  final double structure;
  final double communication;
  final double confidence;
  final double overall;

  const ResponseScore({
    required this.content,
    required this.structure,
    required this.communication,
    required this.confidence,
    required this.overall,
  });

  factory ResponseScore.calculate({
    required double content,
    required double structure,
    required double communication,
    required double confidence,
  }) {
    // Weights from PRD: Content 40%, Structure 25%, Communication 20%, Confidence 15%
    final overall = (content * 0.40) +
        (structure * 0.25) +
        (communication * 0.20) +
        (confidence * 0.15);

    return ResponseScore(
      content: content,
      structure: structure,
      communication: communication,
      confidence: confidence,
      overall: overall,
    );
  }

  @override
  List<Object?> get props => [content, structure, communication, confidence, overall];
}
