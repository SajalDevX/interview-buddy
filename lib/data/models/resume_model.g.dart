// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParsedResumeModelAdapter extends TypeAdapter<ParsedResumeModel> {
  @override
  final int typeId = 5;

  @override
  ParsedResumeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParsedResumeModel(
      id: fields[0] as String,
      fullName: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      location: fields[4] as String?,
      education: (fields[5] as List).cast<EducationModel>(),
      workExperience: (fields[6] as List).cast<WorkExperienceModel>(),
      skills: (fields[7] as List).cast<String>(),
      certifications: (fields[8] as List).cast<String>(),
      projects: (fields[9] as List).cast<ProjectModel>(),
      summary: fields[10] as String?,
      rawText: fields[11] as String,
      parsedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ParsedResumeModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.education)
      ..writeByte(6)
      ..write(obj.workExperience)
      ..writeByte(7)
      ..write(obj.skills)
      ..writeByte(8)
      ..write(obj.certifications)
      ..writeByte(9)
      ..write(obj.projects)
      ..writeByte(10)
      ..write(obj.summary)
      ..writeByte(11)
      ..write(obj.rawText)
      ..writeByte(12)
      ..write(obj.parsedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedResumeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EducationModelAdapter extends TypeAdapter<EducationModel> {
  @override
  final int typeId = 6;

  @override
  EducationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EducationModel(
      degree: fields[0] as String,
      institution: fields[1] as String,
      startDate: fields[2] as DateTime?,
      endDate: fields[3] as DateTime?,
      gpa: fields[4] as String?,
      field: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EducationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.degree)
      ..writeByte(1)
      ..write(obj.institution)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.gpa)
      ..writeByte(5)
      ..write(obj.field);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EducationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkExperienceModelAdapter extends TypeAdapter<WorkExperienceModel> {
  @override
  final int typeId = 7;

  @override
  WorkExperienceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkExperienceModel(
      company: fields[0] as String,
      role: fields[1] as String,
      startDate: fields[2] as DateTime?,
      endDate: fields[3] as DateTime?,
      descriptions: (fields[4] as List).cast<String>(),
      location: fields[5] as String?,
      isCurrent: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkExperienceModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.company)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.descriptions)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.isCurrent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkExperienceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectModelAdapter extends TypeAdapter<ProjectModel> {
  @override
  final int typeId = 8;

  @override
  ProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectModel(
      name: fields[0] as String,
      description: fields[1] as String?,
      technologies: (fields[2] as List).cast<String>(),
      url: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.technologies)
      ..writeByte(3)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
