// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterviewSessionModelAdapter extends TypeAdapter<InterviewSessionModel> {
  @override
  final int typeId = 2;

  @override
  InterviewSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewSessionModel(
      id: fields[0] as String,
      resumeId: fields[1] as String?,
      targetRole: fields[2] as String,
      typeIndex: fields[3] as int,
      startedAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      responses: (fields[6] as List).cast<QuestionResponseModel>(),
      overallScore: fields[7] as ResponseScoreModel?,
      feedback: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewSessionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.resumeId)
      ..writeByte(2)
      ..write(obj.targetRole)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.startedAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.responses)
      ..writeByte(7)
      ..write(obj.overallScore)
      ..writeByte(8)
      ..write(obj.feedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionResponseModelAdapter extends TypeAdapter<QuestionResponseModel> {
  @override
  final int typeId = 3;

  @override
  QuestionResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionResponseModel(
      id: fields[0] as String,
      question: fields[1] as String,
      categoryIndex: fields[2] as int,
      audioPath: fields[3] as String?,
      transcript: fields[4] as String,
      score: fields[5] as ResponseScoreModel?,
      feedback: fields[6] as String?,
      modelAnswer: fields[7] as String?,
      answeredAt: fields[8] as DateTime,
      responseDurationMs: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionResponseModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.categoryIndex)
      ..writeByte(3)
      ..write(obj.audioPath)
      ..writeByte(4)
      ..write(obj.transcript)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.feedback)
      ..writeByte(7)
      ..write(obj.modelAnswer)
      ..writeByte(8)
      ..write(obj.answeredAt)
      ..writeByte(9)
      ..write(obj.responseDurationMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResponseScoreModelAdapter extends TypeAdapter<ResponseScoreModel> {
  @override
  final int typeId = 4;

  @override
  ResponseScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResponseScoreModel(
      content: fields[0] as double,
      structure: fields[1] as double,
      communication: fields[2] as double,
      confidence: fields[3] as double,
      overall: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ResponseScoreModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.structure)
      ..writeByte(2)
      ..write(obj.communication)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.overall);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
