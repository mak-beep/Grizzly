// The path a new user takes: sign up, add (or skip) the first device, close
// the app and open it again. Runs at a small phone width so any title or
// row that runs off the screen fails the test as an overflow.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/widgets/app_bar_title.dart';
import 'package:geoguard_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _launch(WidgetTester tester) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: ProviderContainer(),
    child: const GrizzlyApp(),
  ));
  await tester.pump();
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final f = find.text(text);
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Profile -> consent -> demo mode -> sign up. Ends on "Add your first device".
Future<void> _signUp(WidgetTester tester) async {
  await _launch(tester);
  await tester.enterText(find.widgetWithText(TextFormField, 'First name'), 'Alex');
  await tester.enterText(find.widgetWithText(TextFormField, 'Last name'), 'Doe');
  await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '40');
  await _tapText(tester, 'Continue');
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
  await _tapText(tester, 'I agree, continue');
  await tester.tap(find.byIcon(Icons.add_home_outlined));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byIcon(Icons.play_circle_outline));
  await tester.tap(find.byIcon(Icons.play_circle_outline));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
  await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123456');
  await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

void _smallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1920); // 300 x 640 logical
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  _titles();
  testWidgets('adding the first device lands on the dashboard, not on "add a device" again',
      (tester) async {
    _smallPhone(tester);
    SharedPreferences.setMockInitialValues({});
    await _signUp(tester);
    expect(find.textContaining('Add your first device'), findsOneWidget);

    await tester.tap(find.text('GPS Tracker'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Device name'), 'Backpack');
    await tester.tap(find.text('Save and finish'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('My Devices'), findsOneWidget);
    expect(find.textContaining('Add your first device'), findsNothing);
    expect(find.byType(BackButton), findsNothing); // nothing to go "back" to

    // Closing and reopening the app keeps the user on the dashboard.
    await tester.pumpWidget(const SizedBox());
    await _launch(tester);
    expect(find.text('My Devices'), findsOneWidget);
    expect(find.text('Backpack'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skipping the first device keeps the account and opens the dashboard next time',
      (tester) async {
    _smallPhone(tester);
    SharedPreferences.setMockInitialValues({});
    await _signUp(tester);

    await _tapText(tester, "Skip for now — I'll add a device later");
    expect(find.text('My Devices'), findsOneWidget);

    // Reopen: must NOT ask for the profile again.
    await tester.pumpWidget(const SizedBox());
    await _launch(tester);
    expect(find.text('My Devices'), findsOneWidget);
    expect(find.text("Let's personalize your account"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the app before adding any device resumes at the add-device step',
      (tester) async {
    _smallPhone(tester);
    SharedPreferences.setMockInitialValues({});
    await _signUp(tester);

    await tester.pumpWidget(const SizedBox());
    await _launch(tester);
    expect(find.textContaining('Add your first device'), findsOneWidget);
    expect(find.text("Let's personalize your account"), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _titles() {
  testWidgets('a long French title wraps inside the app bar instead of running off screen',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1280); // 240 x 427 logical
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        appBar: _Bar('Étape 5 sur 5 · Ajoutez votre premier appareil'),
      ),
    ));
    final size = tester.getSize(find.text('Étape 5 sur 5 · Ajoutez votre premier appareil'));
    expect(size.height, greaterThan(30)); // more than one line
    expect(tester.takeException(), isNull);
  });
}

class _Bar extends StatelessWidget implements PreferredSizeWidget {
  const _Bar(this.title);
  final String title;
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) =>
      AppBar(toolbarHeight: 64, title: AppBarTitle(title));
}
