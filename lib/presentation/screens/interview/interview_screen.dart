import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/interview/interview_bloc.dart';
import '../../widgets/common/animated_mic_button.dart';
import '../../widgets/common/gradient_button.dart';

class InterviewScreen extends StatelessWidget {
  final InterviewType interviewType;
  final QuestionCategory? questionCategory;
  final String? targetRole;

  const InterviewScreen({
    super.key,
    required this.interviewType,
    this.questionCategory,
    this.targetRole,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InterviewBloc>()
        ..add(StartInterviewEvent(
          interviewType: interviewType,
          questionCategory: questionCategory,
          targetRole: targetRole,
        )),
      child: const InterviewView(),
    );
  }
}

class InterviewView extends StatefulWidget {
  const InterviewView({super.key});

  @override
  State<InterviewView> createState() => _InterviewViewState();
}

class _InterviewViewState extends State<InterviewView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: Scaffold(
        body: BlocConsumer<InterviewBloc, InterviewState>(
          listener: (context, state) {
            if (state is InterviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, state),

                  // Main Content
                  Expanded(
                    child: _buildMainContent(context, state),
                  ),

                  // Bottom Controls
                  _buildBottomControls(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InterviewState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interview Session',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state is InterviewInProgress)
                  Text(
                    'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (state is InterviewInProgress)
            _buildProgressIndicator(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(InterviewInProgress state) {
    final progress = (state.currentQuestionIndex + 1) / state.totalQuestions;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            strokeWidth: 4,
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, InterviewState state) {
    if (state is InterviewLoading) {
      return _buildLoadingState();
    }

    if (state is InterviewInProgress) {
      return _buildInterviewContent(context, state);
    }

    if (state is InterviewCompleted) {
      return _buildCompletedState(context, state);
    }

    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Preparing your interview...'),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text('Starting interview session...'),
    );
  }

  Widget _buildInterviewContent(BuildContext context, InterviewInProgress state) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getCategoryLabel(state.currentQuestion.category),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              state.currentQuestion.question,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Recording Status
            if (state.isRecording)
              _buildRecordingIndicator()
            else if (state.currentTranscript.isNotEmpty)
              _buildTranscript(context, state.currentTranscript),

            // AI Response
            if (state.aiResponse.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildAIResponse(context, state.aiResponse),
            ],

            // Feedback
            if (state.currentFeedback != null) ...[
              const SizedBox(height: 24),
              _buildFeedbackCard(context, state.currentFeedback!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Recording your answer...',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscript(BuildContext context, String transcript) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over,
                  size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'Your Answer',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            transcript,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAIResponse(BuildContext context, String response) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'AI Interviewer',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, Map<String, dynamic> feedback) {
    final theme = Theme.of(context);
    final score = feedback['overallScore'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Feedback',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(score * 10).toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (feedback['strengths'] != null) ...[
            _buildFeedbackSection(
              'Strengths',
              feedback['strengths'] as List<dynamic>,
              Icons.thumb_up,
              AppColors.success,
            ),
            const SizedBox(height: 8),
          ],
          if (feedback['improvements'] != null)
            _buildFeedbackSection(
              'Areas for Improvement',
              feedback['improvements'] as List<dynamic>,
              Icons.lightbulb,
              AppColors.accent,
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(
    String title,
    List<dynamic> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 22, top: 4),
          child: Text(
            '- $item',
            style: const TextStyle(fontSize: 13),
          ),
        )),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context, InterviewCompleted state) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Completion Badge
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.primary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Interview Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job completing this session',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Overall Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Overall Score',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.session.averageScore * 10).toStringAsFixed(1)}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(state.session.averageScore),
                  ),
                ),
                Text(
                  'out of 10',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Questions',
                  '${state.session.responses.length}',
                  Icons.question_answer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Duration',
                  _formatDuration(state.session.duration),
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    final theme = Theme.of(context);

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
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, InterviewState state) {
    if (state is InterviewCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: GradientButton(
          text: 'Finish',
          onPressed: () => context.pop(),
        ),
      );
    }

    if (state is InterviewInProgress) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Mic Button
            AnimatedMicButton(
              isRecording: state.isRecording,
              isProcessing: state.isProcessing,
              onPressed: () {
                if (state.isRecording) {
                  context.read<InterviewBloc>().add(StopRecordingEvent());
                } else {
                  context.read<InterviewBloc>().add(StartRecordingEvent());
                }
              },
            ),
            const SizedBox(height: 16),

            // Helper text
            Text(
              state.isRecording
                  ? 'Tap to stop recording'
                  : 'Tap the mic to answer',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            // Next Question Button
            if (state.currentFeedback != null &&
                state.currentQuestionIndex < state.totalQuestions - 1) ...[
              const SizedBox(height: 16),
              GradientButton(
                text: 'Next Question',
                onPressed: () {
                  context.read<InterviewBloc>().add(NextQuestionEvent());
                  _fadeController.reset();
                  _fadeController.forward();
                },
              ),
            ],

            // Complete Interview Button
            if (state.currentFeedback != null &&
                state.currentQuestionIndex >= state.totalQuestions - 1) ...[
              const SizedBox(height: 16),
              GradientButton(
                text: 'Complete Interview',
                onPressed: () {
                  context.read<InterviewBloc>().add(CompleteInterviewEvent());
                },
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Interview?'),
        content: const Text(
          'Your progress will not be saved. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.pop();
    }

    return false;
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
