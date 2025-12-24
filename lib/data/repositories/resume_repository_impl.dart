import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/parsed_resume.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/local/hive_service.dart';
import '../models/resume_model.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final HiveService hiveService;
  final _uuid = const Uuid();
  final _textRecognizer = TextRecognizer();

  ResumeRepositoryImpl({required this.hiveService});

  @override
  Future<Either<Failure, ParsedResume>> parseResume(String filePath) async {
    try {
      final file = File(filePath);
      final extension = filePath.split('.').last.toLowerCase();

      String rawText;
      if (extension == 'pdf') {
        final result = await extractTextFromPDF(filePath);
        rawText = result.fold((f) => '', (text) => text);
      } else if (['png', 'jpg', 'jpeg'].contains(extension)) {
        final result = await extractTextFromImage(filePath);
        rawText = result.fold((f) => '', (text) => text);
      } else {
        rawText = await file.readAsString();
      }

      if (rawText.isEmpty) {
        return const Left(OCRFailure(message: 'Could not extract text from document'));
      }

      final resume = _parseResumeText(rawText);
      return Right(resume);
    } catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsedResume>> parseResumeFromImage(String imagePath) async {
    try {
      final result = await extractTextFromImage(imagePath);
      return result.fold(
        (failure) => Left(failure),
        (text) {
          final resume = _parseResumeText(text);
          return Right(resume);
        },
      );
    } catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> extractTextFromPDF(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final StringBuffer textBuffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final text = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        textBuffer.writeln(text);
      }

      document.dispose();
      return Right(textBuffer.toString());
    } catch (e) {
      return Left(OCRFailure(message: 'Failed to extract text from PDF: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return Right(recognizedText.text);
    } catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }

  ParsedResume _parseResumeText(String rawText) {
    // Extract sections from raw text
    final lines = rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();

    // Basic parsing - extract name from first non-empty line
    String? fullName;
    String? email;
    String? phone;
    final skills = <String>[];

    for (final line in lines) {
      // Extract email
      final emailMatch = RegExp(r'[\w.-]+@[\w.-]+\.\w+').firstMatch(line);
      if (emailMatch != null) {
        email = emailMatch.group(0);
      }

      // Extract phone
      final phoneMatch = RegExp(r'[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}')
          .firstMatch(line);
      if (phoneMatch != null) {
        phone = phoneMatch.group(0);
      }

      // First substantial line is likely the name
      if (fullName == null &&
          line.trim().length > 2 &&
          !line.contains('@') &&
          !RegExp(r'\d{3}').hasMatch(line)) {
        fullName = line.trim();
      }

      // Look for skills section
      if (line.toLowerCase().contains('skill') ||
          line.toLowerCase().contains('technolog')) {
        // Next lines might be skills
      }
    }

    // Extract skills from common patterns
    final skillPatterns = [
      'flutter', 'dart', 'java', 'python', 'javascript', 'typescript',
      'react', 'angular', 'vue', 'node', 'sql', 'mongodb', 'firebase',
      'aws', 'gcp', 'azure', 'docker', 'kubernetes', 'git', 'agile',
      'scrum', 'ci/cd', 'rest', 'graphql', 'html', 'css', 'swift', 'kotlin'
    ];

    final lowerText = rawText.toLowerCase();
    for (final skill in skillPatterns) {
      if (lowerText.contains(skill)) {
        skills.add(skill.substring(0, 1).toUpperCase() + skill.substring(1));
      }
    }

    return ParsedResume(
      id: _uuid.v4(),
      fullName: fullName,
      email: email,
      phone: phone,
      skills: skills,
      rawText: rawText,
      parsedAt: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, void>> saveResume(ParsedResume resume) async {
    try {
      await hiveService.saveResume(ParsedResumeModel.fromEntity(resume));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsedResume>> getResume(String id) async {
    try {
      final model = hiveService.getResume(id);
      if (model == null) {
        return const Left(CacheFailure(message: 'Resume not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParsedResume>>> getAllResumes() async {
    try {
      final resumes = hiveService.getAllResumes().map((m) => m.toEntity()).toList();
      return Right(resumes);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsedResume?>> getLatestResume() async {
    try {
      final model = hiveService.getLatestResume();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateResume(ParsedResume resume) async {
    try {
      await hiveService.saveResume(ParsedResumeModel.fromEntity(resume));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    try {
      await hiveService.deleteResume(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
