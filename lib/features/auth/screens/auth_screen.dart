import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/widgets/app_bar_title.dart';

/// Sign up or sign in. With a linked family project this is a real Firebase
/// account; afterwards the user's family membership is checked (the first
/// user of a new project becomes its owner, everyone after that joins as a member).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = true;
  bool _isSubmitting = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No profile on this phone yet → most likely a returning user.
      if (ref.read(userProfileProvider) == null && mounted) {
        setState(() => _isSignUp = false);
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _authErrorText(Object error) {
    if (error is FirebaseAuthException) return error.message ?? error.code;
    return error.toString();
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final t = AppLocalizations.of(context);

    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      if (_isSignUp) {
        await notifier.signUp(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      } else {
        await notifier.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      }
    } catch (e) {
      _showError(_authErrorText(e));
      return;
    }

    final auth = ref.read(authNotifierProvider);
    final userId = auth.userId!;
    final profileNotifier = ref.read(userProfileProvider.notifier)..bindToUser(userId);

    if (_isSignUp) {
      await PersistenceService.instance.claimPendingProfile(userId);
    }
    final savedProfile = await PersistenceService.instance.loadProfile(userId: userId);
    if (savedProfile != null) {
      profileNotifier.restoreFrom(savedProfile);
    }
    final profile = ref.read(userProfileProvider);

    final linked = ref.read(backendModeProvider) != null;
    final family = ref.read(familyServiceProvider);
    if (linked && family != null) {
      try {
        await family.ensureMembership(
          uid: userId,
          email: auth.email ?? _emailCtrl.text.trim(),
          displayName: profile?.displayName ?? '',
        );
      } catch (e) {
        _showError(t.familyCheckFailed(e.toString()));
        return;
      }
    }

    await ref.read(deviceRepositoryProvider).loadForUser(
          userId,
          isLinkedToFirestore: linked,
          firestore: linked ? ref.read(authServiceProvider).firestore : null,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (profile == null) {
      context.goNamed(AppRoutes.profileSetup);
    } else if (profile.hasCompletedOnboarding) {
      context.goNamed(AppRoutes.dashboard);
    } else {
      context.goNamed(AppRoutes.deviceTypeSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profile = ref.watch(userProfileProvider);
    final isMidOnboarding = profile != null && !profile.hasCompletedOnboarding;

    return Scaffold(
      appBar: isMidOnboarding
          ? AppBar(title: AppBarTitle(t.authStepTitle), automaticallyImplyLeading: false)
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMidOnboarding) ...[
                    const Icon(Icons.shield_outlined, size: 56),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    t.authWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? t.authSignUpSubtitle : t.authSignInSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: t.authEmailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '');
                      return valid ? null : t.authEmailInvalid;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _isSubmitting ? null : _submit(),
                    decoration: InputDecoration(
                      labelText: t.authPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? t.authPasswordTooShort : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? t.authSignUpButton : t.authSignInButton),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp ? t.authToggleToSignIn : t.authToggleToSignUp),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t.authIndividualNote,
                              style: const TextStyle(fontSize: 12, height: 1.3)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
