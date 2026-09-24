import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/services/family_service.dart';
import '../../../core/widgets/app_bar_title.dart';

/// Who can see and manage this family's devices: everyone who has signed up
/// to this family's Firebase project.
class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _removeMember(FamilyService family, FamilyMember member) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.removeMemberTitle),
        content: Text(t.removeMemberBody(member.email)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: Text(t.cancelButton)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: Text(t.removeButton)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await family.removeMember(member.uid);
    } catch (e) {
      _toast(t.saveFailed(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final family = ref.watch(familyServiceProvider);
    final myUid = ref.watch(authNotifierProvider).userId;

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(t.familyMembersTitle)),
      body: family == null
          ? Center(child: Text(t.backendModeDemo))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t.familyMembersInfo, style: const TextStyle(color: Colors.grey, height: 1.4)),
                const SizedBox(height: 16),
                StreamBuilder<List<FamilyMember>>(
                  stream: family.watchMembers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text(t.saveFailed('${snapshot.error}'));
                    final members = snapshot.data;
                    if (members == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final iAmOwner = members.any((m) => m.uid == myUid && m.isOwner);
                    return Card(
                      child: Column(
                        children: [
                          for (final m in members)
                            ListTile(
                              leading: Icon(m.isOwner ? Icons.star_outline : Icons.person_outline),
                              title: Text(m.displayName.isEmpty ? m.email : m.displayName),
                              subtitle: Text([
                                m.email,
                                if (m.isOwner) t.ownerLabel,
                                if (m.uid == myUid) t.youLabel,
                              ].join(' · ')),
                              trailing: iAmOwner && !m.isOwner
                                  ? IconButton(
                                      icon: const Icon(Icons.person_remove_outlined),
                                      onPressed: () => _removeMember(family, m),
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
