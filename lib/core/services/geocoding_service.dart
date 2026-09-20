import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../utils/json_parsing.dart';

class GeocodingResult {
  final String label;
  final double lat;
  final double lng;

  const GeocodingResult({required this.label, required this.lat, required this.lng});
}

class GeocodingException implements Exception {
  final String message;
  const GeocodingException(this.message);

  @override
  String toString() => message;
}

/// Address search with OpenStreetMap Nominatim — free, no API key. Only called
/// when the user taps "Search", which keeps within Nominatim's usage policy
/// (max 1 request per second, identifying User-Agent).
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<GeocodingResult>> search(String query, {String? languageCode}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse(AppConstants.nominatimSearchUrl).replace(queryParameters: {
      'q': trimmed,
      'format': 'jsonv2',
      'limit': '5',
    });

    final http.Response response;
    try {
      response = await _client.get(uri, headers: {
        'User-Agent': AppConstants.osmUserAgent,
        if (languageCode != null) 'Accept-Language': languageCode,
      }).timeout(const Duration(seconds: 12));
    } catch (e) {
      throw GeocodingException('Address search failed: $e');
    }

    if (response.statusCode != 200) {
      throw GeocodingException('Address search failed (HTTP ${response.statusCode})');
    }
    return parseResults(response.body);
  }

  static List<GeocodingResult> parseResults(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const GeocodingException('Unexpected response from the address search');
    }
    if (decoded is! List) return const [];

    return decoded
        .map(parseMap)
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final lat = parseDouble(item['lat']);
          final lng = parseDouble(item['lon']);
          final label = parseString(item['display_name']);
          if (lat == null || lng == null || label == null) return null;
          return GeocodingResult(label: label, lat: lat, lng: lng);
        })
        .whereType<GeocodingResult>()
        .toList();
  }
}
