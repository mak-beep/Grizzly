import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signOut();
    // The family project stays linked so another family member can sign in
    // on this phone; only this user's in-memory state is cleared.
    ref.read(userProfileProvider.notifier).clear();
    ref.read(deviceRepositoryProvider).reset();
    ref.invalidate(devicesProvider);
    if (context.mounted) context.goNamed(AppRoutes.auth);
  }

  Future<void> _disconnectBackend(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.disconnectBackendTitle),
        content: Text(t.disconnectBackendBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: Text(t.cancelButton)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t.disconnectBackendButton)),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authNotifierProvider.notifier).signOut();
    await ref.read(authServiceProvider).unlinkBackend();
    ref.read(userProfileProvider.notifier).clear();
    ref.read(backendModeProvider.notifier).state = null;
    ref.read(deviceRepositoryProvider).reset();
    ref.invalidate(devicesProvider);
    if (context.mounted) context.goNamed(AppRoutes.profileSetup);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profile = ref.watch(userProfileProvider);
    final notifier = ref.read(userProfileProvider.notifier);
    final auth = ref.watch(authNotifierProvider);
    final backendMode = ref.watch(backendModeProvider);
    final isAndroid = !kIsWeb && Platform.isAndroid;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(t.settingsScopeNote, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(profile.displayName),
            subtitle: Text('${t.ageLabel} ${profile.age}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(t.languageLabel),
            trailing: DropdownButton<String>(
              value: profile.languageCode,
              items: AppConstants.supportedLanguageCodes
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(AppLocalizations.nativeLanguageNames[code] ?? code),
                      ))
                  .toList(),
              onChanged: (code) {
                if (code != null) notifier.setLanguage(code);
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(t.darkThemeLabel),
            value: profile.isDarkTheme,
            onChanged: notifier.setDarkTheme,
          ),
          const Divider(),
          _SectionTitle(t.notificationsSectionTitle),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(t.alertStyleLabel),
            trailing: DropdownButton<AlertStyle>(
              value: profile.alertStyle,
              items: [
                DropdownMenuItem(value: AlertStyle.soundAndVibration, child: Text(t.alertStyleSound)),
                DropdownMenuItem(value: AlertStyle.vibrationOnly, child: Text(t.alertStyleVibrate)),
              ],
              onChanged: (style) {
                if (style != null) notifier.setAlertStyle(style);
              },
            ),
          ),
          if (isAndroid && backendMode != null)
            SwitchListTile(
              secondary: const Icon(Icons.sensors_outlined),
              title: Text(t.backgroundMonitoringLabel),
              subtitle: Text(t.backgroundMonitoringHint),
              value: profile.backgroundMonitoring,
              onChanged: notifier.setBackgroundMonitoring,
            ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: Text(t.testNotificationButton),
            onTap: () async {
              await NotificationService.instance.requestPermissions();
              await NotificationService.instance.showAlert(
                key: 'test-${DateTime.now().millisecondsSinceEpoch}',
                title: t.testNotificationTitle,
                body: t.testNotificationBody,
                urgent: true,
                style: profile.alertStyle,
              );
            },
          ),
          const Divider(),
          _SectionTitle(t.backendSectionTitle),
          ListTile(
            leading: Icon(backendMode == null ? Icons.science_outlined : Icons.cloud_done_outlined),
            title: Text(backendMode == null ? t.backendModeDemo : t.backendModeConnected(backendMode)),
          ),
          if (backendMode != null) ...[
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text(t.familyMembersTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(AppRoutes.familyMembers),
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: Text(t.securityRulesLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(AppRoutes.rulesView),
            ),
          ],
          const Divider(),
          _SectionTitle(t.legalSectionTitle),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.privacyConsentLabel),
            subtitle: Text(t.acceptedLabel),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const Divider(),
          _SectionTitle(t.accountSectionTitle),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(t.signedInAs(auth.email ?? '')),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(t.signOutButton, style: const TextStyle(color: Colors.redAccent)),
            onTap: () => _signOut(context, ref),
          ),
          if (backendMode != null)
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.redAccent),
              title: Text(t.disconnectBackendButton, style: const TextStyle(color: Colors.redAccent)),
              onTap: () => _disconnectBackend(context, ref),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
