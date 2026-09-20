import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/device.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_projection.dart';
import '../../../core/widgets/osm_map.dart';

/// Create or edit a safe zone: search an address (OpenStreetMap Nominatim),
/// use the phone's location, or tap the map; then choose a radius.
class GeofenceEditor extends StatefulWidget {
  final Geofence? initial;

  /// Last known tracker position, used to centre the map when no zone exists.
  final LatLngPoint? deviceLocation;
  final Future<void> Function(Geofence) onSave;
  final Future<void> Function() onRemove;
  final GeocodingService? geocoding;

  const GeofenceEditor({
    super.key,
    this.initial,
    this.deviceLocation,
    required this.onSave,
    required this.onRemove,
    this.geocoding,
  });

  @override
  State<GeofenceEditor> createState() => _GeofenceEditorState();
}

class _GeofenceEditorState extends State<GeofenceEditor> {
  late final GeocodingService _geocoding = widget.geocoding ?? GeocodingService();
  final _mapController = OsmMapController();
  late final TextEditingController _addressCtrl =
      TextEditingController(text: widget.initial?.addressLabel ?? '');

  late LatLngPoint? _center = widget.initial?.isValid == true
      ? LatLngPoint(widget.initial!.centerLat, widget.initial!.centerLng)
      : null;
  late double _radius = (widget.initial?.radiusMeters ?? AppConstants.geofenceDefaultRadiusMeters)
      .clamp(AppConstants.geofenceMinRadiusMeters, AppConstants.geofenceMaxRadiusMeters);

  bool _dirty = false;
  bool _busy = false;
  List<GeocodingResult> _results = const [];

  @override
  void dispose() {
    _addressCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _setCenter(LatLngPoint point, {String? label, bool moveMap = true}) {
    setState(() {
      _center = point;
      _dirty = true;
      _results = const [];
      if (label != null) _addressCtrl.text = label;
    });
    if (moveMap) {
      _mapController.moveTo(point, zoom: MapProjection.zoomToFit(_radius, point.lat, 240));
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _search() async {
    final t = AppLocalizations.of(context);
    final query = _addressCtrl.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() => _busy = true);
    try {
      final results =
          await _geocoding.search(query, languageCode: Localizations.localeOf(context).languageCode);
      if (!mounted) return;
      if (results.isEmpty) {
        _toast(t.searchNoResults);
      } else if (results.length == 1) {
        _setCenter(LatLngPoint(results.first.lat, results.first.lng), label: results.first.label);
      } else {
        setState(() => _results = results);
      }
    } catch (_) {
      _toast(t.searchFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _useMyLocation() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast(t.locationServicesOff);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toast(t.locationPermissionDenied);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      if (!mounted) return;
      _setCenter(LatLngPoint(position.latitude, position.longitude), label: t.currentLocationLabel);
    } catch (_) {
      _toast(t.locationUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final center = _center;
    if (center == null) {
      _toast(t.safeZoneNeedsCenter);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onSave(Geofence(
        centerLat: center.lat,
        centerLng: center.lng,
        addressLabel: _addressCtrl.text.trim(),
        radiusMeters: _radius.roundToDouble(),
      ));
      if (!mounted) return;
      setState(() => _dirty = false);
      _toast(t.safeZoneSaved);
    } catch (e) {
      _toast(t.saveFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await widget.onRemove();
      if (!mounted) return;
      setState(() {
        _center = null;
        _addressCtrl.clear();
        _dirty = false;
      });
      _toast(t.safeZoneRemoved);
    } catch (e) {
      _toast(t.saveFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final center = _center;
    final mapCenter = center ?? widget.deviceLocation;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.safeZoneTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: t.addressLabel,
                prefixIcon: const Icon(Icons.place_outlined),
                suffixIcon: IconButton(
                  tooltip: t.searchAddressTooltip,
                  icon: const Icon(Icons.search),
                  onPressed: _busy ? null : _search,
                ),
              ),
            ),
            for (final r in _results)
              ListTile(
                dense: true,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(r.label, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _setCenter(LatLngPoint(r.lat, r.lng), label: r.label),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : _useMyLocation,
                icon: const Icon(Icons.my_location),
                label: Text(t.useMyLocationButton),
              ),
            ),
            OsmMap(
              controller: _mapController,
              initialCenter: mapCenter ?? const LatLngPoint(20, 0),
              initialZoom: mapCenter == null
                  ? 2
                  : MapProjection.zoomToFit(_radius, mapCenter.lat, 240),
              height: 240,
              onTap: (point) => _setCenter(point, moveMap: false),
              circles: [
                if (center != null)
                  MapCircle(center: center, radiusMeters: _radius, color: AppTheme.gpsTrackerColor),
              ],
              markers: [
                if (widget.deviceLocation != null)
                  MapMarker(point: widget.deviceLocation!, color: AppTheme.gpsTrackerColor, size: 30),
                if (center != null)
                  MapMarker(point: center, color: Colors.deepOrange, icon: Icons.push_pin, size: 28),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.tapMapToSetCenter, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Text(t.radiusLabel(_radius.round())),
            Slider(
              value: _radius,
              min: AppConstants.geofenceMinRadiusMeters,
              max: AppConstants.geofenceMaxRadiusMeters,
              divisions: 39,
              label: '${_radius.round()} m',
              onChanged: (v) => setState(() {
                _radius = v;
                _dirty = true;
              }),
            ),
            Row(
              children: [
                if (widget.initial != null)
                  TextButton(
                    onPressed: _busy ? null : _remove,
                    child: Text(t.removeSafeZoneButton),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: (_busy || !_dirty || center == null) ? null : _save,
                  child: Text(t.saveSafeZoneButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
