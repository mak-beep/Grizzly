import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

// Each family's own Firebase project is linked at runtime with the values
// entered during onboarding (BackendSetupScreen), not baked in at build time.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: GrizzlyApp()));
}

class GrizzlyApp extends ConsumerWidget {
  const GrizzlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final profile = ref.watch(userProfileProvider);

    // App-wide background work: turning device alerts into notifications,
    // and (Android) keeping that alive while the app is in the background.
    ref.watch(alertMonitorProvider);
    ref.watch(backgroundMonitoringProvider);

    return MaterialApp.router(
      title: 'Grizzly',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: (profile?.isDarkTheme ?? false) ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(profile?.languageCode ?? 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
