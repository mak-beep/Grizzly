import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/family_service.dart';

/// Shown when someone signs in to a family project that already exists but
/// has not invited their email yet.
class WaitingForInviteScreen extends ConsumerStatefulWidget {
  const WaitingForInviteScreen({super.key});

  @override
  ConsumerState<WaitingForInviteScreen> createState() => _WaitingForInviteScreenState();
}

class _WaitingForInviteScreenState extends ConsumerState<WaitingForInviteScreen> {
  bool _checking = false;

  Future<void> _checkAgain() async {
    final t = AppLocalizations.of(context);
    final auth = ref.read(authNotifierProvider);
    final family = ref.read(familyServiceProvider);
    if (auth.userId == null || family == null) return;

    setState(() => _checking = true);
    try {
      final profile = ref.read(userProfileProvider);
      final result = await family.ensureMembership(
        uid: auth.userId!,
        email: auth.email ?? '',
        displayName: profile?.displayName ?? '',
      );
      if (!mounted) return;
      if (result == MembershipResult.member) {
        await ref.read(deviceRepositoryProvider).loadForUser(
              auth.userId!,
              isLinkedToFirestore: true,
              firestore: ref.read(authServiceProvider).firestore,
            );
        if (!mounted) return;
        if (profile == null) {
          context.goNamed(AppRoutes.profileSetup);
        } else if (profile.hasCompletedOnboarding) {
          context.goNamed(AppRoutes.dashboard);
        } else {
          context.goNamed(AppRoutes.deviceTypeSelection);
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stillNotInvited)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.familyCheckFailed(e.toString()))));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    ref.read(userProfileProvider.notifier).clear();
    ref.read(deviceRepositoryProvider).reset();
    if (mounted) context.goNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final email = ref.watch(authNotifierProvider).email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(t.waitingInviteTitle), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                t.waitingInviteHeading,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                t.waitingInviteBody(email),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _checking ? null : _checkAgain,
                icon: _checking
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(t.checkAgainButton),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _signOut, child: Text(t.signOutButton)),
            ],
          ),
        ),
      ),
    );
  }
}
