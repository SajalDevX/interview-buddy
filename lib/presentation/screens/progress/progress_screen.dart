import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/progress/progress_bloc.dart';
import '../../widgets/common/stat_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgressBloc>()..add(LoadProgressEvent()),
      child: const ProgressView(),
    );
  }
}

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProgressBloc>().add(RefreshProgressEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProgressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProgressBloc>().add(LoadProgressEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProgressLoaded) {
            return _buildProgressContent(context, state);
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 80,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Progress Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some interview sessions to see your progress here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressContent(BuildContext context, ProgressLoaded state) {
    final progress = state.progress;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProgressBloc>().add(RefreshProgressEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats
            _buildOverallStats(context, progress),
            const SizedBox(height: 24),

            // Skill Level Card
            _buildSkillLevelCard(context, progress),
            const SizedBox(height: 24),

            // Category Breakdown
            Text(
              'Performance by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryBreakdown(context, progress),
            const SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAchievements(context, progress),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Weekly Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeeklyActivity(context, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, dynamic progress) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Sessions',
            value: '${progress.totalSessions}',
            icon: Icons.mic,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Questions',
            value: '${progress.totalQuestions}',
            icon: Icons.question_answer,
            iconColor: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillLevelCard(BuildContext context, dynamic progress) {
    final theme = Theme.of(context);
    final skillLevel = progress.skillLevel as SkillLevel;
    final levelInfo = _getSkillLevelInfo(skillLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelInfo['color'] as Color, (levelInfo['color'] as Color).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (levelInfo['color'] as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill Level',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelInfo['title'] as String,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  levelInfo['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress to next level
          Text(
            'Progress to ${levelInfo['next']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.levelProgress ?? 0.5,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${((progress.levelProgress ?? 0.5) * 100).toInt()}% complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, dynamic progress) {
    final categories = [
      {'category': QuestionCategory.behavioral, 'score': 0.75},
      {'category': QuestionCategory.technical, 'score': 0.68},
      {'category': QuestionCategory.situational, 'score': 0.82},
      {'category': QuestionCategory.caseStudy, 'score': 0.71},
      {'category': QuestionCategory.cultureFit, 'score': 0.85},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: categories.map((data) {
          final category = data['category'] as QuestionCategory;
          final score = data['score'] as double;
          return _buildCategoryRow(context, category, score);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    QuestionCategory category,
    double score,
  ) {
    final theme = Theme.of(context);
    final label = _getCategoryLabel(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(score * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score,
            backgroundColor: _getScoreColor(score).withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, dynamic progress) {
    final achievements = [
      {'icon': Icons.star, 'title': 'First Interview', 'unlocked': true},
      {'icon': Icons.local_fire_department, 'title': '7-Day Streak', 'unlocked': true},
      {'icon': Icons.trending_up, 'title': 'Score 8+', 'unlocked': false},
      {'icon': Icons.emoji_events, 'title': '10 Sessions', 'unlocked': false},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _AchievementCard(
            icon: achievement['icon'] as IconData,
            title: achievement['title'] as String,
            unlocked: achievement['unlocked'] as bool,
          );
        },
      ),
    );
  }

  Widget _buildWeeklyActivity(BuildContext context, dynamic progress) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activity = [2, 0, 3, 1, 4, 0, 2]; // Mock data

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          return Column(
            children: [
              Container(
                width: 32,
                height: 60,
                decoration: BoxDecoration(
                  color: activity[index] > 0
                      ? AppColors.primary.withOpacity(0.2 + (activity[index] * 0.2))
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${activity[index]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: activity[index] > 0
                          ? AppColors.primary
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isToday ? FontWeight.bold : null,
                  color: isToday
                      ? AppColors.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getCategoryLabel(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.behavioral:
        return 'Behavioral';
      case QuestionCategory.technical:
        return 'Technical';
      case QuestionCategory.situational:
        return 'Situational';
      case QuestionCategory.caseStudy:
        return 'Case Study';
      case QuestionCategory.cultureFit:
        return 'Culture Fit';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.accent;
    if (score >= 0.4) return AppColors.primary;
    return AppColors.error;
  }

  Map<String, dynamic> _getSkillLevelInfo(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return {
          'title': 'Beginner',
          'icon': Icons.emoji_nature,
          'color': AppColors.accent,
          'next': 'Intermediate',
        };
      case SkillLevel.intermediate:
        return {
          'title': 'Intermediate',
          'icon': Icons.trending_up,
          'color': AppColors.primary,
          'next': 'Advanced',
        };
      case SkillLevel.advanced:
        return {
          'title': 'Advanced',
          'icon': Icons.star,
          'color': AppColors.secondary,
          'next': 'Expert',
        };
      case SkillLevel.expert:
        return {
          'title': 'Expert',
          'icon': Icons.emoji_events,
          'color': AppColors.success,
          'next': 'Master',
        };
      case SkillLevel.developing:
        return {
          'title': 'Developing',
          'icon': Icons.auto_stories,
          'color': Colors.orange,
          'next': 'Intermediate',
        };
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool unlocked;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.accent.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? AppColors.accent.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: unlocked
                ? AppColors.accent
                : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: unlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          if (!unlocked)
            Icon(
              Icons.lock,
              size: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
        ],
      ),
    );
  }
}
