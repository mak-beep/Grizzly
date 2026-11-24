// The setup screen tells the user whether the Firestore database can be
// reached at all. A refusal by the security rules still counts as "reached":
// only silence or a connection failure means the phone cannot talk to it.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguard_app/core/services/firestore_diagnostics.dart';

FirebaseException _error(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  test('an answer of any kind from the rules means Firestore is reachable', () async {
    expect(await isFirestoreReachable(() async => 'ok'), isTrue);
    expect(await isFirestoreReachable(() async => throw _error('permission-denied')), isTrue);
  });

  test('"unavailable", other failures and silence mean it is not reachable', () async {
    expect(await isFirestoreReachable(() async => throw _error('unavailable')), isFalse);
    expect(await isFirestoreReachable(() async => throw _error('not-found')), isFalse);
    expect(await isFirestoreReachable(() async => throw StateError('x')), isFalse);
    expect(
      await isFirestoreReachable(() => Completer<Object?>().future,
          timeout: const Duration(milliseconds: 50)),
      isFalse,
    );
  });

  test('the sign-up error from the bug report is recognised', () {
    expect(isUnreachableError(_error('unavailable')), isTrue);
    expect(isUnreachableError(_error('permission-denied')), isFalse);
    expect(isUnreachableError(StateError('x')), isFalse);
  });
}
