import 'dart:math' as math;

/// A latitude/longitude pair in degrees.
class LatLngPoint {
  final double lat;
  final double lng;

  const LatLngPoint(this.lat, this.lng);

  @override
  bool operator ==(Object other) => other is LatLngPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

/// Web Mercator (EPSG:3857) math used by OpenStreetMap slippy-map tiles.
class MapProjection {
  MapProjection._();

  static const double tileSize = 256;
  static const double maxLatitude = 85.05112878;
  static const double minZoom = 2;
  static const double maxZoom = 19;

  static double worldSize(double zoom) => tileSize * math.pow(2, zoom).toDouble();

  /// World pixel coordinates of [point] at [zoom].
  static math.Point<double> project(LatLngPoint point, double zoom) {
    final size = worldSize(zoom);
    final lat = point.lat.clamp(-maxLatitude, maxLatitude) * math.pi / 180;
    final x = (point.lng + 180) / 360 * size;
    final y = (1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2 * size;
    // Rounding at the clamp latitude can land a hair outside the pyramid.
    return math.Point(x, y.clamp(0.0, size));
  }

  static LatLngPoint unproject(math.Point<double> pixel, double zoom) {
    final size = worldSize(zoom);
    var lng = pixel.x / size * 360 - 180;
    lng = ((lng + 180) % 360 + 360) % 360 - 180;
    final n = math.pi * (1 - 2 * pixel.y / size);
    final lat = math.atan((math.exp(n) - math.exp(-n)) / 2) * 180 / math.pi;
    return LatLngPoint(lat.clamp(-maxLatitude, maxLatitude), lng);
  }

  /// Ground resolution at [lat] and [zoom].
  static double metersPerPixel(double lat, double zoom) =>
      156543.03392 * math.cos(lat * math.pi / 180) / math.pow(2, zoom);

  /// Great-circle distance in metres (same formula as the firmware).
  static double distanceMeters(LatLngPoint a, LatLngPoint b) {
    const earthRadius = 6371000.0;
    final dLat = (b.lat - a.lat) * math.pi / 180;
    final dLng = (b.lng - a.lng) * math.pi / 180;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.lat * math.pi / 180) *
            math.cos(b.lat * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  /// Zoom level at which a circle of [radiusMeters] fits in [viewportPixels].
  static double zoomToFit(double radiusMeters, double lat, double viewportPixels) {
    if (radiusMeters <= 0 || viewportPixels <= 0) return 15;
    final metersAcross = radiusMeters * 2.6;
    final zoom = math.log(156543.03392 * math.cos(lat * math.pi / 180) * viewportPixels /
            metersAcross) /
        math.ln2;
    return zoom.clamp(minZoom, 18.0);
  }
}
