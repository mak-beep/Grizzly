import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';

/// Connect the family's own Firebase project. Runs BEFORE sign-up so the
/// account is created in that project.
class BackendSetupScreen extends ConsumerStatefulWidget {
  final bool isNewFamily;
  const BackendSetupScreen({super.key, this.isNewFamily = true});

  @override
  ConsumerState<BackendSetupScreen> createState() => _BackendSetupScreenState();
}

class _BackendSetupScreenState extends ConsumerState<BackendSetupScreen> {
  final _projectIdCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _appIdCtrl = TextEditingController();
  final _senderIdCtrl = TextEditingController();
  bool _isLinking = false;

  @override
  void dispose() {
    _projectIdCtrl.dispose();
    _apiKeyCtrl.dispose();
    _appIdCtrl.dispose();
    _senderIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _linkAndContinue() async {
    final t = AppLocalizations.of(context);
    final projectId = _projectIdCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    final appId = _appIdCtrl.text.trim();
    final senderId = _senderIdCtrl.text.trim();

    if (projectId.isEmpty || apiKey.isEmpty || appId.isEmpty || senderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.backendFieldsRequired)));
      return;
    }

    setState(() => _isLinking = true);
    final result = await ref.read(authServiceProvider).linkFamilyFirebaseProject(
          projectId: projectId,
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: senderId,
        );
    if (!mounted) return;
    setState(() => _isLinking = false);

    switch (result) {
      case BackendLinkResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.backendLinkFailed)));
        return;
      case BackendLinkResult.restartRequired:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.backendRestartRequired)));
        return;
      case BackendLinkResult.linked:
        break;
    }

    ref.read(backendModeProvider.notifier).state = projectId;

    if (widget.isNewFamily) {
      context.goNamed(AppRoutes.firestoreRulesSetup);
    } else {
      context.goNamed(AppRoutes.auth);
    }
  }

  void _continueInDemoMode() {
    ref.read(backendModeProvider.notifier).state = null;
    context.goNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final steps = widget.isNewFamily
        ? [
            t.backendGuideStep1,
            t.backendGuideStep2,
            t.backendGuideStep3,
            t.backendGuideStep4,
            t.backendGuideStep5,
            t.backendGuideStep6,
          ]
        : [t.backendJoinGuideStep1, t.backendJoinGuideStep2];

    return Scaffold(
      appBar: AppBar(title: Text(widget.isNewFamily ? t.backendStepTitle : t.backendJoinStepTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isNewFamily ? t.backendHeading : t.backendJoinHeading,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isNewFamily ? t.backendBody : t.backendJoinBody,
                style: const TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < steps.length; i++) _GuideStep(number: i + 1, text: steps[i]),
              const SizedBox(height: 8),
              TextField(
                controller: _projectIdCtrl,
                autocorrect: false,
                decoration: InputDecoration(labelText: t.backendProjectIdLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKeyCtrl,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: t.backendApiKeyLabel,
                  suffixIcon: const Icon(Icons.lock_outline, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _appIdCtrl,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: t.backendAppIdLabel,
                  helperText: t.backendAppIdHelper,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senderIdCtrl,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.backendSenderIdLabel,
                  helperText: t.backendSenderIdHelper,
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLinking ? null : _linkAndContinue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _isLinking
                      ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(t.backendLinkButton),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.backendDemoDividerLabel, style: const TextStyle(color: Colors.grey)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(t.backendDemoTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(t.backendDemoBody, style: const TextStyle(height: 1.4, fontSize: 13)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLinking ? null : _continueInDemoMode,
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(t.backendDemoButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final int number;
  final String text;
  const _GuideStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text('$number', style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
