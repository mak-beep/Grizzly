import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts Firestore-specific values into plain Dart values the models
/// understand: [Timestamp] → [DateTime] (firmware writes server timestamps),
/// [GeoPoint] → `{lat, lng}`, recursively through maps and lists.
Map<String, dynamic> normalizeFirestoreData(Map<String, dynamic> data) =>
    data.map((key, value) => MapEntry(key, _normalize(value)));

Object? _normalize(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is GeoPoint) return {'lat': value.latitude, 'lng': value.longitude};
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _normalize(v)));
  }
  if (value is List) return value.map(_normalize).toList();
  return value;
}
