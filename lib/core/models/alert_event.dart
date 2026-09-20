import '../utils/json_parsing.dart';

/// Must match the `type` strings written by the firmware.
enum AlertEventType {
  geofenceBreach,
  geofenceReturn,
  alarmTriggered,
  alarmCancelled,
  locationPing,
}

extension AlertEventTypeX on AlertEventType {
  /// Events that notify emergency contacts (everything except location pings).
  bool get isAlert => this != AlertEventType.locationPing;

  /// Events that need immediate attention (loud, high-priority notification).
  bool get isUrgent =>
      this == AlertEventType.geofenceBreach || this == AlertEventType.alarmTriggered;
}

/// One row in a device's history log.
class AlertEvent {
  final String id;
  final String deviceId;
  final AlertEventType type;
  final DateTime timestamp;
  final double? lat;
  final double? lng;
  final String? note;

  const AlertEvent({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.timestamp,
    this.lat,
    this.lng,
    this.note,
  });

  bool get hasLocation => lat != null && lng != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'lat': lat,
        'lng': lng,
        'note': note,
      };

  /// Returns null for entries that cannot be shown (no id or timestamp).
  /// Unknown event types from newer firmware are shown as location updates.
  static AlertEvent? tryFromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
    String? fallbackDeviceId,
  }) {
    final id = parseString(json['id']) ?? fallbackId;
    final deviceId = parseString(json['deviceId']) ?? fallbackDeviceId;
    final timestamp = parseDateTime(json['timestamp']);
    if (id == null || deviceId == null || timestamp == null) return null;

    final typeName = parseString(json['type']);
    return AlertEvent(
      id: id,
      deviceId: deviceId,
      type: AlertEventType.values.where((t) => t.name == typeName).firstOrNull ??
          AlertEventType.locationPing,
      timestamp: timestamp,
      lat: parseDouble(json['lat']),
      lng: parseDouble(json['lng']),
      note: parseString(json['note']),
    );
  }
}
