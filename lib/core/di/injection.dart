import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../utils/permission_handler.dart';
import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/remote/groq_api_service.dart';
import '../../data/datasources/remote/gemini_api_service.dart';
import '../../data/datasources/remote/firebase_auth_service.dart';
import '../../data/datasources/remote/firestore_service.dart';
import '../../data/repositories/interview_repository_impl.dart';
import '../../data/repositories/resume_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/interview_repository.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/interview/start_interview_usecase.dart';
import '../../domain/usecases/interview/submit_answer_usecase.dart';
import '../../domain/usecases/interview/get_feedback_usecase.dart';
import '../../domain/usecases/resume/parse_resume_usecase.dart';
import '../../domain/usecases/resume/save_resume_usecase.dart';
import '../../domain/usecases/progress/get_progress_usecase.dart';
import '../../domain/usecases/progress/update_progress_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_email_usecase.dart';
import '../../domain/usecases/auth/sign_up_with_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../presentation/blocs/interview/interview_bloc.dart';
import '../../presentation/blocs/resume/resume_bloc.dart';
import '../../presentation/blocs/progress/progress_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<AppPermissionHandler>(() => AppPermissionHandler());

  // Services
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<GroqApiService>(
    () => GroqApiService(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<GeminiApiService>(
    () => GeminiApiService(),
  );

  // Firebase Services
  getIt.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());

  // Initialize Hive Service
  await getIt<HiveService>().init();

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      hiveService: getIt<HiveService>(),
    ),
  );

  getIt.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(
      groqApiService: getIt<GroqApiService>(),
      geminiApiService: getIt<GeminiApiService>(),
      hiveService: getIt<HiveService>(),
      connectivity: getIt<Connectivity>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  getIt.registerLazySingleton<ResumeRepository>(
    () => ResumeRepositoryImpl(
      hiveService: getIt<HiveService>(),
    ),
  );

  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(
      hiveService: getIt<HiveService>(),
    ),
  );

  // Use Cases - Interview
  getIt.registerLazySingleton<StartInterviewUseCase>(
    () => StartInterviewUseCase(repository: getIt<InterviewRepository>()),
  );
  getIt.registerLazySingleton<SubmitAnswerUseCase>(
    () => SubmitAnswerUseCase(repository: getIt<InterviewRepository>()),
  );
  getIt.registerLazySingleton<GetFeedbackUseCase>(
    () => GetFeedbackUseCase(repository: getIt<InterviewRepository>()),
  );

  // Use Cases - Resume
  getIt.registerLazySingleton<ParseResumeUseCase>(
    () => ParseResumeUseCase(repository: getIt<ResumeRepository>()),
  );
  getIt.registerLazySingleton<SaveResumeUseCase>(
    () => SaveResumeUseCase(repository: getIt<ResumeRepository>()),
  );

  // Use Cases - Progress
  getIt.registerLazySingleton<GetProgressUseCase>(
    () => GetProgressUseCase(repository: getIt<ProgressRepository>()),
  );
  getIt.registerLazySingleton<UpdateProgressUseCase>(
    () => UpdateProgressUseCase(repository: getIt<ProgressRepository>()),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton<SignInWithEmailUseCase>(
    () => SignInWithEmailUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SendPasswordResetUseCase>(
    () => SendPasswordResetUseCase(repository: getIt<AuthRepository>()),
  );

  // BLoCs
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getProgressUseCase: getIt<GetProgressUseCase>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  getIt.registerFactory<InterviewBloc>(
    () => InterviewBloc(
      startInterviewUseCase: getIt<StartInterviewUseCase>(),
      submitAnswerUseCase: getIt<SubmitAnswerUseCase>(),
      getFeedbackUseCase: getIt<GetFeedbackUseCase>(),
      updateProgressUseCase: getIt<UpdateProgressUseCase>(),
      groqApiService: getIt<GroqApiService>(),
      geminiApiService: getIt<GeminiApiService>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  getIt.registerFactory<ResumeBloc>(
    () => ResumeBloc(
      parseResumeUseCase: getIt<ParseResumeUseCase>(),
      saveResumeUseCase: getIt<SaveResumeUseCase>(),
    ),
  );

  getIt.registerFactory<ProgressBloc>(
    () => ProgressBloc(
      getProgressUseCase: getIt<GetProgressUseCase>(),
    ),
  );

  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
