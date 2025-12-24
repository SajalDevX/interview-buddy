import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/home/home_bloc.dart';
import '../../router/app_router.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(LoadHomeDataEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Interview Buddy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push(AppRouter.settings),
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Welcome Section
                      _buildWelcomeSection(context, state),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(context),
                      const SizedBox(height: 24),

                      // Stats Section
                      if (state is HomeLoaded) ...[
                        _buildStatsSection(context, state),
                        const SizedBox(height: 24),
                      ],

                      // Interview Types
                      _buildInterviewTypesSection(context),
                      const SizedBox(height: 24),

                      // Recent Activity
                      if (state is HomeLoaded && state.recentSessions.isNotEmpty)
                        _buildRecentActivitySection(context, state),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, HomeState state) {
    final theme = Theme.of(context);
    String greeting = _getGreeting();
    String name = 'there';

    if (state is HomeLoaded && state.userProfile != null) {
      name = state.userProfile!.name.split(' ').first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to ace your next interview?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRouter.interviewSetup),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded),
                  SizedBox(width: 8),
                  Text(
                    'Start Practice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.description_outlined,
            title: 'Resume',
            subtitle: 'Upload & Parse',
            color: AppColors.accent,
            onTap: () => context.push(AppRouter.resume),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.trending_up,
            title: 'Progress',
            subtitle: 'Track Growth',
            color: AppColors.success,
            onTap: () => context.push(AppRouter.progress),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, HomeLoaded state) {
    final theme = Theme.of(context);
    final progress = state.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Sessions',
                value: progress?.totalSessions.toString() ?? '0',
                icon: Icons.mic,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Avg Score',
                value: progress != null
                    ? '${(progress.overallAverage * 10).toStringAsFixed(1)}'
                    : '-',
                icon: Icons.star,
                iconColor: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Streak',
                value: '${progress?.currentStreak ?? 0} days',
                icon: Icons.local_fire_department,
                iconColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Questions',
                value: progress?.totalQuestions.toString() ?? '0',
                icon: Icons.question_answer,
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterviewTypesSection(BuildContext context) {
    final theme = Theme.of(context);

    final interviewTypes = [
      _InterviewTypeData(
        type: InterviewType.quickPractice,
        title: 'Quick Practice',
        duration: '5-10 min',
        description: '3-5 questions',
        icon: Icons.flash_on,
        color: AppColors.accent,
      ),
      _InterviewTypeData(
        type: InterviewType.standard,
        title: 'Standard',
        duration: '20-30 min',
        description: '8-10 questions',
        icon: Icons.timer,
        color: AppColors.primary,
      ),
      _InterviewTypeData(
        type: InterviewType.deepDive,
        title: 'Deep Dive',
        duration: '45-60 min',
        description: 'Comprehensive',
        icon: Icons.psychology,
        color: AppColors.secondary,
      ),
      _InterviewTypeData(
        type: InterviewType.technical,
        title: 'Technical',
        duration: '30-45 min',
        description: 'Role-specific',
        icon: Icons.code,
        color: AppColors.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interview Types',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...interviewTypes.map((data) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _InterviewTypeCard(data: data),
        )),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, HomeLoaded state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRouter.progress),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...state.recentSessions.take(3).map((session) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                _getInterviewTypeIcon(session.type),
                color: AppColors.primary,
              ),
            ),
            title: Text(session.type.displayName),
            subtitle: Text(
              '${session.responses.length} questions answered',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(session.averageScore * 10).toStringAsFixed(1)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'score',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _getInterviewTypeIcon(InterviewType type) {
    switch (type) {
      case InterviewType.quickPractice:
        return Icons.flash_on;
      case InterviewType.standard:
        return Icons.timer;
      case InterviewType.deepDive:
        return Icons.psychology;
      case InterviewType.technical:
        return Icons.code;
      case InterviewType.finalRound:
        return Icons.emoji_events;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterviewTypeData {
  final InterviewType type;
  final String title;
  final String duration;
  final String description;
  final IconData icon;
  final Color color;

  const _InterviewTypeData({
    required this.type,
    required this.title,
    required this.duration,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _InterviewTypeCard extends StatelessWidget {
  final _InterviewTypeData data;

  const _InterviewTypeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push(
            AppRouter.interview,
            extra: {'interviewType': data.type},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.duration} - ${data.description}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
