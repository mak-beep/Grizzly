import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/services/geocoding_service.dart';
import 'package:geoguard_app/core/utils/map_projection.dart';

void main() {
  group('map projection', () {
    test('projecting and unprojecting returns the same point', () {
      const points = [
        LatLngPoint(24.8607, 67.0011),
        LatLngPoint(-33.8688, 151.2093),
        LatLngPoint(51.5074, -0.1278),
      ];
      for (final point in points) {
        for (final zoom in [3.0, 12.0, 16.5, 19.0]) {
          final back = MapProjection.unproject(MapProjection.project(point, zoom), zoom);
          expect(back.lat, closeTo(point.lat, 1e-6), reason: '$point @ $zoom');
          expect(back.lng, closeTo(point.lng, 1e-6), reason: '$point @ $zoom');
        }
      }
    });

    test('a tile covers 256 pixels and zooming in doubles the world', () {
      expect(MapProjection.worldSize(0), MapProjection.tileSize);
      expect(MapProjection.worldSize(5), MapProjection.worldSize(4) * 2);
    });

    test('ground resolution at the equator matches the known value', () {
      expect(MapProjection.metersPerPixel(0, 0), closeTo(156543.03, 0.1));
      expect(MapProjection.metersPerPixel(0, 10), closeTo(152.87, 0.1));
    });

    test('distance matches the firmware haversine result', () {
      // ~0.004° of latitude is roughly 445 m, as used in the firmware tests.
      const a = LatLngPoint(24.8607, 67.0011);
      const b = LatLngPoint(24.8647, 67.0011);
      expect(MapProjection.distanceMeters(a, b), closeTo(445, 5));
      expect(MapProjection.distanceMeters(a, a), closeTo(0, 0.001));
    });

    test('a safe zone fits in the viewport at the chosen zoom', () {
      const radius = 200.0;
      final zoom = MapProjection.zoomToFit(radius, 24.86, 240);
      final circleDiameterPx = radius * 2 / MapProjection.metersPerPixel(24.86, zoom);
      expect(circleDiameterPx, lessThanOrEqualTo(240));
      expect(circleDiameterPx, greaterThan(60));
      expect(zoom, lessThanOrEqualTo(MapProjection.maxZoom));
    });

    test('latitudes beyond the Mercator limit are clamped, not infinite', () {
      const zoom = 10.0;
      final north = MapProjection.project(const LatLngPoint(89.9, 10), zoom);
      final south = MapProjection.project(const LatLngPoint(-89.9, 10), zoom);

      // Clamped to the top and bottom edge of the tile pyramid.
      expect(north.y, 0);
      expect(south.y, MapProjection.worldSize(zoom));
      expect(math.min(north.y, south.y), greaterThanOrEqualTo(0));
    });
  });

  group('address search results', () {
    test('parses a Nominatim response', () {
      const body = '''
[{"lat":"48.8584","lon":"2.2945","display_name":"Eiffel Tower, Paris, France"},
 {"lat":"bad","lon":"2.0","display_name":"Broken"},
 {"lat":"51.5007","lon":"-0.1246","display_name":"Big Ben, London"}]''';

      final results = GeocodingService.parseResults(body);
      expect(results.length, 2); // the malformed entry is skipped
      expect(results.first.label, contains('Eiffel Tower'));
      expect(results.first.lat, closeTo(48.8584, 1e-6));
      expect(results.last.lng, closeTo(-0.1246, 1e-6));
    });

    test('an empty or unexpected response is not an error', () {
      expect(GeocodingService.parseResults('[]'), isEmpty);
      expect(GeocodingService.parseResults('{"error":"x"}'), isEmpty);
    });
  });
}
