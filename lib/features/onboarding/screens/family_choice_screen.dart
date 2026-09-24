import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar_title.dart';

/// New step, inserted between Privacy Consent and Backend Setup.
///
/// Per the Option 2 architecture, one Firebase project = one family. This
/// screen decides which of two very different next steps the user needs:
///  - Starting the FIRST account for a brand-new family: they'll create a
///    new Firebase project, enter its credentials, and then need the
///    Firestore security rules to deploy on that fresh project (handled
///    by FirestoreRulesScreen right after backend setup succeeds).
///  - Joining a family that has ALREADY done that (e.g. a second parent,
///    or a sibling's phone): they just enter the SAME project's
///    credentials someone in their family already set up, then go
///    straight to creating their own individual login — no rules setup
///    needed, since the first family member already deployed them.
class FamilyChoiceScreen extends StatelessWidget {
  const FamilyChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: AppBarTitle(t.familyChoiceStepTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.familyChoiceHeading,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                t.familyChoiceSubtext,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _ChoiceCard(
                icon: Icons.add_home_outlined,
                title: t.newFamilyOptionTitle,
                subtitle: t.newFamilyOptionSubtitle,
                onTap: () => context.pushNamed(
                  AppRoutes.backendSetup,
                  extra: true, // isNewFamily
                ),
              ),
              const SizedBox(height: 16),
              _ChoiceCard(
                icon: Icons.group_outlined,
                title: t.joinFamilyOptionTitle,
                subtitle: t.joinFamilyOptionSubtitle,
                onTap: () => context.pushNamed(
                  AppRoutes.backendSetup,
                  extra: false, // isNewFamily
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
