import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Tells "Firestore answered" apart from "Firestore could not be reached".
///
/// A signed-out read of the family document is refused by the security rules
/// (`permission-denied`), and that refusal is exactly what proves the
/// database exists and the network path works. Only a timeout, an
/// `unavailable` error or another failure to get any answer means the phone
/// cannot talk to Firestore at all (database not created, blocked network, ...).
Future<bool> isFirestoreReachable(
  Future<Object?> Function() read, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    await read().timeout(timeout);
    return true;
  } on FirebaseException catch (e) {
    return e.code == 'permission-denied';
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  }
}

/// Reads the family document straight from the server (never the cache).
Future<bool> probeFirestore(FirebaseFirestore db) => isFirestoreReachable(
      () => db
          .collection('families')
          .doc('family')
          .get(const GetOptions(source: Source.server)),
    );

/// True for the "no connection to Firestore" family of errors.
bool isUnreachableError(Object error) =>
    error is FirebaseException && (error.code == 'unavailable' || error.code == 'deadline-exceeded');
