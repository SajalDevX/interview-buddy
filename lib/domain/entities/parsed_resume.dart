import 'package:equatable/equatable.dart';

class ParsedResume extends Equatable {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? location;
  final List<Education> education;
  final List<WorkExperience> workExperience;
  final List<String> skills;
  final List<String> certifications;
  final List<Project> projects;
  final String? summary;
  final String rawText;
  final DateTime parsedAt;

  const ParsedResume({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.education = const [],
    this.workExperience = const [],
    this.skills = const [],
    this.certifications = const [],
    this.projects = const [],
    this.summary,
    required this.rawText,
    required this.parsedAt,
  });

  bool get isEmpty => rawText.isEmpty;
  bool get hasEducation => education.isNotEmpty;
  bool get hasExperience => workExperience.isNotEmpty;
  bool get hasSkills => skills.isNotEmpty;

  int get yearsOfExperience {
    if (workExperience.isEmpty) return 0;
    int totalMonths = 0;
    for (final exp in workExperience) {
      if (exp.startDate != null) {
        final endDate = exp.endDate ?? DateTime.now();
        totalMonths += (endDate.year - exp.startDate!.year) * 12 +
            (endDate.month - exp.startDate!.month);
      }
    }
    return (totalMonths / 12).round();
  }

  ParsedResume copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    List<Education>? education,
    List<WorkExperience>? workExperience,
    List<String>? skills,
    List<String>? certifications,
    List<Project>? projects,
    String? summary,
  }) {
    return ParsedResume(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      education: education ?? this.education,
      workExperience: workExperience ?? this.workExperience,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      projects: projects ?? this.projects,
      summary: summary ?? this.summary,
      rawText: rawText,
      parsedAt: parsedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        location,
        education,
        workExperience,
        skills,
        certifications,
        projects,
        summary,
        rawText,
        parsedAt,
      ];
}

class Education extends Equatable {
  final String degree;
  final String institution;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? gpa;
  final String? field;

  const Education({
    required this.degree,
    required this.institution,
    this.startDate,
    this.endDate,
    this.gpa,
    this.field,
  });

  @override
  List<Object?> get props => [degree, institution, startDate, endDate, gpa, field];
}

class WorkExperience extends Equatable {
  final String company;
  final String role;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> descriptions;
  final String? location;
  final bool isCurrent;

  const WorkExperience({
    required this.company,
    required this.role,
    this.startDate,
    this.endDate,
    this.descriptions = const [],
    this.location,
    this.isCurrent = false,
  });

  @override
  List<Object?> get props =>
      [company, role, startDate, endDate, descriptions, location, isCurrent];
}

class Project extends Equatable {
  final String name;
  final String? description;
  final List<String> technologies;
  final String? url;

  const Project({
    required this.name,
    this.description,
    this.technologies = const [],
    this.url,
  });

  @override
  List<Object?> get props => [name, description, technologies, url];
}
