part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final ProgressRecord? progress;
  final List<InterviewSession> recentSessions;
  final UserProfile? userProfile;
  final String greeting;

  const HomeLoaded({
    this.progress,
    this.recentSessions = const [],
    this.userProfile,
    required this.greeting,
  });

  @override
  List<Object?> get props => [progress, recentSessions, userProfile, greeting];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
