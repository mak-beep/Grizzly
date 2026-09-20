import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  _splash();
  testWidgets('a fresh install starts at the profile setup step', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: GrizzlyApp()));
    await tester.pump(); // splash
    await tester.pumpAndSettle();

    expect(find.text("Let's personalize your account"), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'First name'), findsOneWidget);
  });
}

void _splash() {
  testWidgets('the splash plays the name animation before moving on', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: GrizzlyApp()));
    await tester.pump();

    double opacityOf(String letter) => tester
        .widget<Opacity>(find.ancestor(of: find.text(letter), matching: find.byType(Opacity)).first)
        .opacity;

    // Start: letters hidden, then they appear one after another.
    expect(opacityOf('G'), lessThan(0.1));
    await tester.pump(const Duration(milliseconds: 800));
    final mid = opacityOf('G');
    expect(mid, greaterThan(0.1));
    expect(opacityOf('y'), lessThan(mid));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(opacityOf('y'), closeTo(1, 0.01));

    // Still on the splash until the minimum display time has passed.
    expect(find.text("Let's personalize your account"), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text("Let's personalize your account"), findsOneWidget);
  });
}
