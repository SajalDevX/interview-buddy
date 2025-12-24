import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/progress_record.dart';
import '../../../domain/entities/interview_session.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/usecases/progress/get_progress_usecase.dart';
import '../../../domain/repositories/settings_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProgressUseCase getProgressUseCase;
  final SettingsRepository settingsRepository;

  HomeBloc({
    required this.getProgressUseCase,
    required this.settingsRepository,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeEvent>(_onRefreshHome);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final progressResult = await getProgressUseCase();

    progressResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (progress) => emit(HomeLoaded(
        progress: progress,
        recentSessions: const [],
        greeting: _getGreeting(),
      )),
    );
  }

  Future<void> _onRefreshHome(
    RefreshHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    final progressResult = await getProgressUseCase();

    progressResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (progress) => emit(HomeLoaded(
        progress: progress,
        recentSessions: const [],
        greeting: _getGreeting(),
      )),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
