import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/device.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/relative_time.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isGps = device.type == DeviceType.gpsTracker;
    final color = isGps ? AppTheme.gpsTrackerColor : AppTheme.alarmButtonColor;
    final icon = isGps ? Icons.gps_fixed : Icons.emergency_outlined;
    final status = deviceStatusLine(device, t, DateTime.now());
    final alarm = !isGps && device.alarmActive;
    final outside = isGps && device.geofence != null && device.geofenceStatus == GeofenceStatus.outside;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: alarm ? Theme.of(context).colorScheme.errorContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(device.type.localizedName(t),
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      alarm ? t.alarmActiveLabel : status.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: alarm
                            ? Theme.of(context).colorScheme.error
                            : (status.warning ? Colors.orange.shade800 : Colors.grey),
                        fontWeight: alarm || status.warning ? FontWeight.w600 : null,
                      ),
                    ),
                    if (outside) ...[
                      const SizedBox(height: 6),
                      Chip(
                        avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: Text(t.geofenceOutside, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ],
                ),
              ),
              _StatusDot(color: alarm ? Colors.red : status.dotColor),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceStatusLine {
  final String text;
  final Color dotColor;
  final bool warning;

  const DeviceStatusLine(this.text, this.dotColor, {this.warning = false});
}

/// One-line connection summary, shared by the dashboard and detail screens.
DeviceStatusLine deviceStatusLine(Device device, AppLocalizations t, DateTime now) {
  final seen = device.lastSeen;
  final ago = seen == null ? '' : relativeTime(seen, t, now: now);

  switch (device.connectivityAt(now)) {
    case DeviceConnectivity.neverSeen:
      return DeviceStatusLine(t.statusNeverConnected, Colors.grey.shade400);
    case DeviceConnectivity.online:
      return device.type == DeviceType.gpsTracker
          ? DeviceStatusLine(t.statusOnline(ago), Colors.green)
          : DeviceStatusLine(t.statusArmed(ago), Colors.green);
    case DeviceConnectivity.offline:
      return device.type == DeviceType.gpsTracker
          ? DeviceStatusLine(t.statusOffline(ago), Colors.grey.shade400, warning: true)
          : DeviceStatusLine(t.statusCheckInOverdue(ago), Colors.orange, warning: true);
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
