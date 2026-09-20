import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/alert_event.dart';
import '../models/device.dart';
import '../utils/json_parsing.dart';
import 'firestore_codec.dart';
import 'persistence_service.dart';

/// A history event that may need to alert the user.
class DeviceAlert {
  final Device device;
  final AlertEvent event;

  const DeviceAlert(this.device, this.event);
}

class DeviceTypeMismatchException implements Exception {
  final DeviceType actualType;
  const DeviceTypeMismatchException(this.actualType);
}

class DuplicateDeviceException implements Exception {
  const DuplicateDeviceException();
}

/// Single source of truth for the family's devices and their history.
///
/// With a linked Firebase project, a realtime listener on
/// `families/family/devices` (and each device's `history`) keeps this in
/// sync with whatever firmware or other family members write. Data is also
/// cached on the phone so the dashboard opens instantly and offline.
///
/// Documents created by firmware that nobody has added yet (no `name`) are
/// exposed as [detectedDevices] so they can be picked during pairing.
///
/// The app only ever writes its own fields (name, contacts, geofence);
/// location/status fields belong to the firmware.
class DeviceRepository extends ChangeNotifier {
  final _uuid = const Uuid();
  final List<Device> _devices = [];
  final List<Device> _detected = [];
  final Map<String, List<AlertEvent>> _history = {};
  final StreamController<DeviceAlert> _alerts = StreamController<DeviceAlert>.broadcast();

  String? _userId;
  bool _isLinkedToFirestore = false;
  FirebaseFirestore? _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _devicesSub;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _historySubs = {};

  /// Shown on the dashboard when the live listener fails (e.g. rules not
  /// published, or this user is not a family member).
  String? lastSyncError;

  List<Device> get allDevices => List.unmodifiable(_devices);

  List<Device> get detectedDevices => List.unmodifiable(_detected);

  bool get isLinkedToFirestore => _isLinkedToFirestore;

  /// History events as they arrive (including the initial sync); the
  /// alert monitor decides which ones actually ring the phone.
  Stream<DeviceAlert> get alerts => _alerts.stream;

  List<Device> detectedDevicesOfType(DeviceType type) =>
      _detected.where((d) => d.type == type).toList();

  Future<void> loadForUser(
    String userId, {
    bool isLinkedToFirestore = false,
    FirebaseFirestore? firestore,
  }) async {
    await _cancelLiveSync();

    _userId = userId;
    _isLinkedToFirestore = isLinkedToFirestore && firestore != null;
    _firestore = firestore;
    lastSyncError = null;

    final savedDevices = await PersistenceService.instance.loadDevices(userId);
    final savedHistory = await PersistenceService.instance.loadHistory(userId);
    _devices
      ..clear()
      ..addAll(savedDevices);
    _detected.clear();
    _history
      ..clear()
      ..addAll(savedHistory);
    notifyListeners();

    if (_isLinkedToFirestore) {
      _startLiveSync();
    }
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    await PersistenceService.instance.saveDevices(userId, _devices);
    await PersistenceService.instance.saveHistory(userId, _history);
  }

  CollectionReference<Map<String, dynamic>>? get _devicesCollection => _firestore
      ?.collection('families')
      .doc(AppConstants.sharedFamilyDocId)
      .collection('devices');

  void _startLiveSync() {
    final col = _devicesCollection;
    if (col == null) return;

    _devicesSub = col.snapshots().listen(
      _onDevicesSnapshot,
      onError: (Object e) {
        debugPrint('Firestore devices listener error: $e');
        lastSyncError = e.toString();
        notifyListeners();
      },
    );
  }

  void _onDevicesSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    lastSyncError = null;

    final claimed = <Device>[];
    final detected = <Device>[];
    for (final doc in snapshot.docs) {
      try {
        final device = Device.fromJson(normalizeFirestoreData(doc.data()), fallbackId: doc.id);
        (device.isClaimed ? claimed : detected).add(device);
      } on FormatException catch (e) {
        // One malformed document must never hide every other device.
        debugPrint('Skipping device document ${doc.id}: ${e.message}');
      }
    }
    detected.sort((a, b) => (b.lastSeen ?? DateTime(0)).compareTo(a.lastSeen ?? DateTime(0)));

    _devices
      ..clear()
      ..addAll(claimed);
    _detected
      ..clear()
      ..addAll(detected);

    final currentIds = claimed.map((d) => d.id).toSet();
    for (final id in _historySubs.keys.toList()) {
      if (!currentIds.contains(id)) {
        _historySubs.remove(id)?.cancel();
        _history.remove(id);
      }
    }
    for (final id in currentIds) {
      _historySubs.putIfAbsent(id, () => _listenToHistory(id));
    }

    unawaited(_persist());
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _listenToHistory(String deviceId) {
    return _devicesCollection!
        .doc(deviceId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(AppConstants.historyLimit)
        .snapshots()
        .listen(
      (snapshot) {
        _history[deviceId] = snapshot.docs
            .map((doc) => _eventFromDoc(doc, deviceId))
            .whereType<AlertEvent>()
            .toList();

        final device = deviceById(deviceId);
        if (device != null) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;
            final event = _eventFromDoc(change.doc, deviceId);
            if (event != null && event.type.isAlert) {
              _alerts.add(DeviceAlert(device, event));
            }
          }
        }

        unawaited(_persist());
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Firestore history listener error for $deviceId: $e'),
    );
  }

  AlertEvent? _eventFromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String deviceId) {
    final data = doc.data();
    if (data == null) return null;
    return AlertEvent.tryFromJson(
      normalizeFirestoreData(data),
      fallbackId: doc.id,
      fallbackDeviceId: deviceId,
    );
  }

  Future<void> _cancelLiveSync() async {
    await _devicesSub?.cancel();
    _devicesSub = null;
    for (final sub in _historySubs.values) {
      await sub.cancel();
    }
    _historySubs.clear();
  }

  @override
  void dispose() {
    unawaited(_cancelLiveSync());
    _alerts.close();
    super.dispose();
  }

  Device? deviceById(String id) => _devices.where((d) => d.id == id).firstOrNull;

  List<AlertEvent> historyFor(String deviceId) =>
      List.unmodifiable(_history[deviceId] ?? const <AlertEvent>[]);

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool isValidDeviceUuid(String value) => _uuidPattern.hasMatch(value.trim());

  bool deviceIdExists(String id) => deviceById(normalizeDeviceId(id)) != null;

  /// Firmware prints ids in lowercase; accept any case the user types.
  static String normalizeDeviceId(String id) => id.trim().toLowerCase();

  /// Adds a device to the family. With a linked project [uuid] must be the
  /// id the firmware registered (see [detectedDevices]); in Demo mode a
  /// random id is generated.
  Future<Device> registerDevice({
    required DeviceType type,
    required String name,
    String? uuid,
  }) async {
    final id = (uuid != null && uuid.trim().isNotEmpty) ? normalizeDeviceId(uuid) : _uuid.v4();
    if (deviceById(id) != null) throw const DuplicateDeviceException();

    final detected = _detected.where((d) => d.id == id).firstOrNull;
    if (detected != null && detected.type != type) {
      throw DeviceTypeMismatchException(detected.type);
    }

    final device = detected ?? Device(id: id, type: type, name: name);
    device.name = name;
    _detected.removeWhere((d) => d.id == id);
    _devices.add(device);
    _history.putIfAbsent(id, () => []);
    notifyListeners();

    final col = _devicesCollection;
    if (_isLinkedToFirestore && col != null) {
      try {
        await col.doc(id).set({
          'id': id,
          'type': type.name,
          'name': name,
          'claimedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        _devices.removeWhere((d) => d.id == id);
        if (detected != null) {
          detected.name = '';
          _detected.add(detected);
        }
        notifyListeners();
        rethrow;
      }
    }

    unawaited(_persist());
    return device;
  }

  Future<void> renameDevice(String deviceId, String newName) async {
    final device = deviceById(deviceId);
    final trimmed = newName.trim();
    if (device == null || trimmed.isEmpty) return;
    device.name = trimmed;
    await _saveAppFields(deviceId, {'name': trimmed});
  }

  /// Pass null to remove the safe zone.
  Future<void> updateGeofence(String deviceId, Geofence? geofence) async {
    final device = deviceById(deviceId);
    if (device == null || device.type != DeviceType.gpsTracker) return;
    if (geofence != null && !geofence.isValid) {
      throw ArgumentError('Safe zone needs a real location');
    }
    device.geofence = geofence;
    if (geofence == null) device.geofenceStatus = GeofenceStatus.unknown;
    await _saveAppFields(deviceId, {'geofence': geofence?.toJson()});
  }

  Future<void> setContacts(String deviceId, List<EmergencyContact> contacts) async {
    final device = deviceById(deviceId);
    if (device == null) return;
    if (contacts.length < AppConstants.minEmergencyContacts ||
        contacts.length > AppConstants.maxEmergencyContacts) {
      throw ArgumentError('Each device needs ${AppConstants.minEmergencyContacts}-'
          '${AppConstants.maxEmergencyContacts} emergency contacts.');
    }
    final emails = contacts.map((c) => normalizeEmail(c.email)).toList();
    if (emails.any((e) => !isValidEmail(e)) || emails.toSet().length != emails.length) {
      throw ArgumentError('Every contact needs its own valid email address.');
    }
    device.contacts
      ..clear()
      ..addAll(contacts.map((c) => EmergencyContact(
            id: c.id,
            name: c.name.trim(),
            email: normalizeEmail(c.email),
            phone: c.phone.trim(),
          )));
    await _saveAppFields(deviceId, {
      'contacts': device.contacts.map((c) => c.toJson()).toList(),
    });
  }

  /// Lets the physical device claim its document again, e.g. after it was
  /// re-flashed and signed in to Firebase as a new device user.
  Future<void> repairDevice(String deviceId) => _saveAppFields(deviceId, {'deviceUid': null});

  Future<void> removeDevice(String deviceId) async {
    _devices.removeWhere((d) => d.id == deviceId);
    _history.remove(deviceId);
    await _historySubs.remove(deviceId)?.cancel();
    notifyListeners();
    unawaited(_persist());

    final col = _devicesCollection;
    if (_isLinkedToFirestore && col != null) {
      await col.doc(deviceId).delete();
    }
  }

  Future<void> _saveAppFields(String deviceId, Map<String, Object?> fields) async {
    notifyListeners();
    unawaited(_persist());
    final col = _devicesCollection;
    if (_isLinkedToFirestore && col != null) {
      await col.doc(deviceId).update(fields);
    }
  }

  /// Demo mode only: applies an event the way firmware would, so every
  /// screen, the history and notifications can be tried without hardware.
  void simulateEvent(AlertEvent event) {
    if (_isLinkedToFirestore) return;
    final device = deviceById(event.deviceId);
    if (device == null) return;

    if (event.hasLocation) {
      device.lastLat = event.lat;
      device.lastLng = event.lng;
    }
    device.lastSeen = event.timestamp;
    device.isOnline = true;
    switch (event.type) {
      case AlertEventType.alarmTriggered:
        device.alarmActive = true;
      case AlertEventType.alarmCancelled:
        device.alarmActive = false;
      case AlertEventType.geofenceBreach:
        device.geofenceStatus = GeofenceStatus.outside;
      case AlertEventType.geofenceReturn:
        device.geofenceStatus = GeofenceStatus.inside;
      case AlertEventType.locationPing:
        break;
    }

    _history.putIfAbsent(event.deviceId, () => []).insert(0, event);
    unawaited(_persist());
    notifyListeners();
    if (event.type.isAlert) {
      _alerts.add(DeviceAlert(device, event));
    }
  }

  /// Drops in-memory state and listeners on sign-out. Nothing is deleted
  /// from the phone's cache or from Firestore.
  void reset() {
    unawaited(_cancelLiveSync());
    _devices.clear();
    _detected.clear();
    _history.clear();
    _userId = null;
    _isLinkedToFirestore = false;
    _firestore = null;
    lastSyncError = null;
    notifyListeners();
  }
}
