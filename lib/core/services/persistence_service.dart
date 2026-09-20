import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_event.dart';
import '../models/device.dart';
import '../models/user_profile.dart';

/// On-phone storage (`shared_preferences`) so setup is done once and the
/// dashboard opens instantly, also offline. Profile, devices and history are
/// keyed per signed-in user, so family members sharing a phone never see each
/// other's personal settings.
class PersistenceService {
  PersistenceService._();
  static final PersistenceService instance = PersistenceService._();

  static const _kProfilePendingSlot = 'geoguard.profile.pending.v1'; // pre-auth staging
  static const _kProfilePrefix = 'geoguard.profile.v1.'; // + userId
  static const _kAuthEmail = 'geoguard.auth.email.v1';
  static const _kAuthUserId = 'geoguard.auth.userId.v1';
  static const _kBackendMode = 'geoguard.backend.mode.v1'; // absent = demo mode
  static const _kBackendConfig = 'geoguard.backend.config.v1';
  static const _kDevicesPrefix = 'geoguard.devices.v1.'; // + userId
  static const _kHistoryPrefix = 'geoguard.history.v1.'; // + userId
  static const _kNotifiedEvents = 'geoguard.notifiedEvents.v1';
  static const _maxNotifiedEvents = 300;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---- Profile ----

  Future<void> saveProfile(UserProfile profile, {String? userId}) async {
    final prefs = await _prefs;
    final key = userId != null ? '$_kProfilePrefix$userId' : _kProfilePendingSlot;
    await prefs.setString(key, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile({String? userId}) async {
    final prefs = await _prefs;
    final key = userId != null ? '$_kProfilePrefix$userId' : _kProfilePendingSlot;
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Moves the profile collected before sign-up into the new account's slot.
  Future<void> claimPendingProfile(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kProfilePendingSlot);
    if (raw == null) return;
    await prefs.setString('$_kProfilePrefix$userId', raw);
    await prefs.remove(_kProfilePendingSlot);
  }

  // ---- Auth session (never a password) ----

  Future<void> saveAuthSession({required String userId, required String email}) async {
    final prefs = await _prefs;
    await prefs.setString(_kAuthUserId, userId);
    await prefs.setString(_kAuthEmail, email);
  }

  Future<({String userId, String email})?> loadAuthSession() async {
    final prefs = await _prefs;
    final userId = prefs.getString(_kAuthUserId);
    final email = prefs.getString(_kAuthEmail);
    if (userId == null || email == null) return null;
    return (userId: userId, email: email);
  }

  Future<void> clearAuthSession() async {
    final prefs = await _prefs;
    await prefs.remove(_kAuthUserId);
    await prefs.remove(_kAuthEmail);
  }

  // ---- Backend (demo vs linked family Firebase project) ----

  Future<String?> loadBackendMode() async {
    final prefs = await _prefs;
    return prefs.getString(_kBackendMode);
  }

  Future<void> saveBackendConfig({
    required String projectId,
    required String apiKey,
    required String appId,
    required String messagingSenderId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(
      _kBackendConfig,
      jsonEncode({
        'projectId': projectId,
        'apiKey': apiKey,
        'appId': appId,
        'messagingSenderId': messagingSenderId,
      }),
    );
    await prefs.setString(_kBackendMode, projectId);
  }

  Future<({String projectId, String apiKey, String appId, String messagingSenderId})?>
      loadBackendConfig() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kBackendConfig);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        projectId: json['projectId'] as String,
        apiKey: json['apiKey'] as String,
        appId: json['appId'] as String,
        messagingSenderId: json['messagingSenderId'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearBackendConfig() async {
    final prefs = await _prefs;
    await prefs.remove(_kBackendConfig);
    await prefs.remove(_kBackendMode);
  }

  // ---- Devices + history cache (per signed-in user) ----

  Future<void> saveDevices(String userId, List<Device> devices) async {
    final prefs = await _prefs;
    await prefs.setString(
        '$_kDevicesPrefix$userId', jsonEncode(devices.map((d) => d.toJson()).toList()));
  }

  Future<List<Device>> loadDevices(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_kDevicesPrefix$userId');
    if (raw == null) return [];
    try {
      final devices = <Device>[];
      for (final item in jsonDecode(raw) as List<dynamic>) {
        try {
          devices.add(Device.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Skipping cached device: $e');
        }
      }
      return devices;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String userId, Map<String, List<AlertEvent>> history) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      history.map((id, events) => MapEntry(id, events.map((e) => e.toJson()).toList())),
    );
    await prefs.setString('$_kHistoryPrefix$userId', encoded);
  }

  Future<Map<String, List<AlertEvent>>> loadHistory(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_kHistoryPrefix$userId');
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((deviceId, events) => MapEntry(
            deviceId,
            (events as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map((e) => AlertEvent.tryFromJson(e, fallbackDeviceId: deviceId))
                .whereType<AlertEvent>()
                .toList(),
          ));
    } catch (_) {
      return {};
    }
  }

  // ---- Alerts already shown on this phone ----

  Future<Set<String>> loadNotifiedEventIds() async {
    final prefs = await _prefs;
    return (prefs.getStringList(_kNotifiedEvents) ?? const []).toSet();
  }

  Future<void> saveNotifiedEventIds(Set<String> ids) async {
    final prefs = await _prefs;
    final list = ids.toList();
    final trimmed =
        list.length > _maxNotifiedEvents ? list.sublist(list.length - _maxNotifiedEvents) : list;
    await prefs.setStringList(_kNotifiedEvents, trimmed);
  }

  /// Only the session pointer is cleared; per-user profile, devices and
  /// history stay cached for the next sign-in.
  Future<void> clearAllForSignOut() => clearAuthSession();
}
