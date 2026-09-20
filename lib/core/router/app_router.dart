import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../providers.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/device_detail/screens/alarm_button_detail_screen.dart';
import '../../features/device_detail/screens/gps_tracker_detail_screen.dart';
import '../../features/onboarding/screens/backend_setup_screen.dart';
import '../../features/onboarding/screens/device_setup_screen.dart';
import '../../features/onboarding/screens/device_type_selection_screen.dart';
import '../../features/onboarding/screens/family_choice_screen.dart';
import '../../features/onboarding/screens/firestore_rules_screen.dart';
import '../../features/onboarding/screens/privacy_consent_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/waiting_for_invite_screen.dart';
import '../../features/settings/screens/family_members_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = 'splash';
  static const auth = 'auth';
  static const profileSetup = 'profileSetup';
  static const privacyConsent = 'privacyConsent';
  static const familyChoice = 'familyChoice';
  static const backendSetup = 'backendSetup';
  static const firestoreRulesSetup = 'firestoreRulesSetup';
  static const waitingForInvite = 'waitingForInvite';
  static const deviceTypeSelection = 'deviceTypeSelection';
  static const deviceSetup = 'deviceSetup';
  static const dashboard = 'dashboard';
  static const gpsTrackerDetail = 'gpsTrackerDetail';
  static const alarmButtonDetail = 'alarmButtonDetail';
  static const settings = 'settings';
  static const familyMembers = 'familyMembers';
  static const rulesView = 'rulesView';
}

/// Onboarding order:
///   Splash → Profile → Consent → FamilyChoice → Backend
///     → [new family: FirestoreRules] → Auth → [needs invite: WaitingForInvite]
///     → Device type → Device setup → Dashboard
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final profile = ref.read(userProfileProvider);
      final loc = state.matchedLocation;

      final goingToAuth = loc == '/auth';
      final goingToCoreOnboarding = loc == '/onboarding/profile' ||
          loc == '/onboarding/consent' ||
          loc == '/onboarding/family-choice' ||
          loc == '/onboarding/backend-setup' ||
          loc == '/onboarding/firestore-rules';
      final goingToSignedInOnboarding = loc == '/onboarding/device-type' ||
          loc == '/onboarding/device-setup' ||
          loc == '/onboarding/waiting-invite';
      final goingToProtected =
          loc == '/dashboard' || loc.startsWith('/device/') || loc.startsWith('/settings');

      if (auth.isSignedIn && profile != null && profile.hasCompletedOnboarding) {
        if (loc == '/' || goingToAuth || goingToCoreOnboarding) return '/dashboard';
        return null;
      }

      if (auth.isSignedIn) {
        // A signed-in user without a profile on this phone (e.g. a second
        // family member signing in on a shared phone) completes it first.
        if (profile == null && loc != '/onboarding/profile' && loc != '/onboarding/consent') {
          return '/onboarding/profile';
        }
        if (loc == '/' || goingToAuth) return '/onboarding/device-type';
        return null;
      }

      if (goingToAuth || goingToCoreOnboarding) return null;
      if (goingToSignedInOnboarding || goingToProtected) return '/auth';
      return null;
    },
    routes: [
      GoRoute(path: '/', name: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', name: AppRoutes.auth, builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: '/onboarding/profile',
        name: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/consent',
        name: AppRoutes.privacyConsent,
        builder: (_, __) => const PrivacyConsentScreen(),
      ),
      GoRoute(
        path: '/onboarding/family-choice',
        name: AppRoutes.familyChoice,
        builder: (_, __) => const FamilyChoiceScreen(),
      ),
      GoRoute(
        path: '/onboarding/backend-setup',
        name: AppRoutes.backendSetup,
        builder: (_, state) => BackendSetupScreen(isNewFamily: (state.extra as bool?) ?? true),
      ),
      GoRoute(
        path: '/onboarding/firestore-rules',
        name: AppRoutes.firestoreRulesSetup,
        builder: (_, __) => const FirestoreRulesScreen(),
      ),
      GoRoute(
        path: '/onboarding/waiting-invite',
        name: AppRoutes.waitingForInvite,
        builder: (_, __) => const WaitingForInviteScreen(),
      ),
      GoRoute(
        path: '/onboarding/device-type',
        name: AppRoutes.deviceTypeSelection,
        builder: (_, state) =>
            DeviceTypeSelectionScreen(isFirstDevice: (state.extra as bool?) ?? true),
      ),
      GoRoute(
        path: '/onboarding/device-setup',
        name: AppRoutes.deviceSetup,
        builder: (_, state) => DeviceSetupScreen(deviceType: state.extra as DeviceType),
      ),
      GoRoute(
        path: '/dashboard',
        name: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/device/gps/:id',
        name: AppRoutes.gpsTrackerDetail,
        builder: (_, state) => GpsTrackerDetailScreen(deviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/device/alarm/:id',
        name: AppRoutes.alarmButtonDetail,
        builder: (_, state) => AlarmButtonDetailScreen(deviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/family',
        name: AppRoutes.familyMembers,
        builder: (_, __) => const FamilyMembersScreen(),
      ),
      GoRoute(
        path: '/settings/rules',
        name: AppRoutes.rulesView,
        builder: (_, __) => const FirestoreRulesScreen(fromSettings: true),
      ),
    ],
  );
});
