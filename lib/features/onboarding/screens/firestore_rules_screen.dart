import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar_title.dart';

/// Shows the bundled firestore.rules so the family can publish them in the
/// Firebase console. Shown once for a new family, and from Settings when the
/// rules need updating.
class FirestoreRulesScreen extends StatefulWidget {
  const FirestoreRulesScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  State<FirestoreRulesScreen> createState() => _FirestoreRulesScreenState();
}

class _FirestoreRulesScreenState extends State<FirestoreRulesScreen> {
  String? _rulesText;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    try {
      final text = await DefaultAssetBundle.of(context).loadString('firestore.rules');
      if (!mounted) return;
      setState(() => _rulesText = text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  Future<void> _copyToClipboard() async {
    final text = _rulesText;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).rulesCopiedToast)));
  }

  Future<void> _downloadOrShare() async {
    final text = _rulesText;
    if (text == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/firestore.rules');
      await file.writeAsString(text);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'firestore.rules'));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).rulesDownloadFailed)));
    }
  }

  void _continue() {
    if (widget.fromSettings) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(t.firestoreRulesStepTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.firestoreRulesHeading,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(t.firestoreRulesBody, style: const TextStyle(color: Colors.grey, height: 1.4)),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _rulesText != null
                      ? Scrollbar(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _rulesText!,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12, height: 1.4),
                            ),
                          ),
                        )
                      : _loadError != null
                          ? Center(child: Text(t.rulesLoadFailed))
                          : const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rulesText == null ? null : _copyToClipboard,
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(t.copyRulesButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rulesText == null ? null : _downloadOrShare,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(t.downloadRulesButton),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _continue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(widget.fromSettings ? t.doneButton : t.rulesDeployedContinueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
