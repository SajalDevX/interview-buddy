import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/settings/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(LoadSettingsEvent()),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is CacheCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cache cleared successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            return _buildSettings(context, state);
          }

          return const Center(child: Text('Loading settings...'));
        },
      ),
    );
  }

  Widget _buildSettings(BuildContext context, SettingsLoaded state) {
    final theme = Theme.of(context);
    final settings = state.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Provider Selection
          _buildSectionHeader(context, 'AI Provider', Icons.smart_toy),
          const SizedBox(height: 8),
          _buildAIProviderCard(context, state),
          const SizedBox(height: 24),

          // API Configuration
          _buildSectionHeader(context, 'API Configuration', Icons.key),
          const SizedBox(height: 8),
          _buildApiKeyCard(context, state),
          const SizedBox(height: 24),

          // Voice Settings
          _buildSectionHeader(context, 'Voice Settings', Icons.record_voice_over),
          const SizedBox(height: 8),
          _buildVoiceSettings(context, state),
          const SizedBox(height: 24),

          // Appearance
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          const SizedBox(height: 8),
          _buildAppearanceSettings(context, state),
          const SizedBox(height: 24),

          // Audio
          _buildSectionHeader(context, 'Audio', Icons.volume_up),
          const SizedBox(height: 8),
          _buildAudioSettings(context, state),
          const SizedBox(height: 24),

          // Storage
          _buildSectionHeader(context, 'Storage', Icons.storage),
          const SizedBox(height: 8),
          _buildStorageSettings(context),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader(context, 'About', Icons.info),
          const SizedBox(height: 8),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAIProviderCard(BuildContext context, SettingsLoaded state) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select AI Model',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose which AI provider to use for interviews',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            ...AIProvider.values.map((provider) => RadioListTile<AIProvider>(
              title: Text(provider.displayName),
              subtitle: Text(provider.description),
              value: provider,
              groupValue: state.settings.aiProvider,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateAIProviderEvent(value));
                }
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyCard(BuildContext context, SettingsLoaded state) {
    final hasGroqKey = state.apiKey != null && state.apiKey!.isNotEmpty;
    final hasGeminiKey = state.geminiApiKey != null && state.geminiApiKey!.isNotEmpty;
    final selectedProvider = state.settings.aiProvider;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gemini API Key
            _buildApiKeyRow(
              context,
              title: 'Gemini API Key',
              isConfigured: hasGeminiKey,
              isActive: selectedProvider == AIProvider.gemini,
              onTap: () => _showGeminiApiKeyDialog(context, state.geminiApiKey),
            ),
            const Divider(height: 24),
            // Groq API Key
            _buildApiKeyRow(
              context,
              title: 'Groq API Key',
              isConfigured: hasGroqKey,
              isActive: selectedProvider == AIProvider.groq,
              onTap: () => _showApiKeyDialog(context, state.apiKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyRow(
    BuildContext context, {
    required String title,
    required bool isConfigured,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConfigured
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isConfigured ? 'Configured' : 'Not Set',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isConfigured ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(isConfigured ? Icons.edit : Icons.add),
            label: Text(isConfigured ? 'Update' : 'Add API Key'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSettings(BuildContext context, SettingsLoaded state) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            title: const Text('TTS Voice'),
            subtitle: Text(_getVoiceName(state.settings.selectedVoice)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showVoiceSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context, SettingsLoaded state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            secondary: Icon(
              state.settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            value: state.settings.isDarkMode,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleDarkModeEvent(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSettings(BuildContext context, SettingsLoaded state) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto-play Audio'),
            subtitle: const Text('Automatically play AI responses'),
            secondary: const Icon(Icons.play_circle_outline, color: AppColors.primary),
            value: state.settings.autoPlayAudio,
            onChanged: (value) {
              // Would update autoPlayAudio setting
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.speed, color: AppColors.primary),
            title: const Text('Playback Speed'),
            subtitle: Slider(
              value: state.settings.playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${state.settings.playbackSpeed}x',
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateSpeechSpeedEvent(value));
              },
            ),
            trailing: Text(
              '${state.settings.playbackSpeed}x',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSettings(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove cached data'),
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.accent),
            title: const Text('Reset Settings'),
            subtitle: const Text('Restore default settings'),
            onTap: () => _showResetSettingsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('Version'),
            trailing: Text(
              '1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {
              // Open privacy policy
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: AppColors.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {
              // Open terms of service
            },
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, String? currentKey) {
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Groq API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Groq API key. You can get one from console.groq.com',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'gsk_...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(
                UpdateApiKeyEvent(controller.text),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGeminiApiKeyDialog(BuildContext context, String? currentKey) {
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Gemini API key. You can get one from aistudio.google.com',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIza...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(
                UpdateGeminiApiKeyEvent(controller.text),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showVoiceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Voice',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...TTSVoice.values.map((voice) => ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: Text(_getVoiceDisplayName(voice)),
              subtitle: Text(_getVoiceDescription(voice)),
              onTap: () {
                context.read<SettingsBloc>().add(UpdateTTSVoiceEvent(voice));
                Navigator.pop(sheetContext);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached data including interview history. Your settings will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(ClearCacheEvent());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will restore all settings to their default values. Your API key will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(ResetSettingsEvent());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _getVoiceName(String voiceId) {
    final voice = TTSVoice.values.firstWhere(
      (v) => v.name == voiceId,
      orElse: () => TTSVoice.fritz,
    );
    return _getVoiceDisplayName(voice);
  }

  String _getVoiceDisplayName(TTSVoice voice) {
    return voice.displayName;
  }

  String _getVoiceDescription(TTSVoice voice) {
    return voice.description;
  }
}
