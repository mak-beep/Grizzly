import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/constants/app_constants.dart';
import 'package:geoguard_app/core/models/alert_event.dart';
import 'package:geoguard_app/core/models/device.dart';
import 'package:geoguard_app/core/services/alert_monitor.dart';

void main() {
  final now = DateTime.utc(2026, 9, 17, 12);

  Device deviceWithContacts(List<String> emails) => Device(
        id: 'd1',
        type: DeviceType.alarmButton,
        name: 'Button',
        contacts: [
          for (var i = 0; i < emails.length; i++)
            EmergencyContact(id: 'c$i', name: 'C$i', email: emails[i]),
        ],
      );

  AlertEvent event(AlertEventType type, {Duration age = Duration.zero}) => AlertEvent(
        id: 'e1',
        deviceId: 'd1',
        type: type,
        timestamp: now.subtract(age),
      );

  test('emergency contacts are alerted, other family members are not', () {
    final device = deviceWithContacts(['mum@example.com', 'dad@example.com']);

    expect(
      shouldNotifyUser(
          device: device,
          event: event(AlertEventType.alarmTriggered),
          userEmail: 'Mum@Example.com', // case-insensitive
          now: now),
      isTrue,
    );
    expect(
      shouldNotifyUser(
          device: device,
          event: event(AlertEventType.alarmTriggered),
          userEmail: 'neighbour@example.com',
          now: now),
      isFalse,
    );
  });

  test('with no contacts set up yet, everyone in the family is alerted', () {
    expect(
      shouldNotifyUser(
          device: deviceWithContacts(const []),
          event: event(AlertEventType.geofenceBreach),
          userEmail: 'anyone@example.com',
          now: now),
      isTrue,
    );
  });

  test('location pings never notify', () {
    expect(
      shouldNotifyUser(
          device: deviceWithContacts(const []),
          event: event(AlertEventType.locationPing),
          userEmail: 'mum@example.com',
          now: now),
      isFalse,
    );
  });

  test('old events found when the app is reopened do not ring the phone', () {
    final device = deviceWithContacts(['mum@example.com']);
    expect(
      shouldNotifyUser(
          device: device,
          event: event(AlertEventType.alarmTriggered, age: const Duration(minutes: 5)),
          userEmail: 'mum@example.com',
          now: now),
      isTrue,
    );
    expect(
      shouldNotifyUser(
          device: device,
          event: event(AlertEventType.alarmTriggered, age: const Duration(hours: 2)),
          userEmail: 'mum@example.com',
          now: now),
      isFalse,
    );
  });
}
