import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/progress_record.dart';
import '../../../domain/usecases/progress/get_progress_usecase.dart';

part 'progress_event.dart';
part 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetProgressUseCase getProgressUseCase;

  ProgressBloc({required this.getProgressUseCase}) : super(ProgressInitial()) {
    on<LoadProgressEvent>(_onLoadProgress);
    on<RefreshProgressEvent>(_onRefreshProgress);
  }

  Future<void> _onLoadProgress(
    LoadProgressEvent event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());

    final result = await getProgressUseCase();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(ProgressLoaded(progress)),
    );
  }

  Future<void> _onRefreshProgress(
    RefreshProgressEvent event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await getProgressUseCase();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(ProgressLoaded(progress)),
    );
  }
}
