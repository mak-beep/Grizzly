import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/alert_event.dart';
import '../../../core/models/device.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/map_projection.dart';
import '../../../core/widgets/osm_map.dart';
import '../../dashboard/widgets/device_card.dart';
import '../widgets/contacts_editor.dart';
import '../widgets/device_actions.dart';
import '../widgets/geofence_editor.dart';
import '../widgets/history_log_list.dart';
import '../../../core/widgets/app_bar_title.dart';

class GpsTrackerDetailScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const GpsTrackerDetailScreen({super.key, required this.deviceId});

  @override
  ConsumerState<GpsTrackerDetailScreen> createState() => _GpsTrackerDetailScreenState();
}

class _GpsTrackerDetailScreenState extends ConsumerState<GpsTrackerDetailScreen> {
  final _uuid = const Uuid();
  final _random = Random();
  final _mapController = OsmMapController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repo = ref.watch(deviceRepositoryProvider);
    final device = repo.deviceById(widget.deviceId);
    final isDemo = ref.watch(backendModeProvider) == null;

    if (device == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(t.deviceNotFound)));
    }

    final history = repo.historyFor(widget.deviceId);
    final position = device.hasLocation ? LatLngPoint(device.lastLat!, device.lastLng!) : null;
    final geofence = device.geofence;
    final route = history
        .where((e) => e.hasLocation)
        .take(100)
        .map((e) => LatLngPoint(e.lat!, e.lng!))
        .toList()
        .reversed
        .toList();
    final status = deviceStatusLine(device, t, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(device.name),
        actions: [DeviceActionsMenu(device: device)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(device: device, statusText: status.text, statusColor: status.dotColor),
          const SizedBox(height: 12),
          if (position == null && geofence == null)
            _NoLocationPlaceholder(text: t.waitingForFirstUpdate)
          else
            Stack(
              children: [
                OsmMap(
                  controller: _mapController,
                  initialCenter: position ?? LatLngPoint(geofence!.centerLat, geofence.centerLng),
                  initialZoom: geofence != null
                      ? MapProjection.zoomToFit(geofence.radiusMeters, geofence.centerLat, 260)
                      : 16,
                  height: 260,
                  polylines: [
                    if (route.length > 1)
                      MapPolyline(
                        points: route,
                        color: AppTheme.gpsTrackerColor.withValues(alpha: 0.6),
                      ),
                  ],
                  circles: [
                    if (geofence != null)
                      MapCircle(
                        center: LatLngPoint(geofence.centerLat, geofence.centerLng),
                        radiusMeters: geofence.radiusMeters,
                        color: device.geofenceStatus == GeofenceStatus.outside
                            ? Colors.deepOrange
                            : AppTheme.gpsTrackerColor,
                      ),
                  ],
                  markers: [
                    if (position != null)
                      MapMarker(point: position, color: AppTheme.gpsTrackerColor),
                  ],
                ),
                if (position != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter-${device.id}',
                      tooltip: t.recenterMapTooltip,
                      onPressed: () => _mapController.moveTo(position, zoom: 16),
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            t.pollingInfo(
              AppConstants.gpsPollingIntervalSeconds,
              AppConstants.gpsBatteryLifeMinDays,
              AppConstants.gpsBatteryLifeMaxDays,
            ),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GeofenceEditor(
            key: ValueKey('geofence-${device.id}-${geofence?.centerLat}-${geofence?.radiusMeters}'),
            initial: geofence,
            deviceLocation: position,
            onSave: (g) => repo.updateGeofence(device.id, g),
            onRemove: () => repo.updateGeofence(device.id, null),
          ),
          const SizedBox(height: 16),
          ContactsEditor(
            key: ValueKey('contacts-${device.id}'),
            initial: device.contacts,
            onSave: (contacts) => repo.setContacts(device.id, contacts),
          ),
          if (isDemo) ...[
            const SizedBox(height: 16),
            SimulatePanel(
              actions: [
                SimulateAction(
                  icon: Icons.location_on_outlined,
                  label: t.simulateLocationUpdate,
                  onPressed: () => _simulate(device, AlertEventType.locationPing),
                ),
                SimulateAction(
                  icon: Icons.warning_amber_rounded,
                  label: t.simulateGeofenceBreach,
                  onPressed: () => _simulate(device, AlertEventType.geofenceBreach),
                  destructive: true,
                ),
                SimulateAction(
                  icon: Icons.home_outlined,
                  label: t.simulateGeofenceReturn,
                  onPressed: () => _simulate(device, AlertEventType.geofenceReturn),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.historyTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const Divider(),
                  HistoryLogList(events: history),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Demo mode: moves the tracker the way firmware would report it.
  void _simulate(Device device, AlertEventType type) {
    final g = device.geofence;
    final baseLat = g?.centerLat ?? device.lastLat ?? 24.8607;
    final baseLng = g?.centerLng ?? device.lastLng ?? 67.0011;
    final offsetDeg = switch (type) {
      AlertEventType.geofenceBreach => ((g?.radiusMeters ?? 200) * 2) / 111000,
      AlertEventType.geofenceReturn => 0.0,
      _ => (_random.nextDouble() - 0.5) * 0.002,
    };

    ref.read(deviceRepositoryProvider).simulateEvent(AlertEvent(
          id: _uuid.v4(),
          deviceId: device.id,
          type: type,
          timestamp: DateTime.now(),
          lat: baseLat + offsetDeg,
          lng: baseLng + offsetDeg,
        ));
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.device, required this.statusText, required this.statusColor});

  final Device device;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (zoneText, zoneColor, zoneIcon) = device.geofence == null
        ? (t.geofenceNotSet, Colors.grey, Icons.radio_button_unchecked)
        : switch (device.geofenceStatus) {
            GeofenceStatus.inside => (t.geofenceInside, Colors.green, Icons.verified_user_outlined),
            GeofenceStatus.outside => (t.geofenceOutside, Colors.deepOrange, Icons.warning_amber_rounded),
            GeofenceStatus.unknown => (t.geofenceUnknown, Colors.grey, Icons.help_outline),
          };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Expanded(child: Text(statusText)),
                if (device.charging)
                  Chip(
                    avatar: const Icon(Icons.battery_charging_full, size: 16),
                    label: Text(t.chargingLabel, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(zoneIcon, size: 18, color: zoneColor),
                const SizedBox(width: 8),
                Text(zoneText, style: TextStyle(color: zoneColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoLocationPlaceholder extends StatelessWidget {
  const _NoLocationPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.gpsTrackerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 40, color: AppTheme.gpsTrackerColor),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
