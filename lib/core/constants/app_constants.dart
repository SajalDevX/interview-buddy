class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Interview Buddy';
  static const String appVersion = '1.0.0';

  // Groq API
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';
  static const String groqTranscriptionEndpoint = '/audio/transcriptions';
  static const String groqSpeechEndpoint = '/audio/speech';

  // Models
  static const String primaryModel = 'llama-3.1-70b-versatile';
  static const String fastModel = 'llama-3.1-8b-instant';
  static const String whisperModel = 'whisper-large-v3-turbo';
  static const String ttsModel = 'playai-tts';

  // Gemini API
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.5-flash';

  // Audio Settings
  static const int sampleRate = 16000;
  static const int bitRate = 128000;
  static const int maxAudioFileSizeMB = 25;

  // Cache Settings
  static const int ttsCacheDays = 7;
  static const int questionCacheDays = 30;
  static const int maxCacheSizeMB = 500;
  static const int autoSaveIntervalSeconds = 30;

  // Interview Settings
  static const int quickPracticeQuestions = 1;
  static const int standardInterviewQuestions = 6;
  static const int deepDiveQuestions = 12;
  static const int technicalRoundQuestions = 8;
  static const int finalRoundQuestions = 15;

  // Scoring Weights
  static const double contentWeight = 0.40;
  static const double structureWeight = 0.25;
  static const double communicationWeight = 0.20;
  static const double confidenceWeight = 0.15;

  // Hive Box Names
  static const String userBox = 'userBox';
  static const String resumeBox = 'resumeBox';
  static const String interviewBox = 'interviewBox';
  static const String progressBox = 'progressBox';
  static const String cacheBox = 'cacheBox';
  static const String settingsBox = 'settingsBox';
}
