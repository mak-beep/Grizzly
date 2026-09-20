// The app must understand exactly what the firmware writes to Firestore:
// server timestamps arrive as `Timestamp`, coordinates as numbers, and the
// event `type` as the strings used by both firmware projects.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/constants/app_constants.dart';
import 'package:geoguard_app/core/models/alert_event.dart';
import 'package:geoguard_app/core/models/device.dart';
import 'package:geoguard_app/core/services/firestore_codec.dart';

void main() {
  final seen = DateTime.utc(2026, 9, 17, 10, 30);

  group('device document written by firmware', () {
    final firmwareDoc = <String, dynamic>{
      'type': 'gpsTracker',
      'deviceUid': 'Xr5Qm2pWdKZ3vT7yA1bC9eF0gH12',
      'isOnline': true,
      'charging': false,
      'fwVersion': '1.1.0',
      'lastLat': 24.8607,
      'lastLng': 67.0011,
      'lastSeen': Timestamp.fromDate(seen),
      'geofenceStatus': 'outside',
    };

    test('parses, including the server timestamp', () {
      final device = Device.fromJson(normalizeFirestoreData(firmwareDoc), fallbackId: 'dev-1');

      expect(device.id, 'dev-1');
      expect(device.type, DeviceType.gpsTracker);
      // Firestore hands back a local DateTime for the same instant.
      expect(device.lastSeen!.isAtSameMomentAs(seen), isTrue);
      expect(device.lastLat, closeTo(24.8607, 1e-9));
      expect(device.geofenceStatus, GeofenceStatus.outside);
      expect(device.charging, isFalse);
      // No name yet: this is a device waiting to be added in the app.
      expect(device.isClaimed, isFalse);
    });

    test('app fields written later are merged in', () {
      final claimed = {
        ...firmwareDoc,
        'id': 'dev-1',
        'name': "Emma's backpack",
        'contacts': [
          {'id': 'c1', 'name': 'Dad', 'email': 'Dad@Example.com', 'phone': '+100'},
        ],
        'geofence': {
          'centerLat': 24.86,
          'centerLng': 67.0,
          'addressLabel': 'Home',
          'radiusMeters': 200,
        },
      };

      final device = Device.fromJson(normalizeFirestoreData(claimed));
      expect(device.isClaimed, isTrue);
      expect(device.geofence!.isValid, isTrue);
      expect(device.contactEmails, {'dad@example.com'});
    });

    test('a document with an unknown type is rejected, not crashed on', () {
      expect(
        () => Device.fromJson({'id': 'x', 'type': 'doorbell'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('history entry written by firmware', () {
    test('parses every event type the firmware can send', () {
      for (final type in [
        'locationPing',
        'geofenceBreach',
        'geofenceReturn',
        'alarmTriggered',
        'alarmCancelled',
      ]) {
        final event = AlertEvent.tryFromJson(normalizeFirestoreData({
          'id': 'e-$type',
          'deviceId': 'dev-1',
          'type': type,
          'timestamp': Timestamp.fromDate(seen),
          'lat': null,
          'lng': null,
          'note': null,
        }));
        expect(event, isNotNull, reason: type);
        expect(event!.type.name, type);
        expect(event.timestamp.isAtSameMomentAs(seen), isTrue, reason: type);
      }
    });

    test('only real alerts notify, pings do not', () {
      expect(AlertEventType.alarmTriggered.isAlert, isTrue);
      expect(AlertEventType.alarmTriggered.isUrgent, isTrue);
      expect(AlertEventType.geofenceBreach.isUrgent, isTrue);
      expect(AlertEventType.geofenceReturn.isAlert, isTrue);
      expect(AlertEventType.geofenceReturn.isUrgent, isFalse);
      expect(AlertEventType.locationPing.isAlert, isFalse);
    });

    test('an entry without a timestamp is skipped instead of breaking the list', () {
      expect(AlertEvent.tryFromJson({'id': 'e1', 'deviceId': 'd1', 'type': 'locationPing'}), isNull);
    });

    test('a newer firmware event type falls back to a location update', () {
      final event = AlertEvent.tryFromJson({
        'id': 'e1',
        'deviceId': 'd1',
        'type': 'somethingNew',
        'timestamp': seen.toIso8601String(),
      });
      expect(event!.type, AlertEventType.locationPing);
    });
  });

  group('locally cached data (written as ISO strings)', () {
    test('survives a round trip', () {
      final device = Device(
        id: 'dev-2',
        type: DeviceType.alarmButton,
        name: 'Hallway button',
        lastSeen: seen,
        alarmActive: true,
        contacts: [EmergencyContact(id: 'c1', name: 'Mum', email: 'mum@example.com')],
      );

      final restored = Device.fromJson(device.toJson());
      expect(restored.lastSeen!.isAtSameMomentAs(seen), isTrue);
      expect(restored.alarmActive, isTrue);
      expect(restored.contacts.single.email, 'mum@example.com');
    });

    test('contacts saved by the previous app version still load', () {
      final legacy = {
        'id': 'dev-3',
        'type': 'gpsTracker',
        'name': 'Old',
        'contacts': [
          {'id': 'c1', 'name': 'Dad', 'phoneOrEmail': 'dad@example.com'},
          {'id': 'c2', 'name': 'Gran', 'phoneOrEmail': '+1 555 0100'},
        ],
      };
      final device = Device.fromJson(legacy);
      expect(device.contacts[0].email, 'dad@example.com');
      expect(device.contacts[1].phone, '+1 555 0100');
      expect(device.contacts[1].email, isEmpty);
    });
  });

  group('connectivity', () {
    test('tracker is offline after 3 minutes, button only after 3 hours', () {
      final now = DateTime.utc(2026, 9, 17, 12);
      final tracker = Device(
          id: 't', type: DeviceType.gpsTracker, name: 'T', lastSeen: now.subtract(const Duration(minutes: 5)));
      final button = Device(
          id: 'b', type: DeviceType.alarmButton, name: 'B', lastSeen: now.subtract(const Duration(minutes: 5)));

      expect(tracker.connectivityAt(now), DeviceConnectivity.offline);
      expect(button.connectivityAt(now), DeviceConnectivity.online);

      button.lastSeen = now.subtract(const Duration(hours: 4));
      expect(button.connectivityAt(now), DeviceConnectivity.offline);

      expect(Device(id: 'n', type: DeviceType.gpsTracker, name: 'N').connectivityAt(now),
          DeviceConnectivity.neverSeen);
    });
  });

  group('safe zone validation', () {
    test('rejects the (0,0) placeholder the old app used to save', () {
      const placeholder =
          Geofence(centerLat: 0, centerLng: 0, addressLabel: 'Home', radiusMeters: 200);
      expect(placeholder.isValid, isFalse);

      const real = Geofence(centerLat: 24.86, centerLng: 67.0, addressLabel: 'Home', radiusMeters: 200);
      expect(real.isValid, isTrue);
    });
  });
}
