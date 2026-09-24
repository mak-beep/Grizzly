// An unverified real (non-demo) account must never reach the dashboard or
// any other screen — the router redirect is the only thing enforcing that,
// so it is tested directly rather than trusted by inspection.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/models/user_profile.dart';
import 'package:geoguard_app/core/providers.dart';
import 'package:geoguard_app/core/services/auth_service.dart';
import 'package:geoguard_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts already "signed in", bypassing the real sign-up flow so the test
/// can drop straight into the state that matters: verified or not.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(bool verified) : super(AuthService()) {
    state = AuthState(
      isSignedIn: true,
      userId: 'u1',
      email: 'parent@example.com',
      isEmailVerified: verified,
    );
  }
}

class _FixedProfileNotifier extends UserProfileNotifier {
  _FixedProfileNotifier() {
    state = UserProfile(
      firstName: 'Alex',
      lastName: 'Doe',
      age: 40,
      hasAcceptedPrivacyConsent: true,
      hasCompletedOnboarding: true,
    );
  }
}

Future<void> _pump(WidgetTester tester, {required bool verified}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith((ref) => _FixedAuthNotifier(verified)),
      userProfileProvider.overrideWith((ref) => _FixedProfileNotifier()),
    ],
    child: const GrizzlyApp(),
  ));
  await tester.pump(); // splash
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

void main() {
  testWidgets('an unverified account is held on the verify-email screen, not the dashboard',
      (tester) async {
    await _pump(tester, verified: false);

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.text('My Devices'), findsNothing); // dashboard app bar title
  });

  testWidgets('a verified account reaches the dashboard normally', (tester) async {
    await _pump(tester, verified: true);

    expect(find.text('Verify your email'), findsNothing);
    expect(find.text('My Devices'), findsOneWidget);
  });
}
