import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// Reused both during first-time onboarding AND later from the dashboard's
/// "Add device" button — registering a 2nd, 3rd, 10th device follows the
/// exact same path, independent of any device already configured.
class DeviceTypeSelectionScreen extends StatelessWidget {
  final bool isFirstDevice;

  const DeviceTypeSelectionScreen({super.key, this.isFirstDevice = true});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isFirstDevice ? t.deviceTypeStepTitleFirst : t.deviceTypeStepTitleAdd),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.deviceTypeHeading,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                t.deviceTypeSubtext,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _DeviceTypeTile(
                type: DeviceType.gpsTracker,
                title: t.deviceTypeGpsName,
                subtitle: t.gpsTrackerSubtitle,
                onTap: () => context.pushNamed(
                  AppRoutes.deviceSetup,
                  extra: DeviceType.gpsTracker,
                ),
              ),
              const SizedBox(height: 16),
              _DeviceTypeTile(
                type: DeviceType.alarmButton,
                title: t.deviceTypeAlarmName,
                subtitle: t.alarmButtonSubtitle,
                onTap: () => context.pushNamed(
                  AppRoutes.deviceSetup,
                  extra: DeviceType.alarmButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceTypeTile extends StatelessWidget {
  final DeviceType type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DeviceTypeTile({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == DeviceType.gpsTracker
        ? AppTheme.gpsTrackerColor
        : AppTheme.alarmButtonColor;
    final icon =
        type == DeviceType.gpsTracker ? Icons.gps_fixed : Icons.emergency_outlined;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
