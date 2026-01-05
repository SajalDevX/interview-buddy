import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/interview/interview_screen.dart';
import '../screens/interview/interview_setup_screen.dart';
import '../screens/resume/resume_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class AppRouter {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // App routes
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String interviewSetup = '/interview/setup';
  static const String interview = '/interview';
  static const String resume = '/resume';
  static const String progress = '/progress';
  static const String settings = '/settings';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final isAuthRoute = state.matchedLocation == login ||
            state.matchedLocation == signup ||
            state.matchedLocation == forgotPassword;

        // Still initializing, don't redirect yet
        if (authState is AuthInitial || authState is AuthLoading) {
          return null;
        }

        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isAuthRoute) {
          return login;
        }

        // If authenticated and on auth route, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return home;
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: signup,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Protected routes
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: interviewSetup,
          name: 'interviewSetup',
          builder: (context, state) => const InterviewSetupScreen(),
        ),
        GoRoute(
          path: interview,
          name: 'interview',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>?;
            return InterviewScreen(
              interviewType: extras?['interviewType'] as InterviewType? ??
                  InterviewType.quickPractice,
              questionCategory: extras?['questionCategory'] as QuestionCategory?,
              targetRole: extras?['targetRole'] as String?,
            );
          },
        ),
        GoRoute(
          path: resume,
          name: 'resume',
          builder: (context, state) => const ResumeScreen(),
        ),
        GoRoute(
          path: progress,
          name: 'progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(state.error?.message ?? 'Unknown error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Legacy static router for backward compatibility during migration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home_legacy',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding_legacy',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: interviewSetup,
        name: 'interviewSetup_legacy',
        builder: (context, state) => const InterviewSetupScreen(),
      ),
      GoRoute(
        path: interview,
        name: 'interview_legacy',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return InterviewScreen(
            interviewType: extras?['interviewType'] as InterviewType? ??
                InterviewType.quickPractice,
            questionCategory: extras?['questionCategory'] as QuestionCategory?,
            targetRole: extras?['targetRole'] as String?,
          );
        },
      ),
      GoRoute(
        path: resume,
        name: 'resume_legacy',
        builder: (context, state) => const ResumeScreen(),
      ),
      GoRoute(
        path: progress,
        name: 'progress_legacy',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings_legacy',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper class to convert BLoC Stream to Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
