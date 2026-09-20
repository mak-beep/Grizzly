import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../localization/app_localizations.dart';
import '../models/alert_event.dart';
import '../models/device.dart';
import '../models/user_profile.dart';
import '../utils/json_parsing.dart';
import 'device_repository.dart';
import 'notification_service.dart';
import 'persistence_service.dart';

/// Whether [event] on [device] should ring this user's phone.
///
/// Emergency contacts are Grizzly users identified by email. A device with
/// no contacts configured yet alerts every family member, so nobody misses an
/// alert because setup was incomplete.
bool shouldNotifyUser({
  required Device device,
  required AlertEvent event,
  required String? userEmail,
  required DateTime now,
}) {
  if (!event.type.isAlert) return false;
  if (now.difference(event.timestamp) > AppConstants.alertNotifyMaxAge) return false;

  final contacts = device.contactEmails;
  if (contacts.isEmpty) return true;
  return userEmail != null && contacts.contains(normalizeEmail(userEmail));
}

/// Turns device alerts from [DeviceRepository] into phone notifications for
/// the signed-in user, once per event (also across app restarts).
class AlertMonitor {
  AlertMonitor({
    required DeviceRepository repository,
    required this.userEmail,
    required this.style,
    required String languageCode,
  })  : _repository = repository,
        _t = AppLocalizations(Locale(languageCode));

  final DeviceRepository _repository;
  final String? userEmail;
  final AlertStyle style;
  final AppLocalizations _t;

  StreamSubscription<DeviceAlert>? _subscription;
  Set<String>? _notified;

  void start() {
    _subscription ??= _repository.alerts.listen((alert) => unawaited(_handle(alert)));
  }

  Future<void> _handle(DeviceAlert alert) async {
    if (!shouldNotifyUser(
      device: alert.device,
      event: alert.event,
      userEmail: userEmail,
      now: DateTime.now(),
    )) {
      return;
    }

    final notified = _notified ??= await PersistenceService.instance.loadNotifiedEventIds();
    if (!notified.add(alert.event.id)) return;
    unawaited(PersistenceService.instance.saveNotifiedEventIds(notified));

    final (title, body) = _texts(alert.device, alert.event);
    await NotificationService.instance.showAlert(
      key: alert.event.id,
      title: title,
      body: body,
      urgent: alert.event.type.isUrgent,
      style: style,
    );
  }

  (String, String) _texts(Device device, AlertEvent event) {
    final time = DateFormat.Hm().format(event.timestamp.toLocal());
    return switch (event.type) {
      AlertEventType.alarmTriggered => (
          _t.alertAlarmTitle(device.name),
          _t.alertAlarmBody(time),
        ),
      AlertEventType.alarmCancelled => (
          _t.alertAlarmCancelledTitle(device.name),
          _t.alertAlarmCancelledBody(time),
        ),
      AlertEventType.geofenceBreach => (
          _t.alertBreachTitle(device.name),
          _t.alertBreachBody(time),
        ),
      AlertEventType.geofenceReturn => (
          _t.alertReturnTitle(device.name),
          _t.alertReturnBody(time),
        ),
      AlertEventType.locationPing => (device.name, ''),
    };
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
