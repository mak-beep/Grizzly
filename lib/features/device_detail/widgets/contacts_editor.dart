import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/device.dart';
import '../../../core/utils/json_parsing.dart';

/// Edit a device's 3–5 emergency contacts. Contacts are identified by the
/// email they use to sign in to Grizzly — that is how their phone knows to
/// alert them.
class ContactsEditor extends StatefulWidget {
  final List<EmergencyContact> initial;

  /// Called on Save; should throw on failure so the error is shown.
  final Future<void> Function(List<EmergencyContact>) onSave;

  const ContactsEditor({super.key, required this.initial, required this.onSave});

  @override
  State<ContactsEditor> createState() => _ContactsEditorState();
}

class _ContactsEditorState extends State<ContactsEditor> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  late final List<EmergencyContact> _contacts = widget.initial
      .map((c) => EmergencyContact(id: c.id, name: c.name, email: c.email, phone: c.phone))
      .toList();
  bool _isDirty = false;
  bool _isSaving = false;

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _addContact() {
    if (_contacts.length >= AppConstants.maxEmergencyContacts) return;
    setState(() {
      _contacts.add(EmergencyContact(id: _uuid.v4(), name: '', email: ''));
      _isDirty = true;
    });
  }

  void _removeContact(String id) {
    if (_contacts.length <= AppConstants.minEmergencyContacts) return;
    setState(() {
      _contacts.removeWhere((c) => c.id == id);
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_contacts);
      if (!mounted) return;
      setState(() {
        _isDirty = false;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.contactsSaved), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.contactsSaveFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String? _validateEmail(EmergencyContact contact, String? value, AppLocalizations t) {
    final email = normalizeEmail(value ?? '');
    if (!isValidEmail(email)) return t.contactEmailInvalid;
    final duplicates =
        _contacts.where((c) => c.id != contact.id && normalizeEmail(c.email) == email);
    return duplicates.isEmpty ? null : t.contactEmailDuplicate;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final canAddMore = _contacts.length < AppConstants.maxEmergencyContacts;
    final belowMinimum = _contacts.length < AppConstants.minEmergencyContacts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(t.emergencyContactsTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const Spacer(),
                  Text('${_contacts.length}/${AppConstants.maxEmergencyContacts}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text(t.contactsInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (belowMinimum)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    t.belowMinimumContacts(AppConstants.minEmergencyContacts),
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              for (final contact in _contacts)
                Padding(
                  key: ValueKey(contact.id),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: contact.name,
                              decoration:
                                  InputDecoration(labelText: t.contactNameLabel, isDense: true),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
                              onChanged: (v) {
                                contact.name = v;
                                _markDirty();
                              },
                            ),
                            TextFormField(
                              initialValue: contact.email,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration:
                                  InputDecoration(labelText: t.contactEmailLabel, isDense: true),
                              validator: (v) => _validateEmail(contact, v, t),
                              onChanged: (v) {
                                contact.email = v;
                                _markDirty();
                              },
                            ),
                            TextFormField(
                              initialValue: contact.phone,
                              keyboardType: TextInputType.phone,
                              decoration:
                                  InputDecoration(labelText: t.contactPhoneLabel, isDense: true),
                              onChanged: (v) {
                                contact.phone = v;
                                _markDirty();
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _contacts.length > AppConstants.minEmergencyContacts
                            ? () => _removeContact(contact.id)
                            : null,
                      ),
                    ],
                  ),
                ),
              if (canAddMore)
                TextButton.icon(
                  onPressed: _addContact,
                  icon: const Icon(Icons.add),
                  label: Text(t.addContactButton),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: (!belowMinimum && _isDirty && !_isSaving) ? _save : null,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(_isDirty ? t.saveContactsButton : t.contactsUpToDate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
