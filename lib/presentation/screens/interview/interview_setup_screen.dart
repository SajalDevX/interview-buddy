import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/enums.dart';
import '../../router/app_router.dart';
import '../../widgets/common/gradient_button.dart';

class InterviewSetupScreen extends StatefulWidget {
  const InterviewSetupScreen({super.key});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  InterviewType _selectedType = InterviewType.quickPractice;
  QuestionCategory? _selectedCategory;
  final TextEditingController _targetRoleController = TextEditingController();

  @override
  void dispose() {
    _targetRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Interview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interview Type Selection
            Text(
              'Interview Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...InterviewType.values.map((type) => _InterviewTypeOption(
              type: type,
              isSelected: _selectedType == type,
              onTap: () => setState(() => _selectedType = type),
            )),

            const SizedBox(height: 24),

            // Question Category (optional)
            Text(
              'Question Category (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Focus on a specific area or leave empty for mixed questions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(
                  label: 'All Categories',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...QuestionCategory.values.map((category) => _CategoryChip(
                  label: _getCategoryLabel(category),
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                )),
              ],
            ),

            const SizedBox(height: 24),

            // Target Role
            Text(
              'Target Role (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get more relevant questions for your target position',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetRoleController,
              decoration: InputDecoration(
                hintText: 'e.g., Senior Software Engineer',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),

            const SizedBox(height: 32),

            // Interview Info
            _buildInterviewInfo(),

            const SizedBox(height: 32),

            // Start Button
            GradientButton(
              text: 'Start Interview',
              icon: Icons.mic,
              onPressed: _startInterview,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewInfo() {
    final theme = Theme.of(context);
    final info = _getInterviewInfo(_selectedType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Interview Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: info['duration']!,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.question_answer_outlined,
            label: 'Questions',
            value: info['questions']!,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.psychology_outlined,
            label: 'Focus',
            value: info['focus']!,
          ),
        ],
      ),
    );
  }

  Map<String, String> _getInterviewInfo(InterviewType type) {
    switch (type) {
      case InterviewType.quickPractice:
        return {
          'duration': '5-10 minutes',
          'questions': '3-5 questions',
          'focus': 'Quick warm-up & confidence building',
        };
      case InterviewType.standard:
        return {
          'duration': '20-30 minutes',
          'questions': '8-10 questions',
          'focus': 'Balanced mix of question types',
        };
      case InterviewType.deepDive:
        return {
          'duration': '45-60 minutes',
          'questions': '12-15 questions',
          'focus': 'Comprehensive evaluation with follow-ups',
        };
      case InterviewType.technical:
        return {
          'duration': '30-45 minutes',
          'questions': '8-12 questions',
          'focus': 'Role-specific technical questions',
        };
      case InterviewType.finalRound:
        return {
          'duration': '45-60 minutes',
          'questions': '10-12 questions',
          'focus': 'Executive-level & culture fit',
        };
    }
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

  void _startInterview() {
    context.push(
      AppRouter.interview,
      extra: {
        'interviewType': _selectedType,
        'questionCategory': _selectedCategory,
        'targetRole': _targetRoleController.text.isNotEmpty
            ? _targetRoleController.text
            : null,
      },
    );
  }
}

class _InterviewTypeOption extends StatelessWidget {
  final InterviewType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterviewTypeOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _getTypeInfo(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: info['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(info['icon'], color: info['color']),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['title'],
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info['subtitle'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeInfo(InterviewType type) {
    switch (type) {
      case InterviewType.quickPractice:
        return {
          'title': 'Quick Practice',
          'subtitle': '5-10 min | 3-5 questions',
          'icon': Icons.flash_on,
          'color': AppColors.accent,
        };
      case InterviewType.standard:
        return {
          'title': 'Standard Interview',
          'subtitle': '20-30 min | 8-10 questions',
          'icon': Icons.timer,
          'color': AppColors.primary,
        };
      case InterviewType.deepDive:
        return {
          'title': 'Deep Dive',
          'subtitle': '45-60 min | Comprehensive',
          'icon': Icons.psychology,
          'color': AppColors.secondary,
        };
      case InterviewType.technical:
        return {
          'title': 'Technical Interview',
          'subtitle': '30-45 min | Role-specific',
          'icon': Icons.code,
          'color': AppColors.success,
        };
      case InterviewType.finalRound:
        return {
          'title': 'Final Round',
          'subtitle': '45-60 min | Executive-level',
          'icon': Icons.emoji_events,
          'color': AppColors.error,
        };
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
