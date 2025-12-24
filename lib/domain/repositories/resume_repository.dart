import '../entities/parsed_resume.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class ResumeRepository {
  /// Parse a resume from file path
  Future<Either<Failure, ParsedResume>> parseResume(String filePath);

  /// Parse resume from image using OCR
  Future<Either<Failure, ParsedResume>> parseResumeFromImage(String imagePath);

  /// Save parsed resume
  Future<Either<Failure, void>> saveResume(ParsedResume resume);

  /// Get resume by ID
  Future<Either<Failure, ParsedResume>> getResume(String id);

  /// Get all resumes
  Future<Either<Failure, List<ParsedResume>>> getAllResumes();

  /// Get latest resume
  Future<Either<Failure, ParsedResume?>> getLatestResume();

  /// Update resume
  Future<Either<Failure, void>> updateResume(ParsedResume resume);

  /// Delete resume
  Future<Either<Failure, void>> deleteResume(String id);

  /// Extract text from PDF
  Future<Either<Failure, String>> extractTextFromPDF(String filePath);

  /// Extract text from image using OCR
  Future<Either<Failure, String>> extractTextFromImage(String imagePath);
}
