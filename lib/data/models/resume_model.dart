import 'package:hive/hive.dart';
import '../../domain/entities/parsed_resume.dart';

part 'resume_model.g.dart';

@HiveType(typeId: 5)
class ParsedResumeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? fullName;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? location;

  @HiveField(5)
  final List<EducationModel> education;

  @HiveField(6)
  final List<WorkExperienceModel> workExperience;

  @HiveField(7)
  final List<String> skills;

  @HiveField(8)
  final List<String> certifications;

  @HiveField(9)
  final List<ProjectModel> projects;

  @HiveField(10)
  final String? summary;

  @HiveField(11)
  final String rawText;

  @HiveField(12)
  final DateTime parsedAt;

  ParsedResumeModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    required this.education,
    required this.workExperience,
    required this.skills,
    required this.certifications,
    required this.projects,
    this.summary,
    required this.rawText,
    required this.parsedAt,
  });

  factory ParsedResumeModel.fromEntity(ParsedResume entity) {
    return ParsedResumeModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      location: entity.location,
      education: entity.education.map((e) => EducationModel.fromEntity(e)).toList(),
      workExperience: entity.workExperience.map((e) => WorkExperienceModel.fromEntity(e)).toList(),
      skills: entity.skills,
      certifications: entity.certifications,
      projects: entity.projects.map((e) => ProjectModel.fromEntity(e)).toList(),
      summary: entity.summary,
      rawText: entity.rawText,
      parsedAt: entity.parsedAt,
    );
  }

  ParsedResume toEntity() {
    return ParsedResume(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      location: location,
      education: education.map((e) => e.toEntity()).toList(),
      workExperience: workExperience.map((e) => e.toEntity()).toList(),
      skills: skills,
      certifications: certifications,
      projects: projects.map((e) => e.toEntity()).toList(),
      summary: summary,
      rawText: rawText,
      parsedAt: parsedAt,
    );
  }
}

@HiveType(typeId: 6)
class EducationModel extends HiveObject {
  @HiveField(0)
  final String degree;

  @HiveField(1)
  final String institution;

  @HiveField(2)
  final DateTime? startDate;

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final String? gpa;

  @HiveField(5)
  final String? field;

  EducationModel({
    required this.degree,
    required this.institution,
    this.startDate,
    this.endDate,
    this.gpa,
    this.field,
  });

  factory EducationModel.fromEntity(Education entity) {
    return EducationModel(
      degree: entity.degree,
      institution: entity.institution,
      startDate: entity.startDate,
      endDate: entity.endDate,
      gpa: entity.gpa,
      field: entity.field,
    );
  }

  Education toEntity() {
    return Education(
      degree: degree,
      institution: institution,
      startDate: startDate,
      endDate: endDate,
      gpa: gpa,
      field: field,
    );
  }
}

@HiveType(typeId: 7)
class WorkExperienceModel extends HiveObject {
  @HiveField(0)
  final String company;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final DateTime? startDate;

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final List<String> descriptions;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final bool isCurrent;

  WorkExperienceModel({
    required this.company,
    required this.role,
    this.startDate,
    this.endDate,
    required this.descriptions,
    this.location,
    required this.isCurrent,
  });

  factory WorkExperienceModel.fromEntity(WorkExperience entity) {
    return WorkExperienceModel(
      company: entity.company,
      role: entity.role,
      startDate: entity.startDate,
      endDate: entity.endDate,
      descriptions: entity.descriptions,
      location: entity.location,
      isCurrent: entity.isCurrent,
    );
  }

  WorkExperience toEntity() {
    return WorkExperience(
      company: company,
      role: role,
      startDate: startDate,
      endDate: endDate,
      descriptions: descriptions,
      location: location,
      isCurrent: isCurrent,
    );
  }
}

@HiveType(typeId: 8)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final List<String> technologies;

  @HiveField(3)
  final String? url;

  ProjectModel({
    required this.name,
    this.description,
    required this.technologies,
    this.url,
  });

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      name: entity.name,
      description: entity.description,
      technologies: entity.technologies,
      url: entity.url,
    );
  }

  Project toEntity() {
    return Project(
      name: name,
      description: description,
      technologies: technologies,
      url: url,
    );
  }
}
