/// Tolerant readers for data that may come from local JSON (strings), from
/// Firestore (already converted by `normalizeFirestoreData`), or from older
/// app versions. None of these throw.
library;

DateTime? parseDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

double? parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool parseBool(Object? value, {bool fallback = false}) => value is bool ? value : fallback;

String? parseString(Object? value) => value is String ? value : null;

Map<String, dynamic>? parseMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return null;
}

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

String normalizeEmail(String value) => value.trim().toLowerCase();
