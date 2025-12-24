import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/parsed_resume.dart';
import '../../../domain/usecases/resume/parse_resume_usecase.dart';
import '../../../domain/usecases/resume/save_resume_usecase.dart';

part 'resume_event.dart';
part 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ParseResumeUseCase parseResumeUseCase;
  final SaveResumeUseCase saveResumeUseCase;

  ResumeBloc({
    required this.parseResumeUseCase,
    required this.saveResumeUseCase,
  }) : super(ResumeInitial()) {
    on<ParseResumeEvent>(_onParseResume);
    on<SaveResumeEvent>(_onSaveResume);
    on<ClearResumeEvent>(_onClearResume);
  }

  Future<void> _onParseResume(
    ParseResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());

    final result = await parseResumeUseCase(event.filePath);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (resume) => emit(ResumeParsed(resume)),
    );
  }

  Future<void> _onSaveResume(
    SaveResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeLoading());

    final result = await saveResumeUseCase(event.resume);

    result.fold(
      (failure) => emit(ResumeError(failure.message)),
      (_) => emit(ResumeSaved()),
    );
  }

  Future<void> _onClearResume(
    ClearResumeEvent event,
    Emitter<ResumeState> emit,
  ) async {
    emit(ResumeInitial());
  }
}
