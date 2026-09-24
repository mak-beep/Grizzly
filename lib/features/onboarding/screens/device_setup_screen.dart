import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/device_repository.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/app_bar_title.dart';

/// Name a device and, with a linked family project, pair it with the
/// physical unit. The unit registers itself in Firestore the first time it
/// connects, so it normally appears under "Detected devices"; its ID can also
/// be copied from the Firebase console.
class DeviceSetupScreen extends ConsumerStatefulWidget {
  final DeviceType deviceType;

  const DeviceSetupScreen({super.key, required this.deviceType});

  @override
  ConsumerState<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends ConsumerState<DeviceSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _uuidCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _uuidCtrl.dispose();
    super.dispose();
  }

  bool get _needsRealDeviceId => ref.read(backendModeProvider) != null;

  Future<void> _finish() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(deviceRepositoryProvider);
    setState(() => _isSaving = true);
    try {
      await repo.registerDevice(
        type: widget.deviceType,
        name: _nameCtrl.text.trim(),
        uuid: _needsRealDeviceId ? _uuidCtrl.text : null,
      );
    } on DuplicateDeviceException {
      _fail(t.deviceUuidDuplicate);
      return;
    } on DeviceTypeMismatchException catch (e) {
      _fail(t.deviceTypeMismatch(e.actualType.localizedName(t)));
      return;
    } catch (e) {
      _fail(t.saveFailed(e.toString()));
      return;
    }

    ref.read(userProfileProvider.notifier).completeOnboarding();
    if (!mounted) return;
    // Replace the whole stack: popping would return to the "add a device"
    // step (asking again) and leave the dashboard unreachable by Back.
    context.goNamed(AppRoutes.dashboard);
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUuidHelp() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.deviceUuidHelpTitle),
        content: SingleChildScrollView(
          child: Text(t.deviceUuidHelpBody, style: const TextStyle(height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.continueButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repo = ref.watch(deviceRepositoryProvider);
    final showUuidField = ref.watch(backendModeProvider) != null;
    final detected = repo.detectedDevicesOfType(widget.deviceType);
    final selectedId = DeviceRepository.normalizeDeviceId(_uuidCtrl.text);

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(t.deviceSetupTitle(widget.deviceType.localizedName(t)))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.deviceSetupHeading,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(t.deviceSetupExample, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  autofocus: !showUuidField,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: t.deviceNameLabel),
                  validator: (v) => (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
                ),
                if (showUuidField) ...[
                  const SizedBox(height: 16),
                  Text(t.detectedDevicesTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (detected.isEmpty)
                    Text(t.detectedDevicesEmpty,
                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4))
                  else
                    for (final device in detected)
                      Card(
                        child: ListTile(
                          selected: device.id == selectedId,
                          leading: Icon(device.id == selectedId
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked),
                          onTap: () => setState(() => _uuidCtrl.text = device.id),
                          title: Text(device.id,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          subtitle: Text(device.lastSeen == null
                              ? t.waitingForFirstUpdate
                              : t.detectedDeviceSubtitle(relativeTime(device.lastSeen!, t))),
                        ),
                      ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _uuidCtrl,
                    autocorrect: false,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: t.deviceUuidLabel,
                      hintText: t.deviceUuidHint,
                      helperText: t.orEnterIdManually,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: _showUuidHelp,
                      ),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty || !repo.isValidDeviceUuid(value)) {
                        return t.deviceUuidInvalid;
                      }
                      if (repo.deviceIdExists(value)) return t.deviceUuidDuplicate;
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isSaving ? null : _finish,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(t.saveAndFinishButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
