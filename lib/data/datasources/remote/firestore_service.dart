import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> _usersCollection() =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersCollection().doc(uid);

  CollectionReference<Map<String, dynamic>> _settingsCollection(String uid) =>
      _userDoc(uid).collection('settings');

  CollectionReference<Map<String, dynamic>> _progressCollection(String uid) =>
      _userDoc(uid).collection('progress');

  CollectionReference<Map<String, dynamic>> _interviewsCollection(String uid) =>
      _userDoc(uid).collection('interviews');

  CollectionReference<Map<String, dynamic>> _resumesCollection(String uid) =>
      _userDoc(uid).collection('resumes');

  // ==================== User Profile Operations ====================

  /// Create or update user profile
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data();
  }

  /// Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.exists;
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _userDoc(uid).update(data);
  }

  // ==================== Settings Operations ====================

  /// Save user settings
  Future<void> saveSettings(String uid, Map<String, dynamic> settings) async {
    await _settingsCollection(uid).doc('user_settings').set(settings);
  }

  /// Get user settings
  Future<Map<String, dynamic>?> getSettings(String uid) async {
    final doc = await _settingsCollection(uid).doc('user_settings').get();
    return doc.data();
  }

  /// Update user settings
  Future<void> updateSettings(
      String uid, Map<String, dynamic> settings) async {
    await _settingsCollection(uid)
        .doc('user_settings')
        .set(settings, SetOptions(merge: true));
  }

  // ==================== Progress Operations ====================

  /// Save progress record
  Future<void> saveProgress(
      String uid, String progressId, Map<String, dynamic> data) async {
    await _progressCollection(uid).doc(progressId).set(data);
  }

  /// Get latest progress record
  Future<Map<String, dynamic>?> getLatestProgress(String uid) async {
    final query = await _progressCollection(uid)
        .orderBy('lastUpdated', descending: true)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }

  /// Get progress by ID
  Future<Map<String, dynamic>?> getProgress(String uid, String progressId) async {
    final doc = await _progressCollection(uid).doc(progressId).get();
    return doc.data();
  }

  /// Update progress record
  Future<void> updateProgress(
      String uid, String progressId, Map<String, dynamic> data) async {
    await _progressCollection(uid)
        .doc(progressId)
        .set(data, SetOptions(merge: true));
  }

  // ==================== Interview Session Operations ====================

  /// Save interview session
  Future<void> saveInterviewSession(
      String uid, String sessionId, Map<String, dynamic> data) async {
    await _interviewsCollection(uid).doc(sessionId).set(data);
  }

  /// Get interview session by ID
  Future<Map<String, dynamic>?> getInterviewSession(
      String uid, String sessionId) async {
    final doc = await _interviewsCollection(uid).doc(sessionId).get();
    return doc.data();
  }

  /// Get all interview sessions
  Future<List<Map<String, dynamic>>> getAllInterviewSessions(String uid) async {
    final query = await _interviewsCollection(uid)
        .orderBy('startedAt', descending: true)
        .get();
    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get recent interview sessions
  Future<List<Map<String, dynamic>>> getRecentInterviewSessions(String uid,
      {int limit = 10}) async {
    final query = await _interviewsCollection(uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();
    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Update interview session
  Future<void> updateInterviewSession(
      String uid, String sessionId, Map<String, dynamic> data) async {
    await _interviewsCollection(uid)
        .doc(sessionId)
        .set(data, SetOptions(merge: true));
  }

  /// Delete interview session
  Future<void> deleteInterviewSession(String uid, String sessionId) async {
    await _interviewsCollection(uid).doc(sessionId).delete();
  }

  // ==================== Resume Operations ====================

  /// Save resume
  Future<void> saveResume(
      String uid, String resumeId, Map<String, dynamic> data) async {
    await _resumesCollection(uid).doc(resumeId).set(data);
  }

  /// Get resume by ID
  Future<Map<String, dynamic>?> getResume(String uid, String resumeId) async {
    final doc = await _resumesCollection(uid).doc(resumeId).get();
    return doc.data();
  }

  /// Get all resumes
  Future<List<Map<String, dynamic>>> getAllResumes(String uid) async {
    final query = await _resumesCollection(uid)
        .orderBy('parsedAt', descending: true)
        .get();
    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get latest resume
  Future<Map<String, dynamic>?> getLatestResume(String uid) async {
    final query = await _resumesCollection(uid)
        .orderBy('parsedAt', descending: true)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }

  /// Update resume
  Future<void> updateResume(
      String uid, String resumeId, Map<String, dynamic> data) async {
    await _resumesCollection(uid)
        .doc(resumeId)
        .set(data, SetOptions(merge: true));
  }

  /// Delete resume
  Future<void> deleteResume(String uid, String resumeId) async {
    await _resumesCollection(uid).doc(resumeId).delete();
  }

  // ==================== Cleanup Operations ====================

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String uid) async {
    // Delete interviews subcollection
    final interviews = await _interviewsCollection(uid).get();
    for (final doc in interviews.docs) {
      await doc.reference.delete();
    }

    // Delete resumes subcollection
    final resumes = await _resumesCollection(uid).get();
    for (final doc in resumes.docs) {
      await doc.reference.delete();
    }

    // Delete progress subcollection
    final progress = await _progressCollection(uid).get();
    for (final doc in progress.docs) {
      await doc.reference.delete();
    }

    // Delete settings subcollection
    final settings = await _settingsCollection(uid).get();
    for (final doc in settings.docs) {
      await doc.reference.delete();
    }

    // Delete user document
    await _userDoc(uid).delete();
  }
}
