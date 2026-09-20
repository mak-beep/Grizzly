import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../utils/map_projection.dart';

class MapMarker {
  final LatLngPoint point;
  final Color color;
  final IconData icon;
  final double size;

  const MapMarker({
    required this.point,
    required this.color,
    this.icon = Icons.location_on,
    this.size = 36,
  });
}

class MapCircle {
  final LatLngPoint center;
  final double radiusMeters;
  final Color color;

  const MapCircle({required this.center, required this.radiusMeters, required this.color});
}

class MapPolyline {
  final List<LatLngPoint> points;
  final Color color;
  final double width;

  const MapPolyline({required this.points, required this.color, this.width = 3});
}

/// Moves an [OsmMap] from outside, e.g. after an address search.
class OsmMapController extends ChangeNotifier {
  LatLngPoint? _center;
  double? _zoom;

  void moveTo(LatLngPoint center, {double? zoom}) {
    _center = center;
    _zoom = zoom;
    notifyListeners();
  }
}

/// A lightweight OpenStreetMap view: raster tiles, pan and pinch-zoom, tap to
/// pick a point, markers, circles and a route line. OpenStreetMap needs no
/// API key, only an identifying User-Agent and the attribution shown in the
/// corner.
class OsmMap extends StatefulWidget {
  const OsmMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = 15,
    this.markers = const [],
    this.circles = const [],
    this.polylines = const [],
    this.onTap,
    this.controller,
    this.height = 240,
  });

  final LatLngPoint initialCenter;
  final double initialZoom;
  final List<MapMarker> markers;
  final List<MapCircle> circles;
  final List<MapPolyline> polylines;
  final ValueChanged<LatLngPoint>? onTap;
  final OsmMapController? controller;
  final double height;

  @override
  State<OsmMap> createState() => _OsmMapState();
}

class _OsmMapState extends State<OsmMap> {
  late LatLngPoint _center = widget.initialCenter;
  late double _zoom = widget.initialZoom.clamp(MapProjection.minZoom, MapProjection.maxZoom);
  Size _size = Size.zero;
  bool _userMoved = false;

  double _gestureZoom = 0;
  LatLngPoint _gestureCenter = const LatLngPoint(0, 0);
  Offset _gestureFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerMove);
  }

  @override
  void didUpdateWidget(covariant OsmMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerMove);
      widget.controller?.addListener(_onControllerMove);
    }
    // Follow live position updates until the user pans the map themselves.
    if (!_userMoved && oldWidget.initialCenter != widget.initialCenter) {
      _center = widget.initialCenter;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerMove);
    super.dispose();
  }

  void _onControllerMove() {
    final controller = widget.controller;
    if (controller == null) return;
    setState(() {
      if (controller._center != null) _center = controller._center!;
      if (controller._zoom != null) {
        _zoom = controller._zoom!.clamp(MapProjection.minZoom, MapProjection.maxZoom);
      }
    });
  }

  math.Point<double> _topLeft(double zoom, LatLngPoint center) {
    final c = MapProjection.project(center, zoom);
    return math.Point(c.x - _size.width / 2, c.y - _size.height / 2);
  }

  Offset _toScreen(LatLngPoint point) {
    final world = MapProjection.project(point, _zoom);
    final topLeft = _topLeft(_zoom, _center);
    return Offset(world.x - topLeft.x, world.y - topLeft.y);
  }

  LatLngPoint _toLatLng(Offset local, double zoom, LatLngPoint center) {
    final topLeft = _topLeft(zoom, center);
    return MapProjection.unproject(math.Point(topLeft.x + local.dx, topLeft.y + local.dy), zoom);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureZoom = _zoom;
    _gestureCenter = _center;
    _gestureFocal = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newZoom = (_gestureZoom + math.log(details.scale) / math.ln2)
        .clamp(MapProjection.minZoom, MapProjection.maxZoom);
    // Keep the point that was under the fingers under the fingers.
    final anchor = _toLatLng(_gestureFocal, _gestureZoom, _gestureCenter);
    final anchorWorld = MapProjection.project(anchor, newZoom);
    final centerWorld = math.Point(
      anchorWorld.x - (details.localFocalPoint.dx - _size.width / 2),
      anchorWorld.y - (details.localFocalPoint.dy - _size.height / 2),
    );
    setState(() {
      _userMoved = true;
      _zoom = newZoom;
      _center = MapProjection.unproject(centerWorld, newZoom);
    });
  }

  void _zoomBy(double delta) {
    setState(() {
      _userMoved = true;
      _zoom = (_zoom + delta).clamp(MapProjection.minZoom, MapProjection.maxZoom);
    });
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _zoomBy(event.scrollDelta.dy > 0 ? -0.5 : 0.5);
    }
  }

  List<Widget> _tiles() {
    if (_size.isEmpty) return const [];

    final tileZoom = _zoom.floor().clamp(0, 19);
    final scale = math.pow(2, _zoom - tileZoom).toDouble();
    final centerPx = MapProjection.project(_center, tileZoom.toDouble());
    final originX = centerPx.x - _size.width / 2 / scale;
    final originY = centerPx.y - _size.height / 2 / scale;
    final tileCount = 1 << tileZoom;
    const tile = MapProjection.tileSize;

    final firstX = (originX / tile).floor();
    final lastX = ((originX + _size.width / scale) / tile).floor();
    final firstY = math.max(0, (originY / tile).floor());
    final lastY = math.min(tileCount - 1, ((originY + _size.height / scale) / tile).floor());
    final displaySize = tile * scale;

    return [
      for (var y = firstY; y <= lastY; y++)
        for (var x = firstX; x <= lastX; x++)
          Positioned(
            left: (x * tile - originX) * scale,
            top: (y * tile - originY) * scale,
            width: displaySize + 0.5,
            height: displaySize + 0.5,
            child: _Tile(url: AppConstants.osmTileUrlTemplate
                .replaceAll('{z}', '$tileZoom')
                .replaceAll('{x}', '${x % tileCount}')
                .replaceAll('{y}', '$y')),
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _size = constraints.biggest;

            final circles = [
              for (final c in widget.circles)
                (
                  _toScreen(c.center),
                  c.radiusMeters / MapProjection.metersPerPixel(c.center.lat, _zoom),
                  c.color,
                ),
            ];
            final lines = [
              for (final l in widget.polylines)
                (l.points.map(_toScreen).toList(), l.color, l.width),
            ];

            return Listener(
              onPointerSignal: _onPointerSignal,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onDoubleTap: () => _zoomBy(1),
                onTapUp: widget.onTap == null
                    ? null
                    : (details) => widget.onTap!(_toLatLng(details.localPosition, _zoom, _center)),
                child: Stack(
                  children: [
                    const Positioned.fill(child: ColoredBox(color: Color(0xFFE5E3DF))),
                    ..._tiles(),
                    Positioned.fill(
                      child: CustomPaint(painter: _OverlayPainter(circles: circles, lines: lines)),
                    ),
                    for (final m in widget.markers)
                      Builder(builder: (_) {
                        final p = _toScreen(m.point);
                        return Positioned(
                          left: p.dx - m.size / 2,
                          top: p.dy - m.size,
                          child: IgnorePointer(
                            child: Icon(m.icon, color: m.color, size: m.size, shadows: const [
                              Shadow(color: Colors.black38, blurRadius: 4),
                            ]),
                          ),
                        );
                      }),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Column(
                        children: [
                          _ZoomButton(icon: Icons.add, onPressed: () => _zoomBy(1), scheme: scheme),
                          const SizedBox(height: 6),
                          _ZoomButton(
                              icon: Icons.remove, onPressed: () => _zoomBy(-1), scheme: scheme),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      key: ValueKey(url),
      headers: const {'User-Agent': AppConstants.osmUserAgent},
      fit: BoxFit.fill,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed, required this.scheme});

  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.circles, required this.lines});

  final List<(Offset, double, Color)> circles;
  final List<(List<Offset>, Color, double)> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (points, color, width) in lines) {
      if (points.length < 2) continue;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
    for (final (center, radius, color) in circles) {
      canvas.drawCircle(center, radius, Paint()..color = color.withValues(alpha: 0.15));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) => true;
}
