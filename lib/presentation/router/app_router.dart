import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums.dart';
import '../screens/home/home_screen.dart';
import '../screens/interview/interview_screen.dart';
import '../screens/interview/interview_setup_screen.dart';
import '../screens/resume/resume_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String interviewSetup = '/interview/setup';
  static const String interview = '/interview';
  static const String resume = '/resume';
  static const String progress = '/progress';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
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
            interviewType: extras?['interviewType'] as InterviewType? ?? InterviewType.quickPractice,
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
