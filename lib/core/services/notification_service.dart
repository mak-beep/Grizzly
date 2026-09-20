import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/user_profile.dart';

/// Lets alerts show an in-app banner from anywhere (no BuildContext needed).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Phone notifications for device alerts: sound/vibration per the user's
/// alert style, plus an in-app banner while the app is open.
///
/// There is no push server in this architecture, so alerts come from the
/// app's live Firestore listener. On Android an optional foreground service
/// ([startBackgroundMonitoring]) keeps that listener alive while the app is
/// in the background.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _urgentChannelId = 'geoguard_alerts';
  static const _vibrateChannelId = 'geoguard_alerts_vibrate';
  static const _infoChannelId = 'geoguard_updates';
  static const _monitorChannelId = 'geoguard_monitoring';
  static const _monitorNotificationId = 7001;

  static final Int64List _alarmVibration = Int64List.fromList([0, 700, 300, 700, 300, 700]);

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _monitoring = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      final android = _android;
      if (android != null) {
        await android.createNotificationChannel(AndroidNotificationChannel(
          _urgentChannelId,
          'Emergency alerts',
          description: 'Alarm button presses and safe zone breaches',
          importance: Importance.max,
          vibrationPattern: _alarmVibration,
        ));
        await android.createNotificationChannel(AndroidNotificationChannel(
          _vibrateChannelId,
          'Emergency alerts (vibrate only)',
          description: 'Alarm button presses and safe zone breaches, without sound',
          importance: Importance.high,
          playSound: false,
          vibrationPattern: _alarmVibration,
        ));
        await android.createNotificationChannel(const AndroidNotificationChannel(
          _infoChannelId,
          'Device updates',
          description: 'Alarm cancellations and returns to the safe zone',
          importance: Importance.defaultImportance,
        ));
        await android.createNotificationChannel(const AndroidNotificationChannel(
          _monitorChannelId,
          'Background monitoring',
          description: 'Keeps Grizzly listening for alerts in the background',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        ));
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  Future<void> requestPermissions() async {
    await initialize();
    if (!_initialized) return;
    try {
      await _android?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  /// [key] identifies the event, so the same alert never produces two
  /// notifications.
  Future<void> showAlert({
    required String key,
    required String title,
    required String body,
    required bool urgent,
    required AlertStyle style,
  }) async {
    if (urgent) {
      HapticFeedback.vibrate();
    } else {
      HapticFeedback.mediumImpact();
    }
    showBanner(title: title, body: body, urgent: urgent);

    await initialize();
    if (!_initialized) return;

    final withSound = !urgent || style == AlertStyle.soundAndVibration;
    final channelId = !urgent
        ? _infoChannelId
        : (withSound ? _urgentChannelId : _vibrateChannelId);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        switch (channelId) {
          _urgentChannelId => 'Emergency alerts',
          _vibrateChannelId => 'Emergency alerts (vibrate only)',
          _ => 'Device updates',
        },
        importance: urgent ? Importance.max : Importance.defaultImportance,
        priority: urgent ? Priority.max : Priority.defaultPriority,
        category: urgent ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.event,
        playSound: withSound,
        enableVibration: true,
        vibrationPattern: urgent ? _alarmVibration : null,
        styleInformation: BigTextStyleInformation(body),
        ticker: title,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: withSound,
        interruptionLevel: urgent ? InterruptionLevel.timeSensitive : InterruptionLevel.active,
      ),
    );

    try {
      await _plugin.show(key.hashCode & 0x7fffffff, title, body, details);
    } catch (e) {
      debugPrint('Could not show notification: $e');
    }
  }

  void showBanner({required String title, required String body, required bool urgent}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final theme = Theme.of(messenger.context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: urgent ? 8 : 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: urgent ? theme.colorScheme.error : theme.colorScheme.primary,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(urgent ? Icons.notifications_active : Icons.notifications_none,
                  color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(body, style: const TextStyle(color: Colors.white)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Android: runs a foreground service with an ongoing notification so the
  /// process (and its Firestore listener) is not stopped in the background.
  Future<void> startBackgroundMonitoring({required String title, required String body}) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await initialize();
    final android = _android;
    if (!_initialized || android == null) return;
    try {
      await android.startForegroundService(
        _monitorNotificationId,
        title,
        body,
        notificationDetails: const AndroidNotificationDetails(
          _monitorChannelId,
          'Background monitoring',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          playSound: false,
          enableVibration: false,
          showWhen: false,
        ),
        foregroundServiceTypes: {AndroidServiceForegroundType.foregroundServiceTypeRemoteMessaging},
      );
      _monitoring = true;
    } catch (e) {
      debugPrint('Background monitoring could not start '
          '(see README: AndroidManifest foreground service entries): $e');
    }
  }

  Future<void> stopBackgroundMonitoring() async {
    if (!_monitoring) return;
    try {
      await _android?.stopForegroundService();
    } catch (e) {
      debugPrint('Stopping background monitoring failed: $e');
    }
    _monitoring = false;
  }
}
