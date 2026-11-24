import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/persistence_service.dart';

/// Runs once per launch: restores the linked backend, session, profile and
/// devices, then routes to the right screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _name = 'Grizzly';
  static const _animation = Duration(milliseconds: 1900);
  // The name animation always plays out, even when start-up is instant.
  static const _minimumShow = Duration(milliseconds: 2500);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _animation);
  late final Future<void> _minShow = Future<void>.delayed(_minimumShow);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _go(String routeName) async {
    await _minShow;
    if (!mounted) return;
    context.goNamed(routeName);
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final authService = ref.read(authServiceProvider);

    // 1. Re-link the family project first so the session is validated
    //    against real Firebase Auth, not the demo mock.
    final savedBackendMode = await PersistenceService.instance.loadBackendMode();
    final linked = savedBackendMode != null && await authService.relinkSavedBackendIfAny();
    ref.read(backendModeProvider.notifier).state = linked ? savedBackendMode : null;

    // 2. Session + this user's own profile.
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.restoreSession();
    final auth = ref.read(authNotifierProvider);

    if (auth.isSignedIn && auth.userId != null) {
      ref.read(userProfileProvider.notifier).bindToUser(auth.userId!);
      final savedProfile = await PersistenceService.instance.loadProfile(userId: auth.userId);
      if (savedProfile != null) {
        ref.read(userProfileProvider.notifier).restoreFrom(savedProfile);
      }
    }
    final profile = ref.read(userProfileProvider);
    if (!mounted) return;

    if (auth.isSignedIn && auth.userId != null) {
      // 3. Linked family: confirm membership (quietly continue offline).
      final family = ref.read(familyServiceProvider);
      if (linked && family != null) {
        try {
          await family
              .ensureMembership(
                uid: auth.userId!,
                email: auth.email ?? '',
                displayName: profile?.displayName ?? '',
              )
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          // Offline or slow network: the cached dashboard is still useful.
        }
      }

      await ref.read(deviceRepositoryProvider).loadForUser(
            auth.userId!,
            isLinkedToFirestore: linked,
            firestore: linked ? authService.firestore : null,
          );
      if (!mounted) return;

      if (profile == null) {
        await _go(AppRoutes.profileSetup);
      } else if (profile.hasCompletedOnboarding) {
        await _go(AppRoutes.dashboard);
      } else {
        await _go(AppRoutes.deviceTypeSelection);
      }
      return;
    }

    // This phone is already linked to the family project, so whoever opens
    // the app (after signing out, or when the saved session could not be
    // restored) only needs to sign in again. Their profile, consent and
    // devices are restored from their account on the sign-in screen; never
    // send them back through the whole setup.
    if (linked) {
      await _go(AppRoutes.auth);
      return;
    }

    if (profile == null) {
      await _go(AppRoutes.profileSetup);
    } else if (!profile.hasAcceptedPrivacyConsent) {
      await _go(AppRoutes.privacyConsent);
    } else {
      await _go(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final loader = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scales down on very narrow screens instead of overflowing.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _name.length; i++) _letter(i, t, scheme.onSurface),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(opacity: loader, child: const CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Letters rise and fade in one after another, left to right.
  Widget _letter(int index, double t, Color color) {
    final start = 0.05 + index * 0.1;
    final p = Curves.easeOutCubic.transform(((t - start) / 0.3).clamp(0.0, 1.0));
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - p)),
        child: Text(
          _name[index],
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: color,
          ),
        ),
      ),
    );
  }
}
