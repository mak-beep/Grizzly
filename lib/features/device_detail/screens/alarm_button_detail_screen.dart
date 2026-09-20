import 'dart:async';

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
import '../widgets/history_log_list.dart';

class AlarmButtonDetailScreen extends ConsumerStatefulWidget {
  final String deviceId;
  const AlarmButtonDetailScreen({super.key, required this.deviceId});

  @override
  ConsumerState<AlarmButtonDetailScreen> createState() => _AlarmButtonDetailScreenState();
}

class _AlarmButtonDetailScreenState extends ConsumerState<AlarmButtonDetailScreen> {
  final _uuid = const Uuid();
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
    final isActive = device.alarmActive;
    final status = deviceStatusLine(device, t, DateTime.now());
    final position = device.hasLocation ? LatLngPoint(device.lastLat!, device.lastLng!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [DeviceActionsMenu(device: device)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(
            isActive: isActive,
            statusText: status.text,
            warning: status.warning,
            charging: device.charging,
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Text(t.liveLocationTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            if (position == null)
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.alarmButtonColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(t.waitingForAlarmLocation, style: const TextStyle(color: Colors.grey)),
                ),
              )
            else
              OsmMap(
                initialCenter: position,
                initialZoom: 16,
                height: 240,
                markers: [
                  MapMarker(point: position, color: AppTheme.alarmButtonColor, icon: Icons.emergency),
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
                  Text(t.howItWorksTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.visibility_off_outlined, text: t.alarmInfoSilent),
                  _InfoRow(icon: Icons.emergency, text: t.alarmInfoTrigger),
                  _InfoRow(
                    icon: Icons.lock_outline,
                    text: t.alarmInfoDeactivate(
                      AppConstants.alarmDeactivationPressCount,
                      AppConstants.alarmDeactivationWindowSeconds,
                    ),
                  ),
                  _InfoRow(icon: Icons.favorite_outline, text: t.alarmInfoCheckIn),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ContactsEditor(
            key: ValueKey('contacts-${device.id}'),
            initial: device.contacts,
            onSave: (contacts) => saveContactsAndInvite(ref, device.id, contacts),
          ),
          if (isDemo) ...[
            const SizedBox(height: 16),
            SimulatePanel(
              actions: [
                SimulateAction(
                  icon: Icons.emergency,
                  label: t.simulateButtonPress,
                  onPressed: isActive ? null : () => _simulate(device, AlertEventType.alarmTriggered),
                  destructive: true,
                ),
                SimulateAction(
                  icon: Icons.lock_open_outlined,
                  label: t.simulateDeactivation(AppConstants.alarmDeactivationPressCount),
                  onPressed: isActive ? () => _simulate(device, AlertEventType.alarmCancelled) : null,
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

  void _simulate(Device device, AlertEventType type) {
    final hasFix = type == AlertEventType.alarmTriggered;
    ref.read(deviceRepositoryProvider).simulateEvent(AlertEvent(
          id: _uuid.v4(),
          deviceId: device.id,
          type: type,
          timestamp: DateTime.now(),
          lat: hasFix ? 24.8607 : null,
          lng: hasFix ? 67.0011 : null,
        ));
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isActive;
  final String statusText;
  final bool warning;
  final bool charging;

  const _StatusBanner({
    required this.isActive,
    required this.statusText,
    required this.warning,
    required this.charging,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = isActive ? AppTheme.alarmButtonColor : (warning ? Colors.orange : Colors.green);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isActive ? Icons.emergency : Icons.shield_outlined, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? t.alarmActiveLabel : t.standingByLabel,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(statusText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (charging) const Icon(Icons.battery_charging_full, color: Colors.grey),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
  }
}
