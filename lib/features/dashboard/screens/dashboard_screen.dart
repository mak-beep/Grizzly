import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../widgets/device_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Alerts need notification permission (Android 13+, iOS).
    unawaited(NotificationService.instance.requestPermissions());
    // Keep "last seen" / online status current without new data arriving.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _openAddDevice() => context.pushNamed(AppRoutes.deviceTypeSelection, extra: false);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repo = ref.watch(deviceRepositoryProvider);
    final devices = repo.allDevices;
    final detectedCount = repo.detectedDevices.length;
    final backendMode = ref.watch(backendModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.dashboardTitle),
        bottom: backendMode == null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(22),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Chip(
                    label: Text(t.backendModeDemo, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (repo.lastSyncError != null)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off_outlined),
                content: Text(t.syncErrorBanner),
                actions: [
                  TextButton(
                    onPressed: () => context.pushNamed(AppRoutes.rulesView),
                    child: Text(t.securityRulesLabel),
                  ),
                ],
              ),
            if (detectedCount > 0)
              ListTile(
                tileColor: Theme.of(context).colorScheme.secondaryContainer,
                leading: const Icon(Icons.sensors),
                title: Text(t.newDevicesDetected(detectedCount)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openAddDevice,
              ),
            Expanded(
              child: devices.isEmpty
                  ? _EmptyState(onAddDevice: _openAddDevice)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final device = devices[i];
                        return DeviceCard(
                          device: device,
                          onTap: () => context.pushNamed(
                            device.type == DeviceType.gpsTracker
                                ? AppRoutes.gpsTrackerDetail
                                : AppRoutes.alarmButtonDetail,
                            pathParameters: {'id': device.id},
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: devices.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddDevice,
              icon: const Icon(Icons.add),
              label: Text(t.addDeviceButton),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddDevice;
  const _EmptyState({required this.onAddDevice});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.devices_other, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(t.emptyStateTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(t.emptyStateSubtitle,
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddDevice,
              icon: const Icon(Icons.add),
              label: Text(t.addFirstDeviceButton),
            ),
          ],
        ),
      ),
    );
  }
}
