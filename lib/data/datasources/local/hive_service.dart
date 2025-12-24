import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_profile_model.dart';
import '../../models/interview_session_model.dart';
import '../../models/resume_model.dart';
import '../../models/progress_model.dart';

class HiveService {
  late Box<UserProfileModel> _userBox;
  late Box<ParsedResumeModel> _resumeBox;
  late Box<InterviewSessionModel> _interviewBox;
  late Box<ProgressRecordModel> _progressBox;
  late Box<dynamic> _cacheBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(UserProfileModelAdapter());
    Hive.registerAdapter(UserSettingsModelAdapter());
    Hive.registerAdapter(InterviewSessionModelAdapter());
    Hive.registerAdapter(QuestionResponseModelAdapter());
    Hive.registerAdapter(ResponseScoreModelAdapter());
    Hive.registerAdapter(ParsedResumeModelAdapter());
    Hive.registerAdapter(EducationModelAdapter());
    Hive.registerAdapter(WorkExperienceModelAdapter());
    Hive.registerAdapter(ProjectModelAdapter());
    Hive.registerAdapter(ProgressRecordModelAdapter());

    // Open boxes
    _userBox = await Hive.openBox<UserProfileModel>(AppConstants.userBox);
    _resumeBox = await Hive.openBox<ParsedResumeModel>(AppConstants.resumeBox);
    _interviewBox = await Hive.openBox<InterviewSessionModel>(AppConstants.interviewBox);
    _progressBox = await Hive.openBox<ProgressRecordModel>(AppConstants.progressBox);
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // User Profile Operations
  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _userBox.put(profile.id, profile);
  }

  UserProfileModel? getUserProfile(String id) {
    return _userBox.get(id);
  }

  UserProfileModel? getCurrentUser() {
    return _userBox.values.isNotEmpty ? _userBox.values.first : null;
  }

  // Resume Operations
  Future<void> saveResume(ParsedResumeModel resume) async {
    await _resumeBox.put(resume.id, resume);
  }

  ParsedResumeModel? getResume(String id) {
    return _resumeBox.get(id);
  }

  List<ParsedResumeModel> getAllResumes() {
    return _resumeBox.values.toList();
  }

  ParsedResumeModel? getLatestResume() {
    if (_resumeBox.isEmpty) return null;
    final resumes = _resumeBox.values.toList();
    resumes.sort((a, b) => b.parsedAt.compareTo(a.parsedAt));
    return resumes.first;
  }

  Future<void> deleteResume(String id) async {
    await _resumeBox.delete(id);
  }

  // Interview Session Operations
  Future<void> saveInterviewSession(InterviewSessionModel session) async {
    await _interviewBox.put(session.id, session);
  }

  InterviewSessionModel? getInterviewSession(String id) {
    return _interviewBox.get(id);
  }

  List<InterviewSessionModel> getAllInterviewSessions() {
    final sessions = _interviewBox.values.toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  List<InterviewSessionModel> getRecentSessions({int limit = 10}) {
    final sessions = getAllInterviewSessions();
    return sessions.take(limit).toList();
  }

  Future<void> deleteInterviewSession(String id) async {
    await _interviewBox.delete(id);
  }

  // Progress Operations
  Future<void> saveProgress(ProgressRecordModel progress) async {
    await _progressBox.put(progress.id, progress);
  }

  ProgressRecordModel? getProgress(String id) {
    return _progressBox.get(id);
  }

  ProgressRecordModel? getLatestProgress() {
    if (_progressBox.isEmpty) return null;
    final records = _progressBox.values.toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records.first;
  }

  // Cache Operations
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await _cacheBox.put(key, cacheEntry);
  }

  dynamic getCachedData(String key) {
    final entry = _cacheBox.get(key);
    if (entry == null) return null;

    final ttl = entry['ttl'] as int?;
    if (ttl != null) {
      final timestamp = entry['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > ttl) {
        _cacheBox.delete(key);
        return null;
      }
    }
    return entry['data'];
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Settings Operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  String? getApiKey() {
    return _settingsBox.get('groq_api_key') as String?;
  }

  Future<void> saveApiKey(String apiKey) async {
    await _settingsBox.put('groq_api_key', apiKey);
  }

  // Cleanup
  Future<void> clearAllData() async {
    await _userBox.clear();
    await _resumeBox.clear();
    await _interviewBox.clear();
    await _progressBox.clear();
    await _cacheBox.clear();
    await _settingsBox.clear();
  }

  Future<void> close() async {
    await _userBox.close();
    await _resumeBox.close();
    await _interviewBox.close();
    await _progressBox.close();
    await _cacheBox.close();
    await _settingsBox.close();
  }
}
