import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar_title.dart';

class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  bool _agreed = false;

  void _accept() {
    ref.read(userProfileProvider.notifier).acceptPrivacyConsent();
    // Already signed in (e.g. a family member setting up this phone after
    // signing in): the backend is linked, continue with devices.
    if (ref.read(authNotifierProvider).isSignedIn) {
      context.goNamed(AppRoutes.deviceTypeSelection);
    } else {
      context.goNamed(AppRoutes.familyChoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(t.privacyStepTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.privacy_tip_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                t.privacyHeading,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(t.privacyBody, style: const TextStyle(height: 1.5)),
                ),
              ),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(t.privacyCheckboxLabel),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _agreed ? _accept : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(t.privacyAgreeButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
