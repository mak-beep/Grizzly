import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'persistence_service.dart';

enum BackendLinkResult {
  linked,
  failed,

  /// Another family's project is already initialised in this app session and
  /// cannot be swapped without restarting the app.
  restartRequired,
}

/// Wraps authentication so the rest of the app never talks to Firebase
/// directly. Each family links their OWN Firebase project during onboarding.
///
///  - **Linked**: real `firebase_auth` email/password accounts on that
///    family's project.
///  - **Demo mode** (no project linked): a local mock so the app can be
///    reviewed without a Firebase project.
class AuthService {
  FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;

  bool _isSignedIn = false;
  String? _currentUserId;
  String? _currentEmail;

  bool get isSignedIn => _isSignedIn;
  String? get currentUserId => _currentUserId;
  String? get currentEmail => _currentEmail;

  bool get isLinkedToFirebase => _firebaseAuth != null;
  FirebaseFirestore? get firestore => _firestore;

  /// Initialises the family's Firebase project from the values entered on
  /// the "Connect your backend" screen (a runtime project, not one compiled
  /// into the app).
  Future<BackendLinkResult> linkFamilyFirebaseProject({
    required String projectId,
    required String apiKey,
    required String appId,
    required String messagingSenderId,
  }) async {
    if (projectId.isEmpty || apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty) {
      return BackendLinkResult.failed;
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        final current = Firebase.app().options;
        final sameProject = current.projectId == projectId &&
            current.apiKey == apiKey &&
            current.appId == appId;
        if (!sameProject) {
          // Never keep talking to a previously linked family's project.
          try {
            await Firebase.app().delete();
          } catch (e) {
            debugPrint('Could not release the previous Firebase project: $e');
            return BackendLinkResult.restartRequired;
          }
        }
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
          ),
        );
      }

      _firebaseAuth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      await PersistenceService.instance.saveBackendConfig(
        projectId: projectId,
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
      );
      return BackendLinkResult.linked;
    } catch (e, st) {
      debugPrint('Firebase link failed: $e\n$st');
      _firebaseAuth = null;
      _firestore = null;
      return BackendLinkResult.failed;
    }
  }

  /// Re-links the saved family project on app launch. Must run before
  /// [restoreSession].
  Future<bool> relinkSavedBackendIfAny() async {
    final saved = await PersistenceService.instance.loadBackendConfig();
    if (saved == null) return false;
    final result = await linkFamilyFirebaseProject(
      projectId: saved.projectId,
      apiKey: saved.apiKey,
      appId: saved.appId,
      messagingSenderId: saved.messagingSenderId,
    );
    return result == BackendLinkResult.linked;
  }

  Future<String> signUp({required String email, required String password}) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      final credential =
          await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return _setSession(credential.user!.uid, credential.user!.email ?? email.trim());
    }
    return _mockSignIn(email);
  }

  Future<String> signIn({required String email, required String password}) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      final credential =
          await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return _setSession(credential.user!.uid, credential.user!.email ?? email.trim());
    }
    return _mockSignIn(email);
  }

  Future<String> _setSession(String uid, String email) async {
    _isSignedIn = true;
    _currentUserId = uid;
    _currentEmail = email;
    await PersistenceService.instance.saveAuthSession(userId: uid, email: email);
    return uid;
  }

  Future<String> _mockSignIn(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _setSession('demo-user-${email.trim().toLowerCase().hashCode}', email.trim());
  }

  /// Restores a cached session on launch. Real Firebase sessions are
  /// validated against `FirebaseAuth.currentUser`.
  Future<bool> restoreSession() async {
    final cached = await PersistenceService.instance.loadAuthSession();
    if (cached == null) return false;

    final auth = _firebaseAuth;
    if (auth != null) {
      final user = auth.currentUser;
      if (user == null) return false;
      _isSignedIn = true;
      _currentUserId = user.uid;
      _currentEmail = user.email ?? cached.email;
      return true;
    }

    _isSignedIn = true;
    _currentUserId = cached.userId;
    _currentEmail = cached.email;
    return true;
  }

  /// Signs this user out. The family project stays linked on this phone so
  /// another member of the same family can sign in.
  Future<void> signOut() async {
    await _firebaseAuth?.signOut();
    _isSignedIn = false;
    _currentUserId = null;
    _currentEmail = null;
    await PersistenceService.instance.clearAllForSignOut();
  }

  /// Disconnects this phone from the family's Firebase project entirely.
  Future<void> unlinkBackend() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await Firebase.app().delete();
      }
    } catch (e) {
      debugPrint('Firebase app could not be released until restart: $e');
    }
    _firebaseAuth = null;
    _firestore = null;
    await PersistenceService.instance.clearBackendConfig();
  }
}
