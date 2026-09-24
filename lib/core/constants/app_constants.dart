import 'package:flutter/material.dart' show IconData, Icons;

import '../localization/app_localizations.dart';

/// Central place for every numeric/business rule agreed with the client, so
/// nothing is scattered as magic numbers across the app.
class AppConstants {
  AppConstants._();

  // --- GPS Tracking Chip ---
  static const int gpsPollingIntervalSeconds = 30;
  static const int gpsBatteryLifeMinDays = 1;
  static const int gpsBatteryLifeMaxDays = 2;

  /// A tracker reports every 30 s; after this long without an update it is
  /// shown as offline.
  static const Duration gpsTrackerOfflineAfter = Duration(minutes: 3);

  // --- Alarm Button ---
  static const int alarmBuzzerDurationSeconds = 30;
  static const int alarmDeactivationPressCount = 3; // exactly 3, never 1 or 2
  static const int alarmDeactivationWindowSeconds = 2;

  /// The button checks in quietly about every 50 minutes; after this long
  /// without a check-in the app warns that it may be dead or out of coverage.
  static const Duration alarmCheckInOverdueAfter = Duration(hours: 3);

  // --- Shared ---
  static const int minEmergencyContacts = 3;
  static const int maxEmergencyContacts = 5;

  /// Number of history entries kept in sync per device.
  static const int historyLimit = 200;

  /// Alerts older than this (e.g. found when the app is opened hours later)
  /// are shown in the history but do not ring the phone.
  static const Duration alertNotifyMaxAge = Duration(minutes: 15);

  // --- Safe zones ---
  static const double geofenceMinRadiusMeters = 50;
  static const double geofenceMaxRadiusMeters = 2000;
  static const double geofenceDefaultRadiusMeters = 200;

  // --- OpenStreetMap (no API key required) ---
  static const String osmTileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String nominatimSearchUrl = 'https://nominatim.openstreetmap.org/search';

  /// OpenStreetMap's usage policy requires an identifying User-Agent.
  static const String osmUserAgent = 'Grizzly-FamilySafetyApp/0.2 (Flutter)';

  static const List<String> supportedLanguageCodes = [
    'en', // English
    'fr', // French
    'es', // Spanish
    'it', // Italian
  ];

  /// Fixed document id for the single family's shared data within their own
  /// Firebase project. Every family has its own project, so every signed-in
  /// member reads and writes the SAME `families/{sharedFamilyDocId}` tree,
  /// which is what makes device settings (safe zone, contacts) shared across
  /// every member's individual login. Must match FIRESTORE_FAMILY_DOC in the
  /// firmware.
  static const String sharedFamilyDocId = 'family';
}

enum DeviceType { gpsTracker, alarmButton }

extension DeviceTypeLabel on DeviceType {
  /// English fallback only — for logs/debug output. UI code should call
  /// [localizedName] instead.
  String get displayName => switch (this) {
        DeviceType.gpsTracker => 'GPS Tracker',
        DeviceType.alarmButton => 'Alarm Button',
      };

  /// Standard Material icons used everywhere a device type is shown, so the
  /// chip and the button look the same on every screen.
  IconData get icon => switch (this) {
        DeviceType.gpsTracker => Icons.location_on,
        DeviceType.alarmButton => Icons.notifications_active,
      };

  String localizedName(AppLocalizations t) => switch (this) {
        DeviceType.gpsTracker => t.deviceTypeGpsName,
        DeviceType.alarmButton => t.deviceTypeAlarmName,
      };
}
