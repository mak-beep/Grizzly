import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../utils/json_parsing.dart';

class FamilyMember {
  final String uid;
  final String email;
  final String displayName;
  final String role;

  const FamilyMember({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isOwner => role == 'owner';
}

/// Family membership in the family's own Firebase project.
///
/// firestore.rules only give access to `families/family/**` to users listed
/// in `members`. The first person to sign up on a fresh project becomes the
/// owner; everyone who signs up after that joins as a member.
class FamilyService {
  FamilyService(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _family =>
      _db.collection('families').doc(AppConstants.sharedFamilyDocId);

  CollectionReference<Map<String, dynamic>> get _members => _family.collection('members');

  /// Makes sure the signed-in user is listed as a member. The first user of a
  /// fresh project becomes the owner; anyone else joins as a member.
  Future<void> ensureMembership({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final memberRef = _members.doc(uid);
    if ((await memberRef.get()).exists) return;

    final emailKey = normalizeEmail(email);
    final now = FieldValue.serverTimestamp();
    final family = await _family.get();

    if (!family.exists) {
      final batch = _db.batch()
        ..set(_family, {'ownerUid': uid, 'createdAt': now})
        ..set(memberRef, {
          'email': emailKey,
          'displayName': displayName,
          'role': 'owner',
          'joinedAt': now,
        });
      await batch.commit();
      return;
    }

    await memberRef.set({
      'email': emailKey,
      'displayName': displayName,
      'role': 'member',
      'joinedAt': now,
    });
  }

  Stream<List<FamilyMember>> watchMembers() => _members.snapshots().map((snapshot) {
        final members = snapshot.docs.map((doc) {
          final data = doc.data();
          return FamilyMember(
            uid: doc.id,
            email: parseString(data['email']) ?? '',
            displayName: parseString(data['displayName']) ?? '',
            role: parseString(data['role']) ?? 'member',
          );
        }).toList()
          ..sort((a, b) {
            if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
            return a.email.compareTo(b.email);
          });
        return members;
      });

  Future<void> removeMember(String uid) => _members.doc(uid).delete();
}
