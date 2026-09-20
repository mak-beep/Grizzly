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

enum MembershipResult {
  /// Signed-in user is a member of this family (possibly just joined).
  member,

  /// The family exists but nobody has invited this email yet.
  needsInvite,
}

/// Family membership in the family's own Firebase project.
///
/// firestore.rules only give access to `families/family/**` to users listed
/// in `members`. The first person to sign in on a fresh project becomes the
/// owner; everyone else joins with an invite created by an existing member
/// (adding someone as an emergency contact invites them automatically).
class FamilyService {
  FamilyService(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _family =>
      _db.collection('families').doc(AppConstants.sharedFamilyDocId);

  CollectionReference<Map<String, dynamic>> get _members => _family.collection('members');

  CollectionReference<Map<String, dynamic>> get _invites => _family.collection('invites');

  Future<MembershipResult> ensureMembership({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final memberRef = _members.doc(uid);
    if ((await memberRef.get()).exists) return MembershipResult.member;

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
      return MembershipResult.member;
    }

    final inviteRef = _invites.doc(emailKey);
    if ((await inviteRef.get()).exists) {
      await memberRef.set({
        'email': emailKey,
        'displayName': displayName,
        'role': 'member',
        'joinedAt': now,
      });
      try {
        await inviteRef.delete();
      } catch (_) {
        // The invite is harmless once used; members can clean it up later.
      }
      return MembershipResult.member;
    }

    return MembershipResult.needsInvite;
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

  Stream<List<String>> watchInvites() =>
      _invites.snapshots().map((snapshot) => snapshot.docs.map((d) => d.id).toList()..sort());

  Future<void> invite(String email, {required String invitedByUid}) {
    final key = normalizeEmail(email);
    return _invites.doc(key).set({
      'email': key,
      'invitedBy': invitedByUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Invites every email that does not already belong to a member.
  Future<void> inviteIfNotMembers(Iterable<String> emails, {required String invitedByUid}) async {
    final wanted = emails.map(normalizeEmail).where((e) => e.isNotEmpty).toSet();
    if (wanted.isEmpty) return;

    final members = await _members.get();
    final memberEmails =
        members.docs.map((d) => parseString(d.data()['email'])).whereType<String>().toSet();

    for (final email in wanted.difference(memberEmails)) {
      await invite(email, invitedByUid: invitedByUid);
    }
  }

  Future<void> revokeInvite(String email) => _invites.doc(normalizeEmail(email)).delete();

  Future<void> removeMember(String uid) => _members.doc(uid).delete();
}
