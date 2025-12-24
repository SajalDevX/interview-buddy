part of 'resume_bloc.dart';

abstract class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

class ParseResumeEvent extends ResumeEvent {
  final String filePath;

  const ParseResumeEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SaveResumeEvent extends ResumeEvent {
  final ParsedResume resume;

  const SaveResumeEvent(this.resume);

  @override
  List<Object?> get props => [resume];
}

class ClearResumeEvent extends ResumeEvent {}
