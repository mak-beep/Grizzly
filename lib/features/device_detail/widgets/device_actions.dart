import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/device.dart';
import '../../../core/providers.dart';

enum _DeviceAction { rename, showId, repair, remove }

/// App bar menu shared by both device screens.
class DeviceActionsMenu extends ConsumerWidget {
  const DeviceActionsMenu({super.key, required this.device});

  final Device device;

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: device.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.renameDeviceTitle),
        content: TextField(controller: ctrl, autofocus: true, maxLength: 40),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t.cancelButton)),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: Text(t.saveButton),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (newName == null || newName.isEmpty) return;
    try {
      await ref.read(deviceRepositoryProvider).renameDevice(device.id, newName);
    } catch (e) {
      if (context.mounted) _toast(context, t.saveFailed(e.toString()));
    }
  }

  Future<void> _showId(BuildContext context) async {
    final t = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deviceUuidLabel),
        content: SelectableText(device.id, style: const TextStyle(fontFamily: 'monospace')),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: device.id));
              Navigator.pop(dialogContext);
            },
            child: Text(t.copyRulesButton),
          ),
        ],
      ),
    );
  }

  Future<void> _repair(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.repairDeviceTitle),
        content: Text(t.repairDeviceBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: Text(t.cancelButton)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: Text(t.repairButton)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(deviceRepositoryProvider).repairDevice(device.id);
      if (context.mounted) _toast(context, t.repairDone);
    } catch (e) {
      if (context.mounted) _toast(context, t.saveFailed(e.toString()));
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.removeDeviceQuestion),
        content: Text(t.removeDeviceBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: Text(t.cancelButton)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: Text(t.removeButton)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    try {
      await ref.read(deviceRepositoryProvider).removeDevice(device.id);
      if (navigator.canPop()) navigator.pop();
    } catch (e) {
      if (context.mounted) _toast(context, t.saveFailed(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final linked = ref.watch(backendModeProvider) != null;

    return PopupMenuButton<_DeviceAction>(
      onSelected: (action) => switch (action) {
        _DeviceAction.rename => _rename(context, ref),
        _DeviceAction.showId => _showId(context),
        _DeviceAction.repair => _repair(context, ref),
        _DeviceAction.remove => _remove(context, ref),
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: _DeviceAction.rename, child: Text(t.renameDeviceTitle)),
        PopupMenuItem(value: _DeviceAction.showId, child: Text(t.deviceUuidLabel)),
        if (linked) PopupMenuItem(value: _DeviceAction.repair, child: Text(t.repairDeviceTitle)),
        PopupMenuItem(value: _DeviceAction.remove, child: Text(t.removeThisDeviceButton)),
      ],
    );
  }
}

class SimulateAction {
  const SimulateAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
}

/// Demo mode only: drives the same data path real firmware events use.
class SimulatePanel extends StatelessWidget {
  const SimulatePanel({super.key, required this.actions});

  final List<SimulateAction> actions;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 18),
                const SizedBox(width: 8),
                Text(t.testWithoutHardwareTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.testWithoutHardwareBody, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in actions)
                  OutlinedButton.icon(
                    style: a.destructive
                        ? OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error)
                        : null,
                    onPressed: a.onPressed,
                    icon: Icon(a.icon),
                    label: Text(a.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
