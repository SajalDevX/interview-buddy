import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_theme.dart';
import 'core/di/injection.dart';
import 'presentation/router/app_router.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  await initializeDependencies();

  runApp(const InterviewBuddyApp());
}

class InterviewBuddyApp extends StatelessWidget {
  const InterviewBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettingsEvent()),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              final isDarkMode = settingsState is SettingsLoaded
                  ? settingsState.settings.isDarkMode
                  : false;

              final authBloc = context.read<AuthBloc>();
              final router = AppRouter.createRouter(authBloc);

              return MaterialApp.router(
                title: 'Interview Buddy',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
