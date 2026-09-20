import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'localization/app_localizations.dart';
import 'models/device.dart';
import 'models/user_profile.dart';
import 'services/alert_monitor.dart';
import 'services/auth_service.dart';
import 'services/device_repository.dart';
import 'services/family_service.dart';
import 'services/notification_service.dart';
import 'services/persistence_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Rebuilds every watcher whenever the repository notifies — local changes,
/// firmware updates arriving from Firestore, or another member's edits.
final deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>((ref) => DeviceRepository());

class AuthState {
  final bool isSignedIn;
  final String? userId;
  final String? email;

  const AuthState({this.isSignedIn = false, this.userId, this.email});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(const AuthState());

  Future<void> signUp({required String email, required String password}) async {
    final id = await _service.signUp(email: email, password: password);
    state = AuthState(isSignedIn: true, userId: id, email: _service.currentEmail);
  }

  Future<void> signIn({required String email, required String password}) async {
    final id = await _service.signIn(email: email, password: password);
    state = AuthState(isSignedIn: true, userId: id, email: _service.currentEmail);
  }

  Future<void> restoreSession() async {
    if (await _service.restoreSession()) {
      state = AuthState(
        isSignedIn: true,
        userId: _service.currentUserId,
        email: _service.currentEmail,
      );
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

/// The linked family project id, or null in Demo mode.
final backendModeProvider = StateProvider<String?>((ref) => null);

/// Membership helpers for the linked family project (null in Demo mode).
final familyServiceProvider = Provider<FamilyService?>((ref) {
  if (ref.watch(backendModeProvider) == null) return null;
  final db = ref.watch(authServiceProvider).firestore;
  return db == null ? null : FamilyService(db);
});

final devicesProvider = Provider<List<Device>>((ref) {
  return ref.watch(deviceRepositoryProvider).allDevices;
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  /// Which user's slot to persist to — null before sign-up/sign-in.
  String? _userId;

  void createProfile({
    required String firstName,
    required String lastName,
    required int age,
  }) {
    state = UserProfile(firstName: firstName, lastName: lastName, age: age);
    _persist();
  }

  void bindToUser(String userId) {
    _userId = userId;
  }

  void unbindUser() {
    _userId = null;
  }

  void restoreFrom(UserProfile profile) {
    state = profile;
  }

  void acceptPrivacyConsent() => _update((p) => p.copyWith(hasAcceptedPrivacyConsent: true));

  void setLanguage(String code) => _update((p) => p.copyWith(languageCode: code));

  void setDarkTheme(bool value) => _update((p) => p.copyWith(isDarkTheme: value));

  void setAlertStyle(AlertStyle style) => _update((p) => p.copyWith(alertStyle: style));

  void setBackgroundMonitoring(bool value) =>
      _update((p) => p.copyWith(backgroundMonitoring: value));

  void completeOnboarding() => _update((p) => p.copyWith(hasCompletedOnboarding: true));

  void clear() {
    state = null;
    unbindUser();
  }

  void _update(UserProfile Function(UserProfile) change) {
    final profile = state;
    if (profile == null) return;
    state = change(profile);
    _persist();
  }

  void _persist() {
    final profile = state;
    if (profile != null) {
      PersistenceService.instance.saveProfile(profile, userId: _userId);
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>(
  (ref) => UserProfileNotifier(),
);

/// Rings this phone for alerts on devices where the signed-in user is an
/// emergency contact. Watched by the app root so it runs app-wide.
final alertMonitorProvider = Provider<AlertMonitor?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isSignedIn) return null;

  final style = ref.watch(
      userProfileProvider.select((p) => p?.alertStyle ?? AlertStyle.soundAndVibration));
  final language = ref.watch(userProfileProvider.select((p) => p?.languageCode ?? 'en'));

  final monitor = AlertMonitor(
    repository: ref.read(deviceRepositoryProvider),
    userEmail: auth.email,
    style: style,
    languageCode: language,
  )..start();
  ref.onDispose(monitor.dispose);
  return monitor;
});

/// Android: keeps alerts arriving while the app is in the background, when
/// the user enabled it and a real family project is linked.
final backgroundMonitoringProvider = Provider<void>((ref) {
  final signedIn = ref.watch(authNotifierProvider.select((a) => a.isSignedIn));
  final linked = ref.watch(backendModeProvider) != null;
  final enabled =
      ref.watch(userProfileProvider.select((p) => p?.backgroundMonitoring ?? false));
  final language = ref.watch(userProfileProvider.select((p) => p?.languageCode ?? 'en'));
  final t = AppLocalizations(Locale(language));

  if (signedIn && linked && enabled) {
    NotificationService.instance.startBackgroundMonitoring(
      title: t.monitoringNotificationTitle,
      body: t.monitoringNotificationBody,
    );
  } else {
    NotificationService.instance.stopBackgroundMonitoring();
  }
});
