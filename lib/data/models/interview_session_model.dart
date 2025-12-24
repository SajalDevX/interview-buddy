import 'package:hive/hive.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/enums.dart';

part 'interview_session_model.g.dart';

@HiveType(typeId: 2)
class InterviewSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? resumeId;

  @HiveField(2)
  final String targetRole;

  @HiveField(3)
  final int typeIndex;

  @HiveField(4)
  final DateTime startedAt;

  @HiveField(5)
  final DateTime? completedAt;

  @HiveField(6)
  final List<QuestionResponseModel> responses;

  @HiveField(7)
  final ResponseScoreModel? overallScore;

  @HiveField(8)
  final String? feedback;

  InterviewSessionModel({
    required this.id,
    this.resumeId,
    required this.targetRole,
    required this.typeIndex,
    required this.startedAt,
    this.completedAt,
    required this.responses,
    this.overallScore,
    this.feedback,
  });

  factory InterviewSessionModel.fromEntity(InterviewSession entity) {
    return InterviewSessionModel(
      id: entity.id,
      resumeId: entity.resumeId,
      targetRole: entity.targetRole,
      typeIndex: entity.type.index,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      responses: entity.responses
          .map((r) => QuestionResponseModel.fromEntity(r))
          .toList(),
      overallScore: entity.overallScore != null
          ? ResponseScoreModel.fromEntity(entity.overallScore!)
          : null,
      feedback: entity.feedback,
    );
  }

  InterviewSession toEntity() {
    return InterviewSession(
      id: id,
      resumeId: resumeId,
      targetRole: targetRole,
      type: InterviewType.values[typeIndex],
      startedAt: startedAt,
      completedAt: completedAt,
      responses: responses.map((r) => r.toEntity()).toList(),
      overallScore: overallScore?.toEntity(),
      feedback: feedback,
    );
  }
}

@HiveType(typeId: 3)
class QuestionResponseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final int categoryIndex;

  @HiveField(3)
  final String? audioPath;

  @HiveField(4)
  final String transcript;

  @HiveField(5)
  final ResponseScoreModel? score;

  @HiveField(6)
  final String? feedback;

  @HiveField(7)
  final String? modelAnswer;

  @HiveField(8)
  final DateTime answeredAt;

  @HiveField(9)
  final int responseDurationMs;

  QuestionResponseModel({
    required this.id,
    required this.question,
    required this.categoryIndex,
    this.audioPath,
    required this.transcript,
    this.score,
    this.feedback,
    this.modelAnswer,
    required this.answeredAt,
    required this.responseDurationMs,
  });

  factory QuestionResponseModel.fromEntity(QuestionResponse entity) {
    return QuestionResponseModel(
      id: entity.id,
      question: entity.question,
      categoryIndex: entity.category.index,
      audioPath: entity.audioPath,
      transcript: entity.transcript,
      score: entity.score != null
          ? ResponseScoreModel.fromEntity(entity.score!)
          : null,
      feedback: entity.feedback,
      modelAnswer: entity.modelAnswer,
      answeredAt: entity.answeredAt,
      responseDurationMs: entity.responseDuration.inMilliseconds,
    );
  }

  QuestionResponse toEntity() {
    return QuestionResponse(
      id: id,
      question: question,
      category: QuestionCategory.values[categoryIndex],
      audioPath: audioPath,
      transcript: transcript,
      score: score?.toEntity(),
      feedback: feedback,
      modelAnswer: modelAnswer,
      answeredAt: answeredAt,
      responseDuration: Duration(milliseconds: responseDurationMs),
    );
  }
}

@HiveType(typeId: 4)
class ResponseScoreModel extends HiveObject {
  @HiveField(0)
  final double content;

  @HiveField(1)
  final double structure;

  @HiveField(2)
  final double communication;

  @HiveField(3)
  final double confidence;

  @HiveField(4)
  final double overall;

  ResponseScoreModel({
    required this.content,
    required this.structure,
    required this.communication,
    required this.confidence,
    required this.overall,
  });

  factory ResponseScoreModel.fromEntity(ResponseScore entity) {
    return ResponseScoreModel(
      content: entity.content,
      structure: entity.structure,
      communication: entity.communication,
      confidence: entity.confidence,
      overall: entity.overall,
    );
  }

  ResponseScore toEntity() {
    return ResponseScore(
      content: content,
      structure: structure,
      communication: communication,
      confidence: confidence,
      overall: overall,
    );
  }
}
