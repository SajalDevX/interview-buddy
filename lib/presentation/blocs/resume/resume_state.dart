part of 'resume_bloc.dart';

abstract class ResumeState extends Equatable {
  const ResumeState();

  @override
  List<Object?> get props => [];
}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumeParsed extends ResumeState {
  final ParsedResume resume;

  const ResumeParsed(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ResumeSaved extends ResumeState {}

class ResumeError extends ResumeState {
  final String message;

  const ResumeError(this.message);

  @override
  List<Object?> get props => [message];
}
