import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';

/// Shown after sign-up (and on every launch until confirmed) for a real
/// Firebase account whose email address hasn't been verified yet. There is
/// no way around this screen other than opening the link Firebase emailed,
/// or signing out — the router redirects here from everywhere else.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final verified = await ref.read(authNotifierProvider.notifier).refreshEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!verified) {
      _toast(AppLocalizations.of(context).verifyEmailStillUnverified);
      return;
    }
    final profile = ref.read(userProfileProvider);
    if (profile == null) {
      context.goNamed(AppRoutes.profileSetup);
    } else if (profile.hasCompletedOnboarding) {
      context.goNamed(AppRoutes.dashboard);
    } else {
      context.goNamed(AppRoutes.deviceTypeSelection);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    String? message;
    try {
      await ref.read(authNotifierProvider.notifier).resendVerificationEmail();
      message = mounted ? AppLocalizations.of(context).verifyEmailResent : null;
    } catch (e) {
      message = mounted ? AppLocalizations.of(context).saveFailed(e.toString()) : null;
    } finally {
      if (mounted) setState(() => _resending = false);
    }
    if (message != null) _toast(message);
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.goNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final email = ref.watch(authNotifierProvider).email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 56),
                const SizedBox(height: 20),
                Text(
                  t.verifyEmailTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  t.verifyEmailBody(email),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _checking ? null : _checkNow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _checking
                        ? const SizedBox(
                            height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(t.verifyEmailContinueButton),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _resending ? null : _resend,
                  child: Text(t.verifyEmailResendButton),
                ),
                const SizedBox(height: 16),
                TextButton(onPressed: _signOut, child: Text(t.verifyEmailSignOutButton)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
