import 'package:flutter/material.dart';

/// Hand-written localization (no `flutter gen-l10n` build step required —
/// works the moment `flutter pub get` finishes, nothing to generate).
///
/// Every user-facing string in the app should be read from here, not
/// hardcoded in a widget. To add a new string: add one key to each of the
/// four maps below (_en/_fr/_es/_it), then add a getter (or a small
/// parametrized method, see e.g. [lastSeenAt]) that reads it via [_t].
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('it'),
  ];

  static const Map<String, String> nativeLanguageNames = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'it': 'Italiano',
  };

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'AppLocalizations.delegate missing from MaterialApp');
    return result!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _t(String key) {
    final table = _values[locale.languageCode] ?? _values['en']!;
    return table[key] ?? _values['en']![key] ?? key;
  }

  String _fmt(String key, Map<String, String> args) {
    var s = _t(key);
    for (final e in args.entries) {
      s = s.replaceAll('{${e.key}}', e.value);
    }
    return s;
  }

  // ---- Auth ----
  String get authWelcomeTitle => _t('authWelcomeTitle');
  String get authSignUpSubtitle => _t('authSignUpSubtitle');
  String get authSignInSubtitle => _t('authSignInSubtitle');
  String get authEmailLabel => _t('authEmailLabel');
  String get authPasswordLabel => _t('authPasswordLabel');
  String get authEmailInvalid => _t('authEmailInvalid');
  String get authPasswordTooShort => _t('authPasswordTooShort');
  String get authSignUpButton => _t('authSignUpButton');
  String get authSignInButton => _t('authSignInButton');
  String get authToggleToSignIn => _t('authToggleToSignIn');
  String get authToggleToSignUp => _t('authToggleToSignUp');
  String get authIndividualNote => _t('authIndividualNote');
  String get authStepTitle => _t('authStepTitle');

  // ---- Onboarding: profile ----
  String get profileStepTitle => _t('profileStepTitle');
  String get profileHeading => _t('profileHeading');
  String get profileSubtext => _t('profileSubtext');
  String get firstNameLabel => _t('firstNameLabel');
  String get lastNameLabel => _t('lastNameLabel');
  String get ageLabel => _t('ageLabel');
  String get fieldRequired => _t('fieldRequired');
  String get ageInvalid => _t('ageInvalid');
  String get continueButton => _t('continueButton');

  // ---- Onboarding: privacy ----
  String get privacyStepTitle => _t('privacyStepTitle');
  String get privacyHeading => _t('privacyHeading');
  String get privacyBody => _t('privacyBody');
  String get privacyCheckboxLabel => _t('privacyCheckboxLabel');
  String get privacyAgreeButton => _t('privacyAgreeButton');

  // ---- Onboarding: backend ----
  String get backendStepTitle => _t('backendStepTitle');
  String get backendHeading => _t('backendHeading');
  String get backendBody => _t('backendBody');
  String get backendGuideStep1 => _t('backendGuideStep1');
  String get backendGuideStep2 => _t('backendGuideStep2');
  String get backendGuideStep3 => _t('backendGuideStep3');
  String get backendProjectIdLabel => _t('backendProjectIdLabel');
  String get backendApiKeyLabel => _t('backendApiKeyLabel');
  String get backendAppIdLabel => _t('backendAppIdLabel');
  String get backendSenderIdLabel => _t('backendSenderIdLabel');
  String get familyChoiceStepTitle => _t('familyChoiceStepTitle');
  String get familyChoiceHeading => _t('familyChoiceHeading');
  String get familyChoiceSubtext => _t('familyChoiceSubtext');
  String get newFamilyOptionTitle => _t('newFamilyOptionTitle');
  String get newFamilyOptionSubtitle => _t('newFamilyOptionSubtitle');
  String get joinFamilyOptionTitle => _t('joinFamilyOptionTitle');
  String get joinFamilyOptionSubtitle => _t('joinFamilyOptionSubtitle');
  String get backendJoinStepTitle => _t('backendJoinStepTitle');
  String get backendJoinHeading => _t('backendJoinHeading');
  String get backendJoinBody => _t('backendJoinBody');
  String get firestoreRulesStepTitle => _t('firestoreRulesStepTitle');
  String get firestoreRulesHeading => _t('firestoreRulesHeading');
  String get firestoreRulesBody => _t('firestoreRulesBody');
  String get copyRulesButton => _t('copyRulesButton');
  String get downloadRulesButton => _t('downloadRulesButton');
  String get rulesCopiedToast => _t('rulesCopiedToast');
  String get rulesDownloadFailed => _t('rulesDownloadFailed');
  String get rulesLoadFailed => _t('rulesLoadFailed');
  String get rulesDeployedContinueButton => _t('rulesDeployedContinueButton');
  String get backendLinkButton => _t('backendLinkButton');
  String get backendLinkFailed => _t('backendLinkFailed');
  String get backendFieldsRequired => _t('backendFieldsRequired');
  String get backendDemoDividerLabel => _t('backendDemoDividerLabel');
  String get backendDemoTitle => _t('backendDemoTitle');
  String get backendDemoBody => _t('backendDemoBody');
  String get backendDemoButton => _t('backendDemoButton');

  // ---- Onboarding: device type ----
  String get deviceTypeStepTitleFirst => _t('deviceTypeStepTitleFirst');
  String get deviceTypeStepTitleAdd => _t('deviceTypeStepTitleAdd');
  String get deviceTypeHeading => _t('deviceTypeHeading');
  String get deviceTypeSubtext => _t('deviceTypeSubtext');
  String get gpsTrackerSubtitle => _t('gpsTrackerSubtitle');
  String get alarmButtonSubtitle => _t('alarmButtonSubtitle');
  String get deviceTypeGpsName => _t('deviceTypeGpsName');
  String get deviceTypeAlarmName => _t('deviceTypeAlarmName');

  // ---- Onboarding: device setup ----
  String deviceSetupTitle(String typeName) => _fmt('deviceSetupTitle', {'type': typeName});
  String get deviceSetupHeading => _t('deviceSetupHeading');
  String get deviceSetupExample => _t('deviceSetupExample');
  String get deviceNameLabel => _t('deviceNameLabel');
  String get saveAndFinishButton => _t('saveAndFinishButton');
  String get deviceUuidLabel => _t('deviceUuidLabel');
  String get deviceUuidHint => _t('deviceUuidHint');
  String get deviceUuidInvalid => _t('deviceUuidInvalid');
  String get deviceUuidDuplicate => _t('deviceUuidDuplicate');
  String get deviceUuidHelpTitle => _t('deviceUuidHelpTitle');
  String get deviceUuidHelpBody => _t('deviceUuidHelpBody');

  // ---- Dashboard ----
  String get dashboardTitle => _t('dashboardTitle');
  String get emptyStateTitle => _t('emptyStateTitle');
  String get emptyStateSubtitle => _t('emptyStateSubtitle');
  String get addFirstDeviceButton => _t('addFirstDeviceButton');
  String get addDeviceButton => _t('addDeviceButton');

  // ---- Device detail: shared ----
  String get renameDeviceTitle => _t('renameDeviceTitle');
  String get deviceNotFound => _t('deviceNotFound');
  String get cancelButton => _t('cancelButton');
  String get saveButton => _t('saveButton');
  String get removeDeviceQuestion => _t('removeDeviceQuestion');
  String get removeDeviceBody => _t('removeDeviceBody');
  String get removeButton => _t('removeButton');
  String get removeThisDeviceButton => _t('removeThisDeviceButton');
  String get historyTitle => _t('historyTitle');
  String get noActivityYet => _t('noActivityYet');
  String get testWithoutHardwareTitle => _t('testWithoutHardwareTitle');
  String get testWithoutHardwareBody => _t('testWithoutHardwareBody');

  // ---- GPS tracker detail ----
  String get waitingForFirstUpdate => _t('waitingForFirstUpdate');
  String get justNowShort => _t('justNowShort');
  String minutesAgoShort(int n) => _fmt('minutesAgoShort', {'n': '$n'});
  String hoursAgoShort(int n) => _fmt('hoursAgoShort', {'n': '$n'});
  String daysAgoShort(int n) => _fmt('daysAgoShort', {'n': '$n'});
  String pollingInfo(int seconds, int min, int max) =>
      _fmt('pollingInfo', {'seconds': '$seconds', 'min': '$min', 'max': '$max'});
  String get simulateLocationUpdate => _t('simulateLocationUpdate');
  String get simulateGeofenceBreach => _t('simulateGeofenceBreach');

  // ---- Geofence editor ----
  String get safeZoneTitle => _t('safeZoneTitle');
  String get addressLabel => _t('addressLabel');
  String radiusLabel(int radius) => _fmt('radiusLabel', {'radius': '$radius'});
  String get saveSafeZoneButton => _t('saveSafeZoneButton');
  String get safeZoneSaved => _t('safeZoneSaved');

  // ---- Contacts editor ----
  String get emergencyContactsTitle => _t('emergencyContactsTitle');
  String belowMinimumContacts(int min) => _fmt('belowMinimumContacts', {'min': '$min'});
  String get contactNameLabel => _t('contactNameLabel');
  String get addContactButton => _t('addContactButton');
  String get saveContactsButton => _t('saveContactsButton');
  String get contactsUpToDate => _t('contactsUpToDate');
  String get contactsSaved => _t('contactsSaved');
  String contactsSaveFailed(String error) => _fmt('contactsSaveFailed', {'error': error});

  // ---- Alarm button detail ----
  String get alarmActiveLabel => _t('alarmActiveLabel');
  String get standingByLabel => _t('standingByLabel');
  String get howItWorksTitle => _t('howItWorksTitle');
  String get alarmInfoSilent => _t('alarmInfoSilent');
  String get alarmInfoTrigger => _t('alarmInfoTrigger');
  String alarmInfoDeactivate(int count, int seconds) =>
      _fmt('alarmInfoDeactivate', {'count': '$count', 'seconds': '$seconds'});
  String get simulateButtonPress => _t('simulateButtonPress');
  String simulateDeactivation(int count) => _fmt('simulateDeactivation', {'count': '$count'});

  // ---- History event labels ----
  String get eventGeofenceBreach => _t('eventGeofenceBreach');
  String get eventAlarmTriggered => _t('eventAlarmTriggered');
  String get eventAlarmCancelled => _t('eventAlarmCancelled');
  String get eventLocationPing => _t('eventLocationPing');

  // ---- Settings ----
  String get settingsTitle => _t('settingsTitle');
  String get settingsScopeNote => _t('settingsScopeNote');
  String get languageLabel => _t('languageLabel');
  String get darkThemeLabel => _t('darkThemeLabel');
  String get legalSectionTitle => _t('legalSectionTitle');
  String get privacyConsentLabel => _t('privacyConsentLabel');
  String get acceptedLabel => _t('acceptedLabel');
  String get accountSectionTitle => _t('accountSectionTitle');
  String signedInAs(String email) => _fmt('signedInAs', {'email': email});
  String get signOutButton => _t('signOutButton');
  String get backendSectionTitle => _t('backendSectionTitle');
  String get backendModeDemo => _t('backendModeDemo');
  String backendModeConnected(String projectId) =>
      _fmt('backendModeConnected', {'projectId': projectId});

  // ---- v0.2: alerts, pairing, family, maps ----
  String get backendGuideStep4 => _t('backendGuideStep4');
  String get backendGuideStep5 => _t('backendGuideStep5');
  String get backendGuideStep6 => _t('backendGuideStep6');
  String get backendAppIdHelper => _t('backendAppIdHelper');
  String get backendSenderIdHelper => _t('backendSenderIdHelper');
  String get backendJoinGuideStep1 => _t('backendJoinGuideStep1');
  String get backendJoinGuideStep2 => _t('backendJoinGuideStep2');
  String get backendRestartRequired => _t('backendRestartRequired');
  String get alarmInfoCheckIn => _t('alarmInfoCheckIn');
  String alertAlarmTitle(String name) => _fmt('alertAlarmTitle', {'name': name});
  String alertAlarmBody(String time) => _fmt('alertAlarmBody', {'time': time});
  String alertAlarmCancelledTitle(String name) => _fmt('alertAlarmCancelledTitle', {'name': name});
  String alertAlarmCancelledBody(String time) => _fmt('alertAlarmCancelledBody', {'time': time});
  String alertBreachTitle(String name) => _fmt('alertBreachTitle', {'name': name});
  String alertBreachBody(String time) => _fmt('alertBreachBody', {'time': time});
  String alertReturnTitle(String name) => _fmt('alertReturnTitle', {'name': name});
  String alertReturnBody(String time) => _fmt('alertReturnBody', {'time': time});
  String get alertStyleLabel => _t('alertStyleLabel');
  String get alertStyleSound => _t('alertStyleSound');
  String get alertStyleVibrate => _t('alertStyleVibrate');
  String get backgroundMonitoringLabel => _t('backgroundMonitoringLabel');
  String get backgroundMonitoringHint => _t('backgroundMonitoringHint');
  String get chargingLabel => _t('chargingLabel');
  String get checkAgainButton => _t('checkAgainButton');
  String get contactEmailDuplicate => _t('contactEmailDuplicate');
  String get contactEmailInvalid => _t('contactEmailInvalid');
  String get contactEmailLabel => _t('contactEmailLabel');
  String get contactPhoneLabel => _t('contactPhoneLabel');
  String get contactsInfo => _t('contactsInfo');
  String get currentLocationLabel => _t('currentLocationLabel');
  String detectedDeviceSubtitle(String time) => _fmt('detectedDeviceSubtitle', {'time': time});
  String get detectedDevicesEmpty => _t('detectedDevicesEmpty');
  String get detectedDevicesTitle => _t('detectedDevicesTitle');
  String deviceTypeMismatch(String type) => _fmt('deviceTypeMismatch', {'type': type});
  String get disconnectBackendBody => _t('disconnectBackendBody');
  String get disconnectBackendButton => _t('disconnectBackendButton');
  String get disconnectBackendTitle => _t('disconnectBackendTitle');
  String get doneButton => _t('doneButton');
  String get eventGeofenceReturn => _t('eventGeofenceReturn');
  String familyCheckFailed(String error) => _fmt('familyCheckFailed', {'error': error});
  String get familyMembersInfo => _t('familyMembersInfo');
  String get familyMembersTitle => _t('familyMembersTitle');
  String get geofenceInside => _t('geofenceInside');
  String get geofenceNotSet => _t('geofenceNotSet');
  String get geofenceOutside => _t('geofenceOutside');
  String get geofenceUnknown => _t('geofenceUnknown');
  String get inviteButton => _t('inviteButton');
  String get inviteMemberTitle => _t('inviteMemberTitle');
  String inviteSent(String email) => _fmt('inviteSent', {'email': email});
  String get liveLocationTitle => _t('liveLocationTitle');
  String get locationPermissionDenied => _t('locationPermissionDenied');
  String get locationServicesOff => _t('locationServicesOff');
  String get locationUnavailable => _t('locationUnavailable');
  String get monitoringNotificationBody => _t('monitoringNotificationBody');
  String get monitoringNotificationTitle => _t('monitoringNotificationTitle');
  String newDevicesDetected(int n) => _fmt('newDevicesDetected', {'n': '\$n'});
  String get noPendingInvites => _t('noPendingInvites');
  String get notificationsSectionTitle => _t('notificationsSectionTitle');
  String get orEnterIdManually => _t('orEnterIdManually');
  String get ownerLabel => _t('ownerLabel');
  String get pendingInvitesTitle => _t('pendingInvitesTitle');
  String get recenterMapTooltip => _t('recenterMapTooltip');
  String removeMemberBody(String email) => _fmt('removeMemberBody', {'email': email});
  String get removeMemberTitle => _t('removeMemberTitle');
  String get removeSafeZoneButton => _t('removeSafeZoneButton');
  String get repairButton => _t('repairButton');
  String get repairDeviceBody => _t('repairDeviceBody');
  String get repairDeviceTitle => _t('repairDeviceTitle');
  String get repairDone => _t('repairDone');
  String get revokeInviteTooltip => _t('revokeInviteTooltip');
  String get safeZoneNeedsCenter => _t('safeZoneNeedsCenter');
  String get safeZoneRemoved => _t('safeZoneRemoved');
  String saveFailed(String error) => _fmt('saveFailed', {'error': error});
  String get searchAddressTooltip => _t('searchAddressTooltip');
  String get searchFailed => _t('searchFailed');
  String get searchNoResults => _t('searchNoResults');
  String get securityRulesLabel => _t('securityRulesLabel');
  String get showMoreButton => _t('showMoreButton');
  String get simulateGeofenceReturn => _t('simulateGeofenceReturn');
  String statusArmed(String time) => _fmt('statusArmed', {'time': time});
  String statusCheckInOverdue(String time) => _fmt('statusCheckInOverdue', {'time': time});
  String get statusNeverConnected => _t('statusNeverConnected');
  String statusOffline(String time) => _fmt('statusOffline', {'time': time});
  String statusOnline(String time) => _fmt('statusOnline', {'time': time});
  String get stillNotInvited => _t('stillNotInvited');
  String get syncErrorBanner => _t('syncErrorBanner');
  String get tapMapToSetCenter => _t('tapMapToSetCenter');
  String get testNotificationBody => _t('testNotificationBody');
  String get testNotificationButton => _t('testNotificationButton');
  String get testNotificationTitle => _t('testNotificationTitle');
  String get useMyLocationButton => _t('useMyLocationButton');
  String get waitingForAlarmLocation => _t('waitingForAlarmLocation');
  String waitingInviteBody(String email) => _fmt('waitingInviteBody', {'email': email});
  String get waitingInviteHeading => _t('waitingInviteHeading');
  String get waitingInviteTitle => _t('waitingInviteTitle');
  String get youLabel => _t('youLabel');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const Map<String, Map<String, String>> _values = {
  'en': _enValues,
  'fr': _frValues,
  'es': _esValues,
  'it': _itValues,
};

const Map<String, String> _enValues = {
  'authWelcomeTitle': 'Welcome to Grizzly',
  'authSignUpSubtitle': "Create your personal account. Every contact gets their own separate login.",
  'authSignInSubtitle': 'Sign in to your Grizzly account.',
  'authEmailLabel': 'Email',
  'authPasswordLabel': 'Password',
  'authEmailInvalid': 'Enter a valid email address',
  'authPasswordTooShort': 'Password must be at least 6 characters',
  'authSignUpButton': 'Create account',
  'authSignInButton': 'Sign in',
  'authToggleToSignIn': 'Already have an account? Sign in',
  'authToggleToSignUp': "Don't have an account? Sign up",
  'authIndividualNote': 'Each contact linked to a device signs in separately — your language, theme, and login are yours alone.',
  'authStepTitle': 'Step 4 of 5 · Create your account',
  'backendFieldsRequired': 'Please enter both the Project ID and API Key.',
  'profileStepTitle': 'Step 1 of 5 · Your profile',
  'profileHeading': "Let's personalize your account",
  'profileSubtext': 'This information stays with your account only and does not affect any device settings.',
  'firstNameLabel': 'First name',
  'lastNameLabel': 'Last name',
  'ageLabel': 'Age',
  'fieldRequired': 'Required',
  'ageInvalid': 'Enter a valid age',
  'continueButton': 'Continue',
  'privacyStepTitle': 'Step 2 of 5 · Privacy',
  'privacyHeading': 'Before you continue',
  'privacyBody': 'Grizzly collects and stores real-time location data, geofence events, and alarm alerts for each device you register, so they can be shown to you and the emergency contacts you configure.\n\nYour data is stored in your own private backend (linked in the next step) and is never visible to other families using this app.\n\nYou must accept this before using Grizzly.',
  'privacyCheckboxLabel': 'I understand and agree to the collection and storage of my location and alert data.',
  'privacyAgreeButton': 'I agree, continue',
  'backendStepTitle': 'Step 3 of 5 · Connect your backend',
  'backendHeading': 'Your own private cloud',
  'backendBody': 'Grizzly stores your data in a free Firebase project that belongs only to you — not a server shared with other families. This keeps everything private and costs \$0 for typical family use.',
  'backendProjectIdLabel': 'Firebase Project ID',
  'backendApiKeyLabel': 'Firebase Web API Key',
  'backendAppIdLabel': 'Firebase App ID',
  'backendSenderIdLabel': 'Firebase Messaging Sender ID',
  'familyChoiceStepTitle': 'Family setup',
  'familyChoiceHeading': 'Is this a new family, or are you joining one?',
  'familyChoiceSubtext':
      'Every family uses its own private Firebase project to store their devices. Choose whichever applies to you.',
  'newFamilyOptionTitle': 'Set up a new family',
  'newFamilyOptionSubtitle':
      'You\'ll create a new Firebase project and get the security rules to deploy on it.',
  'joinFamilyOptionTitle': 'Join an existing family',
  'joinFamilyOptionSubtitle':
      'Someone in your family already set this up — enter the same project details they used.',
  'backendJoinStepTitle': 'Connect to your family\'s backend',
  'backendJoinHeading': 'Enter your family\'s existing Firebase details',
  'backendJoinBody':
      'Ask whoever set up Grizzly for your family for these details, then enter them below to join the same project.',
  'firestoreRulesStepTitle': 'Security rules',
  'firestoreRulesHeading': 'One more step: deploy these security rules',
  'copyRulesButton': 'Copy',
  'downloadRulesButton': 'Download',
  'rulesCopiedToast': 'Rules copied to clipboard',
  'rulesDownloadFailed': 'Couldn\'t prepare the file to share. Try copying instead.',
  'rulesLoadFailed': 'Couldn\'t load the rules file.',
  'rulesDeployedContinueButton': 'I\'ve deployed the rules \u2014 continue',
  'backendLinkButton': 'Link my project and continue',
  'backendLinkFailed': "Couldn't connect to that Firebase project — check the project ID and API key, or continue in Demo mode below.",
  'backendDemoDividerLabel': 'or',
  'backendDemoTitle': 'Just want to try the app?',
  'backendDemoBody': 'Skip this step and run Grizzly in demo mode. Every feature — devices, alerts, contacts, history — works fully on this device only, no Firebase project required. Connect a real backend anytime later from Settings.',
  'backendDemoButton': 'Continue in demo mode',
  'deviceTypeStepTitleFirst': 'Step 5 of 5 · Add your first device',
  'deviceTypeStepTitleAdd': 'Add a device',
  'deviceTypeHeading': 'What are you setting up?',
  'deviceTypeSubtext': 'Each device is configured independently — you can add as many chips and buttons as you need, one at a time.',
  'gpsTrackerSubtitle': 'Continuous location + custom safe zone alerts',
  'alarmButtonSubtitle': 'Silent until pressed — instant alert + loud alarm',
  'deviceTypeGpsName': 'GPS Tracker',
  'deviceTypeAlarmName': 'Alarm Button',
  'deviceSetupTitle': 'Name your {type}',
  'deviceSetupHeading': "Give this device a name you'll recognize",
  'deviceSetupExample': 'E.g. "Emma\'s backpack" or "Front door button". You can change this anytime from the device screen.',
  'deviceNameLabel': 'Device name',
  'saveAndFinishButton': 'Save and finish',
  'deviceUuidLabel': 'Device ID',
  'deviceUuidHint': 'e.g. 550e8400-e29b-41d4-a716-446655440000',
  'dashboardTitle': 'My Devices',
  'emptyStateTitle': 'No devices yet',
  'emptyStateSubtitle': 'Add a GPS tracker or alarm button to get started.',
  'addFirstDeviceButton': 'Add your first device',
  'addDeviceButton': 'Add device',
  'deviceNotFound': 'Device not found',
  'renameDeviceTitle': 'Rename device',
  'cancelButton': 'Cancel',
  'saveButton': 'Save',
  'removeDeviceQuestion': 'Remove device?',
  'removeDeviceBody': 'This only removes it from the app. It does not affect any other device.',
  'removeButton': 'Remove',
  'removeThisDeviceButton': 'Remove this device',
  'historyTitle': 'History',
  'noActivityYet': 'No activity yet',
  'testWithoutHardwareTitle': 'Test without hardware',
  'waitingForFirstUpdate': 'Waiting for first location update…',
  'justNowShort': 'Just now',
  'minutesAgoShort': '{n}m ago',
  'hoursAgoShort': '{n}h ago',
  'daysAgoShort': '{n}d ago',
  'pollingInfo': 'Updates every {seconds}s · ~{min}-{max} day battery life',
  'simulateLocationUpdate': 'Simulate location update',
  'simulateGeofenceBreach': 'Simulate geofence breach',
  'safeZoneTitle': 'Safe zone',
  'addressLabel': 'Address or place',
  'radiusLabel': 'Radius: {radius} m',
  'saveSafeZoneButton': 'Save safe zone',
  'safeZoneSaved': 'Safe zone saved',
  'emergencyContactsTitle': 'Emergency contacts',
  'belowMinimumContacts': 'Add at least {min} contacts',
  'contactNameLabel': 'Name',
  'addContactButton': 'Add contact',
  'saveContactsButton': 'Save contacts',
  'contactsUpToDate': 'Saved',
  'contactsSaved': 'Contacts saved',
  'contactsSaveFailed': 'Could not save contacts: {error}',
  'alarmActiveLabel': 'ALARM ACTIVE',
  'standingByLabel': 'Standing by',
  'howItWorksTitle': 'How it works',
  'alarmInfoSilent': 'Silent and invisible until pressed',
  'alarmInfoDeactivate': 'Deactivate with exactly {count} consecutive presses within {seconds}s — 1 or 2 presses do nothing, to prevent accidents',
  'simulateButtonPress': 'Simulate button press',
  'simulateDeactivation': 'Simulate {count}x deactivation',
  'eventGeofenceBreach': 'Geofence breached',
  'eventAlarmTriggered': 'Alarm triggered',
  'eventAlarmCancelled': 'Alarm cancelled (3x press)',
  'eventLocationPing': 'Location update',
  'settingsTitle': 'Settings',
  'settingsScopeNote': 'These settings only affect your own account — other contacts on the same devices keep their own preferences.',
  'languageLabel': 'Language',
  'darkThemeLabel': 'Dark theme',
  'legalSectionTitle': 'Legal',
  'privacyConsentLabel': 'Privacy consent',
  'acceptedLabel': 'Accepted',
  'accountSectionTitle': 'Account',
  'signedInAs': 'Signed in as {email}',
  'signOutButton': 'Sign out',
  'backendSectionTitle': 'Backend',
  'backendModeDemo': 'Demo mode (data stored on this device only)',
  'backendModeConnected': 'Connected to Firebase project: {projectId}',
  'backendGuideStep1': 'Go to console.firebase.google.com and create a free project (the free Spark plan is enough).',
  'backendGuideStep2': 'Build → Authentication → Get started: enable Email/Password and Anonymous (Anonymous is how the Grizzly devices sign in).',
  'backendGuideStep3': 'Build → Firestore Database → Create database (production mode, the location closest to you).',
  'deviceUuidInvalid': 'That doesn\'t look like a valid device ID. Check it in the Firebase console and try again.',
  'deviceUuidDuplicate': 'A device with this ID is already set up. Each physical unit should only be added once.',
  'deviceUuidHelpTitle': 'Where do I find this device\'s ID?',
  'deviceUuidHelpBody': 'Every Grizzly device creates a permanent ID the first time it connects to your Firebase project. Once the device is switched on and connected, it appears under "Detected devices". You can also find it in the Firebase console: Firestore Database → families → family → devices. The document ID is the device ID. Enter it exactly, including the dashes.',
  'firestoreRulesBody': 'Copy or download this file, paste it into Firestore Database → Rules in the Firebase console and click Publish. Then only your family members can see your devices, and each Grizzly device can only update its own data.',
  'alarmInfoTrigger': 'One press: the alarm sounds and your contacts are alerted immediately, the live location follows',
  'testWithoutHardwareBody': 'No physical device yet? Simulate its behaviour below to check notifications, alerts and history end to end. Only available in demo mode.',
  'backendGuideStep4': 'Project settings → General → Your apps: add an Android app (and an iOS app for iPhones), then copy the App ID for this phone\'s platform.',
  'backendGuideStep5': 'On the same page copy the Project ID, the Web API Key and the Project number.',
  'backendGuideStep6': 'Enter them below. The same Project ID and Web API Key also go into the device firmware (credentials.h).',
  'backendAppIdHelper': 'Looks like 1:123456789012:android:abc123… (use the iOS App ID on an iPhone)',
  'backendSenderIdHelper': 'The Project number from Project settings → General',
  'backendJoinGuideStep1': 'Ask whoever set up Grizzly for the Project ID, Web API Key, App ID and Project number.',
  'backendJoinGuideStep2': 'Ask them to invite your email (Settings → Family members) before you sign up.',
  'backendRestartRequired': 'Another family backend is still loaded. Close and reopen Grizzly, then try again.',
  'alarmInfoCheckIn': 'Checks in quietly about once an hour so you know it still works. Nothing is logged or notified',
  'alertAlarmTitle': '🚨 ALARM: {name}',
  'alertAlarmBody': 'The alarm button was pressed at {time}. Open Grizzly for the live location.',
  'alertAlarmCancelledTitle': '{name}: alarm cancelled',
  'alertAlarmCancelledBody': 'The alarm was cancelled at {time}.',
  'alertBreachTitle': '⚠️ {name} left the safe zone',
  'alertBreachBody': 'Left the safe zone at {time}. Open Grizzly to see where it is.',
  'alertReturnTitle': '{name} is back in the safe zone',
  'alertReturnBody': 'Back inside at {time}.',
  'alertStyleLabel': 'Alert notifications',
  'alertStyleSound': 'Sound + vibration',
  'alertStyleVibrate': 'Vibration only',
  'backgroundMonitoringLabel': 'Monitor in the background',
  'backgroundMonitoringHint': 'Keeps alerts coming while Grizzly is in the background. Shows a small ongoing notification.',
  'chargingLabel': 'Charging',
  'checkAgainButton': 'Check again',
  'contactEmailDuplicate': 'Each contact needs a different email',
  'contactEmailInvalid': 'Enter a valid email address',
  'contactEmailLabel': 'Email (their Grizzly login)',
  'contactPhoneLabel': 'Phone (optional)',
  'contactsInfo': 'Contacts get alerts on their own phone once they sign in to Grizzly with this email. New emails are invited to your family automatically.',
  'currentLocationLabel': 'My current location',
  'detectedDeviceSubtitle': 'Last connected {time}',
  'detectedDevicesEmpty': 'No new devices yet. Switch the device on with its SIM inserted; it appears here within a minute of connecting.',
  'detectedDevicesTitle': 'Detected devices',
  'deviceTypeMismatch': 'This ID belongs to a {type}. Choose that device type instead.',
  'disconnectBackendBody': 'This phone forgets your family\'s Firebase project and signs you out. No family data is deleted.',
  'disconnectBackendButton': 'Disconnect this phone from the family',
  'disconnectBackendTitle': 'Disconnect from the family?',
  'doneButton': 'Done',
  'eventGeofenceReturn': 'Back in safe zone',
  'familyCheckFailed': 'Could not check your family membership: {error}. Make sure the security rules are published.',
  'familyMembersInfo': 'Everyone listed here can see and manage your family\'s devices. To add someone, invite their email; they then sign up in Grizzly with that email.',
  'familyMembersTitle': 'Family members',
  'geofenceInside': 'Inside the safe zone',
  'geofenceNotSet': 'No safe zone set',
  'geofenceOutside': 'Outside the safe zone',
  'geofenceUnknown': 'Safe zone status not known yet',
  'inviteButton': 'Invite',
  'inviteMemberTitle': 'Invite someone',
  'inviteSent': '{email} can now join your family',
  'liveLocationTitle': 'Live location',
  'locationPermissionDenied': 'Location permission was denied',
  'locationServicesOff': 'Turn on location services first',
  'locationUnavailable': 'Could not get your current location',
  'monitoringNotificationBody': 'Watching your devices for alerts',
  'monitoringNotificationTitle': 'Grizzly is active',
  'newDevicesDetected': 'New devices detected: {n}. Tap to add',
  'noPendingInvites': 'No pending invites',
  'notificationsSectionTitle': 'Notifications',
  'orEnterIdManually': 'Select a detected device above, or enter its ID',
  'ownerLabel': 'Owner',
  'pendingInvitesTitle': 'Pending invites',
  'recenterMapTooltip': 'Center on device',
  'removeMemberBody': '{email} will no longer see your family\'s devices.',
  'removeMemberTitle': 'Remove member?',
  'removeSafeZoneButton': 'Remove safe zone',
  'repairButton': 'Re-pair',
  'repairDeviceBody': 'Use this when the device was re-flashed and can no longer send updates. It claims this entry again the next time it connects.',
  'repairDeviceTitle': 'Re-pair device',
  'repairDone': 'The device can reconnect now',
  'revokeInviteTooltip': 'Cancel invite',
  'safeZoneNeedsCenter': 'Search an address, use your location or tap the map first',
  'safeZoneRemoved': 'Safe zone removed',
  'saveFailed': 'Could not save: {error}',
  'searchAddressTooltip': 'Search address',
  'searchFailed': 'Address search failed. Check your connection.',
  'searchNoResults': 'No places found',
  'securityRulesLabel': 'Security rules',
  'showMoreButton': 'Show more',
  'simulateGeofenceReturn': 'Simulate return to safe zone',
  'statusArmed': 'Armed · last check-in {time}',
  'statusCheckInOverdue': 'Last check-in {time}. Check battery and coverage',
  'statusNeverConnected': 'Waiting for the device to connect',
  'statusOffline': 'Offline · last update {time}',
  'statusOnline': 'Online · updated {time}',
  'stillNotInvited': 'Not invited yet. Ask a family member to invite your email.',
  'syncErrorBanner': 'Can\'t sync with your family\'s backend. Check the connection and that the security rules are published.',
  'tapMapToSetCenter': 'Tap the map to place the centre of the safe zone',
  'testNotificationBody': 'This is how Grizzly alerts look and feel.',
  'testNotificationButton': 'Send a test alert',
  'testNotificationTitle': 'Grizzly test alert',
  'useMyLocationButton': 'Use my current location',
  'waitingForAlarmLocation': 'Alert sent. Waiting for the button\'s GPS location…',
  'waitingInviteBody': 'Your account {email} is not part of this family yet. Ask a family member to open Settings → Family members in Grizzly and invite this email, then tap Check again.',
  'waitingInviteHeading': 'Almost there',
  'waitingInviteTitle': 'Waiting for an invite',
  'youLabel': 'You',
};

const Map<String, String> _frValues = {
  'authWelcomeTitle': 'Bienvenue sur Grizzly',
  'authSignUpSubtitle': 'Créez votre compte personnel. Chaque contact dispose de sa propre connexion.',
  'authSignInSubtitle': 'Connectez-vous à votre compte Grizzly.',
  'authEmailLabel': 'E-mail',
  'authPasswordLabel': 'Mot de passe',
  'authEmailInvalid': 'Saisissez une adresse e-mail valide',
  'authPasswordTooShort': 'Le mot de passe doit contenir au moins 6 caractères',
  'authSignUpButton': 'Créer un compte',
  'authSignInButton': 'Se connecter',
  'authToggleToSignIn': 'Vous avez déjà un compte ? Connectez-vous',
  'authToggleToSignUp': "Vous n'avez pas de compte ? Inscrivez-vous",
  'authIndividualNote': 'Chaque contact lié à un appareil se connecte séparément — votre langue, votre thème et votre connexion vous appartiennent.',
  'authStepTitle': 'Étape 4 sur 5 · Créer votre compte',
  'backendFieldsRequired': "Veuillez saisir l'ID de projet et la clé API.",
  'profileStepTitle': 'Étape 1 sur 5 · Votre profil',
  'profileHeading': 'Personnalisons votre compte',
  'profileSubtext': 'Ces informations restent liées à votre compte uniquement et n\'affectent aucun réglage des appareils.',
  'firstNameLabel': 'Prénom',
  'lastNameLabel': 'Nom',
  'ageLabel': 'Âge',
  'fieldRequired': 'Obligatoire',
  'ageInvalid': 'Saisissez un âge valide',
  'continueButton': 'Continuer',
  'privacyStepTitle': 'Étape 2 sur 5 · Confidentialité',
  'privacyHeading': 'Avant de continuer',
  'privacyBody': 'Grizzly collecte et stocke les données de localisation en temps réel, les événements de zone de sécurité et les alertes pour chaque appareil que vous enregistrez, afin de vous les présenter ainsi qu\'aux contacts d\'urgence que vous configurez.\n\nVos données sont stockées dans votre propre backend privé (à connecter à l\'étape suivante) et ne sont jamais visibles par d\'autres familles utilisant cette application.\n\nVous devez accepter ceci avant d\'utiliser Grizzly.',
  'privacyCheckboxLabel': 'Je comprends et j\'accepte la collecte et le stockage de mes données de localisation et d\'alerte.',
  'privacyAgreeButton': "J'accepte, continuer",
  'backendStepTitle': 'Étape 3 sur 5 · Connecter votre backend',
  'backendHeading': 'Votre propre cloud privé',
  'backendBody': 'Grizzly stocke vos données dans un projet Firebase gratuit qui vous appartient exclusivement — et non sur un serveur partagé avec d\'autres familles. Cela garantit la confidentialité et un coût de 0 \$ pour un usage familial classique.',
  'backendProjectIdLabel': 'ID de projet Firebase',
  'backendApiKeyLabel': 'Clé API Web Firebase',
  'backendAppIdLabel': 'ID d\'application Firebase',
  'backendSenderIdLabel': 'ID d\'expéditeur Firebase Messaging',
  'familyChoiceStepTitle': 'Configuration familiale',
  'familyChoiceHeading': 'S\'agit-il d\'une nouvelle famille ou en rejoignez-vous une ?',
  'familyChoiceSubtext':
      'Chaque famille utilise son propre projet Firebase privé pour stocker ses appareils. Choisissez ce qui vous correspond.',
  'newFamilyOptionTitle': 'Créer une nouvelle famille',
  'newFamilyOptionSubtitle':
      'Vous allez créer un nouveau projet Firebase et obtenir les règles de sécurité à déployer.',
  'joinFamilyOptionTitle': 'Rejoindre une famille existante',
  'joinFamilyOptionSubtitle':
      'Quelqu\'un de votre famille a déjà configuré cela — entrez les mêmes informations de projet.',
  'backendJoinStepTitle': 'Se connecter au backend de votre famille',
  'backendJoinHeading': 'Entrez les informations Firebase existantes de votre famille',
  'backendJoinBody':
      'Demandez ces informations à la personne qui a configuré Grizzly pour votre famille, puis entrez-les ci-dessous.',
  'firestoreRulesStepTitle': 'Règles de sécurité',
  'firestoreRulesHeading': 'Une dernière étape : déployez ces règles de sécurité',
  'copyRulesButton': 'Copier',
  'downloadRulesButton': 'Télécharger',
  'rulesCopiedToast': 'Règles copiées dans le presse-papiers',
  'rulesDownloadFailed': 'Impossible de préparer le fichier. Essayez de copier à la place.',
  'rulesLoadFailed': 'Impossible de charger le fichier de règles.',
  'rulesDeployedContinueButton': 'J\'ai déployé les règles \u2014 continuer',
  'backendLinkButton': 'Lier mon projet et continuer',
  'backendLinkFailed': "Impossible de se connecter à ce projet Firebase — vérifiez l'ID du projet et la clé API, ou continuez en mode démo ci-dessous.",
  'backendDemoDividerLabel': 'ou',
  'backendDemoTitle': 'Vous voulez simplement essayer l\'application ?',
  'backendDemoBody': 'Passez cette étape et utilisez Grizzly en mode démo. Toutes les fonctionnalités — appareils, alertes, contacts, historique — fonctionnent entièrement sur cet appareil, sans projet Firebase requis. Connectez un vrai backend plus tard depuis les Réglages.',
  'backendDemoButton': 'Continuer en mode démo',
  'deviceTypeStepTitleFirst': 'Étape 5 sur 5 · Ajoutez votre premier appareil',
  'deviceTypeStepTitleAdd': 'Ajouter un appareil',
  'deviceTypeHeading': 'Que configurez-vous ?',
  'deviceTypeSubtext': 'Chaque appareil est configuré indépendamment — ajoutez autant de puces et de boutons que nécessaire, un à la fois.',
  'gpsTrackerSubtitle': 'Localisation continue + alertes de zone de sécurité personnalisées',
  'alarmButtonSubtitle': "Silencieux jusqu'à activation — alerte instantanée et alarme sonore",
  'deviceTypeGpsName': 'Traceur GPS',
  'deviceTypeAlarmName': "Bouton d'alarme",
  'deviceSetupTitle': 'Nommez votre {type}',
  'deviceSetupHeading': 'Donnez un nom facile à reconnaître à cet appareil',
  'deviceSetupExample': 'Ex. « Sac d\'Emma » ou « Bouton porte d\'entrée ». Vous pourrez le modifier à tout moment depuis l\'écran de l\'appareil.',
  'deviceNameLabel': "Nom de l'appareil",
  'saveAndFinishButton': 'Enregistrer et terminer',
  'dashboardTitle': 'Mes appareils',
  'emptyStateTitle': "Aucun appareil pour l'instant",
  'emptyStateSubtitle': 'Ajoutez un traceur GPS ou un bouton d\'alarme pour commencer.',
  'addFirstDeviceButton': 'Ajouter votre premier appareil',
  'addDeviceButton': 'Ajouter un appareil',
  'deviceNotFound': 'Appareil introuvable',
  'renameDeviceTitle': "Renommer l'appareil",
  'cancelButton': 'Annuler',
  'saveButton': 'Enregistrer',
  'removeDeviceQuestion': "Supprimer l'appareil ?",
  'removeDeviceBody': "Cela le retire uniquement de l'application. Cela n'affecte aucun autre appareil.",
  'removeButton': 'Supprimer',
  'removeThisDeviceButton': 'Supprimer cet appareil',
  'historyTitle': 'Historique',
  'noActivityYet': 'Aucune activité pour le moment',
  'testWithoutHardwareTitle': 'Tester sans matériel',
  'waitingForFirstUpdate': 'En attente de la première position…',
  'justNowShort': 'À l\'instant',
  'minutesAgoShort': 'il y a {n} min',
  'hoursAgoShort': 'il y a {n} h',
  'daysAgoShort': 'il y a {n} j',
  'pollingInfo': 'Mise à jour toutes les {seconds}s · ~{min}-{max} jours d\'autonomie',
  'simulateLocationUpdate': 'Simuler une mise à jour de position',
  'simulateGeofenceBreach': 'Simuler une sortie de zone',
  'safeZoneTitle': 'Zone de sécurité',
  'addressLabel': 'Adresse ou lieu',
  'radiusLabel': 'Rayon : {radius} m',
  'saveSafeZoneButton': 'Enregistrer la zone de sécurité',
  'safeZoneSaved': 'Zone de sécurité enregistrée',
  'emergencyContactsTitle': "Contacts d'urgence",
  'belowMinimumContacts': 'Ajoutez au moins {min} contacts',
  'contactNameLabel': 'Nom',
  'addContactButton': 'Ajouter un contact',
  'saveContactsButton': 'Enregistrer les contacts',
  'contactsUpToDate': 'Enregistré',
  'contactsSaved': 'Contacts enregistrés',
  'contactsSaveFailed': 'Impossible d\u2019enregistrer les contacts\u00a0: {error}',
  'alarmActiveLabel': 'ALARME ACTIVE',
  'standingByLabel': 'En veille',
  'howItWorksTitle': 'Fonctionnement',
  'alarmInfoSilent': "Silencieux et invisible jusqu'à activation",
  'alarmInfoDeactivate': 'Désactivation avec exactement {count} pressions consécutives en {seconds}s — 1 ou 2 pressions ne font rien, pour éviter les accidents',
  'simulateButtonPress': 'Simuler une pression du bouton',
  'simulateDeactivation': 'Simuler {count} pressions de désactivation',
  'eventGeofenceBreach': 'Sortie de zone détectée',
  'eventAlarmTriggered': 'Alarme déclenchée',
  'eventAlarmCancelled': 'Alarme annulée (3 pressions)',
  'eventLocationPing': 'Mise à jour de position',
  'settingsTitle': 'Réglages',
  'settingsScopeNote': 'Ces réglages n\'affectent que votre propre compte — les autres contacts liés aux mêmes appareils conservent leurs propres préférences.',
  'languageLabel': 'Langue',
  'darkThemeLabel': 'Thème sombre',
  'legalSectionTitle': 'Mentions légales',
  'privacyConsentLabel': 'Consentement à la confidentialité',
  'acceptedLabel': 'Accepté',
  'accountSectionTitle': 'Compte',
  'signedInAs': 'Connecté en tant que {email}',
  'signOutButton': 'Se déconnecter',
  'backendSectionTitle': 'Backend',
  'backendModeDemo': 'Mode démo (données stockées uniquement sur cet appareil)',
  'backendModeConnected': 'Connecté au projet Firebase : {projectId}',
  'backendGuideStep1': 'Allez sur console.firebase.google.com et créez un projet gratuit (le plan gratuit Spark suffit).',
  'backendGuideStep2': 'Build → Authentication → Commencer : activez E-mail/Mot de passe et Anonyme (les appareils Grizzly se connectent en mode anonyme).',
  'backendGuideStep3': 'Build → Firestore Database → Créer une base de données (mode production, l\'emplacement le plus proche de vous).',
  'deviceUuidInvalid': 'Cet identifiant ne semble pas valide. Vérifiez-le dans la console Firebase et réessayez.',
  'deviceUuidDuplicate': 'Un appareil avec cet identifiant est déjà configuré. Chaque unité physique ne doit être ajoutée qu\'une fois.',
  'deviceUuidHelpTitle': 'Où trouver l\'identifiant de cet appareil ?',
  'deviceUuidHelpBody': 'Chaque appareil Grizzly crée un identifiant permanent lors de sa première connexion à votre projet Firebase. Une fois l\'appareil allumé et connecté, il apparaît sous « Appareils détectés ». Vous pouvez aussi le trouver dans la console Firebase : Firestore Database → families → family → devices. L\'identifiant du document est celui de l\'appareil. Saisissez-le exactement, tirets compris.',
  'firestoreRulesBody': 'Copiez ou téléchargez ce fichier, collez-le dans Firestore Database → Règles dans la console Firebase et cliquez sur Publier. Ainsi, seuls les membres de votre famille voient vos appareils, et chaque appareil Grizzly ne peut mettre à jour que ses propres données.',
  'alarmInfoTrigger': 'Une pression : l\'alarme sonne et vos contacts sont alertés immédiatement, la position suit',
  'testWithoutHardwareBody': 'Pas encore d\'appareil physique ? Simulez son comportement ci-dessous pour vérifier notifications, alertes et historique. Disponible uniquement en mode démo.',
  'backendGuideStep4': 'Paramètres du projet → Général → Vos applications : ajoutez une application Android (et iOS pour les iPhone), puis copiez l\'ID d\'application correspondant à ce téléphone.',
  'backendGuideStep5': 'Sur la même page, copiez l\'ID du projet, la clé API Web et le numéro du projet.',
  'backendGuideStep6': 'Saisissez-les ci-dessous. Le même ID de projet et la même clé API Web vont aussi dans le firmware des appareils (credentials.h).',
  'backendAppIdHelper': 'Ressemble à 1:123456789012:android:abc123… (utilisez l\'ID iOS sur un iPhone)',
  'backendSenderIdHelper': 'Le numéro du projet dans Paramètres du projet → Général',
  'backendJoinGuideStep1': 'Demandez à la personne qui a configuré Grizzly l\'ID de projet, la clé API Web, l\'ID d\'application et le numéro du projet.',
  'backendJoinGuideStep2': 'Demandez-lui d\'inviter votre e-mail (Réglages → Membres de la famille) avant votre inscription.',
  'backendRestartRequired': 'Un autre backend familial est encore chargé. Fermez et rouvrez Grizzly, puis réessayez.',
  'alarmInfoCheckIn': 'Se signale discrètement environ une fois par heure pour confirmer qu\'il fonctionne. Aucun enregistrement ni notification',
  'alertAlarmTitle': '🚨 ALARME : {name}',
  'alertAlarmBody': 'Le bouton d\'alarme a été pressé à {time}. Ouvrez Grizzly pour la position en direct.',
  'alertAlarmCancelledTitle': '{name} : alarme annulée',
  'alertAlarmCancelledBody': 'L\'alarme a été annulée à {time}.',
  'alertBreachTitle': '⚠️ {name} a quitté la zone de sécurité',
  'alertBreachBody': 'Sortie de la zone de sécurité à {time}. Ouvrez Grizzly pour voir où il se trouve.',
  'alertReturnTitle': '{name} est de retour dans la zone de sécurité',
  'alertReturnBody': 'De retour à {time}.',
  'alertStyleLabel': 'Notifications d\'alerte',
  'alertStyleSound': 'Son + vibration',
  'alertStyleVibrate': 'Vibration seulement',
  'backgroundMonitoringLabel': 'Surveiller en arrière-plan',
  'backgroundMonitoringHint': 'Permet de recevoir les alertes lorsque Grizzly est en arrière-plan. Affiche une petite notification permanente.',
  'chargingLabel': 'En charge',
  'checkAgainButton': 'Vérifier à nouveau',
  'contactEmailDuplicate': 'Chaque contact doit avoir un e-mail différent',
  'contactEmailInvalid': 'Saisissez une adresse e-mail valide',
  'contactEmailLabel': 'E-mail (son identifiant Grizzly)',
  'contactPhoneLabel': 'Téléphone (facultatif)',
  'contactsInfo': 'Les contacts reçoivent les alertes sur leur téléphone dès qu\'ils se connectent à Grizzly avec cet e-mail. Les nouveaux e-mails sont invités automatiquement dans votre famille.',
  'currentLocationLabel': 'Ma position actuelle',
  'detectedDeviceSubtitle': 'Dernière connexion {time}',
  'detectedDevicesEmpty': 'Aucun nouvel appareil. Allumez l\'appareil avec sa carte SIM ; il apparaît ici moins d\'une minute après la connexion.',
  'detectedDevicesTitle': 'Appareils détectés',
  'deviceTypeMismatch': 'Cet identifiant appartient à un appareil de type {type}. Choisissez ce type.',
  'disconnectBackendBody': 'Ce téléphone oublie le projet Firebase de votre famille et vous déconnecte. Aucune donnée familiale n\'est supprimée.',
  'disconnectBackendButton': 'Déconnecter ce téléphone de la famille',
  'disconnectBackendTitle': 'Se déconnecter de la famille ?',
  'doneButton': 'Terminé',
  'eventGeofenceReturn': 'Retour dans la zone de sécurité',
  'familyCheckFailed': 'Impossible de vérifier votre appartenance à la famille : {error}. Vérifiez que les règles de sécurité sont publiées.',
  'familyMembersInfo': 'Toutes les personnes listées ici peuvent voir et gérer les appareils de votre famille. Pour ajouter quelqu\'un, invitez son e-mail ; il s\'inscrit ensuite dans Grizzly avec cet e-mail.',
  'familyMembersTitle': 'Membres de la famille',
  'geofenceInside': 'Dans la zone de sécurité',
  'geofenceNotSet': 'Aucune zone de sécurité définie',
  'geofenceOutside': 'Hors de la zone de sécurité',
  'geofenceUnknown': 'État de la zone de sécurité inconnu pour l\'instant',
  'inviteButton': 'Inviter',
  'inviteMemberTitle': 'Inviter quelqu\'un',
  'inviteSent': '{email} peut maintenant rejoindre votre famille',
  'liveLocationTitle': 'Position en direct',
  'locationPermissionDenied': 'L\'autorisation de localisation a été refusée',
  'locationServicesOff': 'Activez d\'abord les services de localisation',
  'locationUnavailable': 'Impossible d\'obtenir votre position actuelle',
  'monitoringNotificationBody': 'Surveillance des alertes de vos appareils',
  'monitoringNotificationTitle': 'Grizzly est actif',
  'newDevicesDetected': 'Nouveaux appareils détectés : {n}. Touchez pour ajouter',
  'noPendingInvites': 'Aucune invitation en attente',
  'notificationsSectionTitle': 'Notifications',
  'orEnterIdManually': 'Sélectionnez un appareil détecté ci-dessus ou saisissez son identifiant',
  'ownerLabel': 'Propriétaire',
  'pendingInvitesTitle': 'Invitations en attente',
  'recenterMapTooltip': 'Centrer sur l\'appareil',
  'removeMemberBody': '{email} ne verra plus les appareils de votre famille.',
  'removeMemberTitle': 'Retirer ce membre ?',
  'removeSafeZoneButton': 'Supprimer la zone de sécurité',
  'repairButton': 'Réappairer',
  'repairDeviceBody': 'À utiliser lorsque l\'appareil a été reflashé et ne peut plus envoyer de mises à jour. Il reprendra cette fiche à sa prochaine connexion.',
  'repairDeviceTitle': 'Réappairer l\'appareil',
  'repairDone': 'L\'appareil peut se reconnecter',
  'revokeInviteTooltip': 'Annuler l\'invitation',
  'safeZoneNeedsCenter': 'Recherchez une adresse, utilisez votre position ou touchez la carte d\'abord',
  'safeZoneRemoved': 'Zone de sécurité supprimée',
  'saveFailed': 'Impossible d\'enregistrer : {error}',
  'searchAddressTooltip': 'Rechercher une adresse',
  'searchFailed': 'La recherche d\'adresse a échoué. Vérifiez votre connexion.',
  'searchNoResults': 'Aucun lieu trouvé',
  'securityRulesLabel': 'Règles de sécurité',
  'showMoreButton': 'Afficher plus',
  'simulateGeofenceReturn': 'Simuler un retour en zone de sécurité',
  'statusArmed': 'Armé · dernier signal {time}',
  'statusCheckInOverdue': 'Dernier signal {time}. Vérifiez la batterie et la couverture',
  'statusNeverConnected': 'En attente de la connexion de l\'appareil',
  'statusOffline': 'Hors ligne · dernière mise à jour {time}',
  'statusOnline': 'En ligne · mis à jour {time}',
  'stillNotInvited': 'Pas encore invité. Demandez à un membre de la famille d\'inviter votre e-mail.',
  'syncErrorBanner': 'Synchronisation impossible avec le backend familial. Vérifiez la connexion et la publication des règles de sécurité.',
  'tapMapToSetCenter': 'Touchez la carte pour placer le centre de la zone de sécurité',
  'testNotificationBody': 'Voici à quoi ressemblent les alertes Grizzly.',
  'testNotificationButton': 'Envoyer une alerte test',
  'testNotificationTitle': 'Alerte test Grizzly',
  'useMyLocationButton': 'Utiliser ma position actuelle',
  'waitingForAlarmLocation': 'Alerte envoyée. En attente de la position GPS du bouton…',
  'waitingInviteBody': 'Votre compte {email} ne fait pas encore partie de cette famille. Demandez à un membre d\'ouvrir Réglages → Membres de la famille dans Grizzly et d\'inviter cet e-mail, puis touchez Vérifier à nouveau.',
  'waitingInviteHeading': 'Presque terminé',
  'waitingInviteTitle': 'En attente d\'une invitation',
  'youLabel': 'Vous',
  'deviceUuidLabel': 'Identifiant de l\'appareil',
  'deviceUuidHint': 'p. ex. 550e8400-e29b-41d4-a716-446655440000',
};

const Map<String, String> _esValues = {
  'authWelcomeTitle': 'Bienvenido a Grizzly',
  'authSignUpSubtitle': 'Crea tu cuenta personal. Cada contacto tiene su propio inicio de sesión.',
  'authSignInSubtitle': 'Inicia sesión en tu cuenta de Grizzly.',
  'authEmailLabel': 'Correo electrónico',
  'authPasswordLabel': 'Contraseña',
  'authEmailInvalid': 'Introduce un correo electrónico válido',
  'authPasswordTooShort': 'La contraseña debe tener al menos 6 caracteres',
  'authSignUpButton': 'Crear cuenta',
  'authSignInButton': 'Iniciar sesión',
  'authToggleToSignIn': '¿Ya tienes una cuenta? Inicia sesión',
  'authToggleToSignUp': '¿No tienes una cuenta? Regístrate',
  'authIndividualNote': 'Cada contacto vinculado a un dispositivo inicia sesión por separado — tu idioma, tema e inicio de sesión son solo tuyos.',
  'authStepTitle': 'Paso 4 de 5 · Crea tu cuenta',
  'backendFieldsRequired': 'Por favor, introduce el ID del proyecto y la clave API.',
  'profileStepTitle': 'Paso 1 de 5 · Tu perfil',
  'profileHeading': 'Personalicemos tu cuenta',
  'profileSubtext': 'Esta información permanece solo en tu cuenta y no afecta la configuración de ningún dispositivo.',
  'firstNameLabel': 'Nombre',
  'lastNameLabel': 'Apellido',
  'ageLabel': 'Edad',
  'fieldRequired': 'Obligatorio',
  'ageInvalid': 'Introduce una edad válida',
  'continueButton': 'Continuar',
  'privacyStepTitle': 'Paso 2 de 5 · Privacidad',
  'privacyHeading': 'Antes de continuar',
  'privacyBody': 'Grizzly recopila y almacena datos de ubicación en tiempo real, eventos de zona segura y alertas de alarma para cada dispositivo que registres, para poder mostrártelos a ti y a los contactos de emergencia que configures.\n\nTus datos se almacenan en tu propio backend privado (que se vinculará en el siguiente paso) y nunca son visibles para otras familias que usan esta aplicación.\n\nDebes aceptar esto antes de usar Grizzly.',
  'privacyCheckboxLabel': 'Entiendo y acepto la recopilación y el almacenamiento de mis datos de ubicación y alertas.',
  'privacyAgreeButton': 'Acepto, continuar',
  'backendStepTitle': 'Paso 3 de 5 · Conecta tu backend',
  'backendHeading': 'Tu propia nube privada',
  'backendBody': 'Grizzly almacena tus datos en un proyecto de Firebase gratuito que te pertenece únicamente a ti — no un servidor compartido con otras familias. Esto mantiene todo privado y cuesta \$0 para el uso familiar típico.',
  'backendProjectIdLabel': 'ID del proyecto de Firebase',
  'backendApiKeyLabel': 'Clave de API web de Firebase',
  'backendAppIdLabel': 'ID de app de Firebase',
  'backendSenderIdLabel': 'ID de remitente de Firebase Messaging',
  'familyChoiceStepTitle': 'Configuración familiar',
  'familyChoiceHeading': '¿Es una familia nueva o te unes a una existente?',
  'familyChoiceSubtext':
      'Cada familia usa su propio proyecto de Firebase privado para guardar sus dispositivos. Elige lo que te corresponda.',
  'newFamilyOptionTitle': 'Configurar una familia nueva',
  'newFamilyOptionSubtitle':
      'Crearás un nuevo proyecto de Firebase y obtendrás las reglas de seguridad para implementarlas.',
  'joinFamilyOptionTitle': 'Unirme a una familia existente',
  'joinFamilyOptionSubtitle':
      'Alguien de tu familia ya configuró esto — ingresa los mismos datos del proyecto.',
  'backendJoinStepTitle': 'Conectar con el backend de tu familia',
  'backendJoinHeading': 'Ingresa los datos de Firebase existentes de tu familia',
  'backendJoinBody':
      'Pídele estos datos a quien configuró Grizzly para tu familia y luego ingrésalos abajo.',
  'firestoreRulesStepTitle': 'Reglas de seguridad',
  'firestoreRulesHeading': 'Un paso más: implementa estas reglas de seguridad',
  'copyRulesButton': 'Copiar',
  'downloadRulesButton': 'Descargar',
  'rulesCopiedToast': 'Reglas copiadas al portapapeles',
  'rulesDownloadFailed': 'No se pudo preparar el archivo. Intenta copiar en su lugar.',
  'rulesLoadFailed': 'No se pudo cargar el archivo de reglas.',
  'rulesDeployedContinueButton': 'Ya implementé las reglas \u2014 continuar',
  'backendLinkButton': 'Vincular mi proyecto y continuar',
  'backendLinkFailed': 'No se pudo conectar a ese proyecto de Firebase; verifica el ID del proyecto y la clave de API, o continúa en modo demo.',
  'backendDemoDividerLabel': 'o',
  'backendDemoTitle': '¿Solo quieres probar la aplicación?',
  'backendDemoBody': 'Omite este paso y ejecuta Grizzly en modo demo. Todas las funciones — dispositivos, alertas, contactos, historial — funcionan completamente en este dispositivo, sin necesidad de un proyecto de Firebase. Conecta un backend real más adelante desde Ajustes.',
  'backendDemoButton': 'Continuar en modo demo',
  'deviceTypeStepTitleFirst': 'Paso 5 de 5 · Añade tu primer dispositivo',
  'deviceTypeStepTitleAdd': 'Añadir un dispositivo',
  'deviceTypeHeading': '¿Qué vas a configurar?',
  'deviceTypeSubtext': 'Cada dispositivo se configura de forma independiente — puedes añadir tantos chips y botones como necesites, uno a la vez.',
  'gpsTrackerSubtitle': 'Ubicación continua + alertas de zona segura personalizadas',
  'alarmButtonSubtitle': 'Silencioso hasta que se presiona — alerta instantánea y alarma sonora',
  'deviceTypeGpsName': 'Rastreador GPS',
  'deviceTypeAlarmName': 'Botón de alarma',
  'deviceSetupTitle': 'Nombra tu {type}',
  'deviceSetupHeading': 'Dale a este dispositivo un nombre que reconozcas',
  'deviceSetupExample': 'Por ej. "Mochila de Emma" o "Botón puerta principal". Puedes cambiarlo en cualquier momento desde la pantalla del dispositivo.',
  'deviceNameLabel': 'Nombre del dispositivo',
  'saveAndFinishButton': 'Guardar y finalizar',
  'dashboardTitle': 'Mis dispositivos',
  'emptyStateTitle': 'Aún no hay dispositivos',
  'emptyStateSubtitle': 'Añade un rastreador GPS o un botón de alarma para empezar.',
  'addFirstDeviceButton': 'Añade tu primer dispositivo',
  'addDeviceButton': 'Añadir dispositivo',
  'deviceNotFound': 'Dispositivo no encontrado',
  'renameDeviceTitle': 'Renombrar dispositivo',
  'cancelButton': 'Cancelar',
  'saveButton': 'Guardar',
  'removeDeviceQuestion': '¿Eliminar dispositivo?',
  'removeDeviceBody': 'Esto solo lo elimina de la aplicación. No afecta a ningún otro dispositivo.',
  'removeButton': 'Eliminar',
  'removeThisDeviceButton': 'Eliminar este dispositivo',
  'historyTitle': 'Historial',
  'noActivityYet': 'Aún no hay actividad',
  'testWithoutHardwareTitle': 'Probar sin hardware',
  'waitingForFirstUpdate': 'Esperando la primera actualización de ubicación…',
  'justNowShort': 'Justo ahora',
  'minutesAgoShort': 'hace {n} min',
  'hoursAgoShort': 'hace {n} h',
  'daysAgoShort': 'hace {n} d',
  'pollingInfo': 'Se actualiza cada {seconds}s · ~{min}-{max} días de batería',
  'simulateLocationUpdate': 'Simular actualización de ubicación',
  'simulateGeofenceBreach': 'Simular salida de zona segura',
  'safeZoneTitle': 'Zona segura',
  'addressLabel': 'Dirección o lugar',
  'radiusLabel': 'Radio: {radius} m',
  'saveSafeZoneButton': 'Guardar zona segura',
  'safeZoneSaved': 'Zona segura guardada',
  'emergencyContactsTitle': 'Contactos de emergencia',
  'belowMinimumContacts': 'Añade al menos {min} contactos',
  'contactNameLabel': 'Nombre',
  'addContactButton': 'Añadir contacto',
  'saveContactsButton': 'Guardar contactos',
  'contactsUpToDate': 'Guardado',
  'contactsSaved': 'Contactos guardados',
  'contactsSaveFailed': 'No se pudieron guardar los contactos: {error}',
  'alarmActiveLabel': 'ALARMA ACTIVA',
  'standingByLabel': 'En espera',
  'howItWorksTitle': 'Cómo funciona',
  'alarmInfoSilent': 'Silencioso e invisible hasta que se presiona',
  'alarmInfoDeactivate': 'Desactivar con exactamente {count} pulsaciones consecutivas en {seconds}s — 1 o 2 pulsaciones no hacen nada, para evitar accidentes',
  'simulateButtonPress': 'Simular pulsación del botón',
  'simulateDeactivation': 'Simular {count} pulsaciones de desactivación',
  'eventGeofenceBreach': 'Salida de zona segura',
  'eventAlarmTriggered': 'Alarma activada',
  'eventAlarmCancelled': 'Alarma cancelada (3 pulsaciones)',
  'eventLocationPing': 'Actualización de ubicación',
  'settingsTitle': 'Ajustes',
  'settingsScopeNote': 'Estos ajustes solo afectan a tu propia cuenta — otros contactos en los mismos dispositivos conservan sus propias preferencias.',
  'languageLabel': 'Idioma',
  'darkThemeLabel': 'Tema oscuro',
  'legalSectionTitle': 'Legal',
  'privacyConsentLabel': 'Consentimiento de privacidad',
  'acceptedLabel': 'Aceptado',
  'accountSectionTitle': 'Cuenta',
  'signedInAs': 'Sesión iniciada como {email}',
  'signOutButton': 'Cerrar sesión',
  'backendSectionTitle': 'Backend',
  'backendModeDemo': 'Modo demo (datos almacenados solo en este dispositivo)',
  'backendModeConnected': 'Conectado al proyecto de Firebase: {projectId}',
  'backendGuideStep1': 'Ve a console.firebase.google.com y crea un proyecto gratuito (el plan gratuito Spark es suficiente).',
  'backendGuideStep2': 'Build → Authentication → Comenzar: activa Correo/Contraseña y Anónimo (los dispositivos Grizzly inician sesión de forma anónima).',
  'backendGuideStep3': 'Build → Firestore Database → Crear base de datos (modo producción, la ubicación más cercana a ti).',
  'deviceUuidInvalid': 'Ese ID de dispositivo no parece válido. Compruébalo en la consola de Firebase e inténtalo de nuevo.',
  'deviceUuidDuplicate': 'Ya hay un dispositivo configurado con este ID. Cada unidad física solo debe añadirse una vez.',
  'deviceUuidHelpTitle': '¿Dónde encuentro el ID de este dispositivo?',
  'deviceUuidHelpBody': 'Cada dispositivo Grizzly crea un ID permanente la primera vez que se conecta a tu proyecto de Firebase. Cuando el dispositivo está encendido y conectado, aparece en «Dispositivos detectados». También puedes encontrarlo en la consola de Firebase: Firestore Database → families → family → devices. El ID del documento es el ID del dispositivo. Introdúcelo exactamente, con los guiones.',
  'firestoreRulesBody': 'Copia o descarga este archivo, pégalo en Firestore Database → Reglas en la consola de Firebase y pulsa Publicar. Así solo los miembros de tu familia ven tus dispositivos y cada dispositivo Grizzly solo puede actualizar sus propios datos.',
  'alarmInfoTrigger': 'Una pulsación: suena la alarma y tus contactos reciben el aviso de inmediato; la ubicación llega después',
  'testWithoutHardwareBody': '¿Aún no tienes un dispositivo físico? Simula su comportamiento para comprobar notificaciones, alertas e historial. Solo disponible en modo demo.',
  'backendGuideStep4': 'Configuración del proyecto → General → Tus apps: añade una app Android (y una app iOS para iPhone) y copia el App ID de la plataforma de este teléfono.',
  'backendGuideStep5': 'En la misma página copia el ID del proyecto, la clave de API web y el número del proyecto.',
  'backendGuideStep6': 'Introdúcelos abajo. El mismo ID de proyecto y clave de API web van también en el firmware de los dispositivos (credentials.h).',
  'backendAppIdHelper': 'Tiene el formato 1:123456789012:android:abc123… (usa el App ID de iOS en un iPhone)',
  'backendSenderIdHelper': 'El número del proyecto en Configuración del proyecto → General',
  'backendJoinGuideStep1': 'Pide a quien configuró Grizzly el ID de proyecto, la clave de API web, el App ID y el número del proyecto.',
  'backendJoinGuideStep2': 'Pídele que invite tu correo (Ajustes → Miembros de la familia) antes de registrarte.',
  'backendRestartRequired': 'Aún hay otro backend familiar cargado. Cierra y vuelve a abrir Grizzly e inténtalo de nuevo.',
  'alarmInfoCheckIn': 'Se registra discretamente una vez por hora para confirmar que funciona. Sin registros ni notificaciones',
  'alertAlarmTitle': '🚨 ALARMA: {name}',
  'alertAlarmBody': 'El botón de alarma se pulsó a las {time}. Abre Grizzly para ver la ubicación en vivo.',
  'alertAlarmCancelledTitle': '{name}: alarma cancelada',
  'alertAlarmCancelledBody': 'La alarma se canceló a las {time}.',
  'alertBreachTitle': '⚠️ {name} salió de la zona segura',
  'alertBreachBody': 'Salió de la zona segura a las {time}. Abre Grizzly para ver dónde está.',
  'alertReturnTitle': '{name} ha vuelto a la zona segura',
  'alertReturnBody': 'De vuelta a las {time}.',
  'alertStyleLabel': 'Notificaciones de alerta',
  'alertStyleSound': 'Sonido + vibración',
  'alertStyleVibrate': 'Solo vibración',
  'backgroundMonitoringLabel': 'Vigilar en segundo plano',
  'backgroundMonitoringHint': 'Permite seguir recibiendo alertas con Grizzly en segundo plano. Muestra una pequeña notificación permanente.',
  'chargingLabel': 'Cargando',
  'checkAgainButton': 'Comprobar de nuevo',
  'contactEmailDuplicate': 'Cada contacto necesita un correo distinto',
  'contactEmailInvalid': 'Introduce un correo electrónico válido',
  'contactEmailLabel': 'Correo (su acceso a Grizzly)',
  'contactPhoneLabel': 'Teléfono (opcional)',
  'contactsInfo': 'Los contactos reciben alertas en su propio teléfono cuando inician sesión en Grizzly con este correo. Los correos nuevos se invitan automáticamente a tu familia.',
  'currentLocationLabel': 'Mi ubicación actual',
  'detectedDeviceSubtitle': 'Última conexión {time}',
  'detectedDevicesEmpty': 'Aún no hay dispositivos nuevos. Enciende el dispositivo con su SIM puesta; aparecerá aquí en menos de un minuto tras conectarse.',
  'detectedDevicesTitle': 'Dispositivos detectados',
  'deviceTypeMismatch': 'Este ID pertenece a un {type}. Elige ese tipo de dispositivo.',
  'disconnectBackendBody': 'Este teléfono olvidará el proyecto de Firebase de tu familia y cerrará tu sesión. No se borra ningún dato familiar.',
  'disconnectBackendButton': 'Desconectar este teléfono de la familia',
  'disconnectBackendTitle': '¿Desconectar de la familia?',
  'doneButton': 'Hecho',
  'eventGeofenceReturn': 'De vuelta en la zona segura',
  'familyCheckFailed': 'No se pudo comprobar tu pertenencia a la familia: {error}. Asegúrate de que las reglas de seguridad estén publicadas.',
  'familyMembersInfo': 'Todas las personas de esta lista pueden ver y gestionar los dispositivos de tu familia. Para añadir a alguien, invita su correo; después se registrará en Grizzly con ese correo.',
  'familyMembersTitle': 'Miembros de la familia',
  'geofenceInside': 'Dentro de la zona segura',
  'geofenceNotSet': 'Sin zona segura definida',
  'geofenceOutside': 'Fuera de la zona segura',
  'geofenceUnknown': 'Estado de la zona segura aún desconocido',
  'inviteButton': 'Invitar',
  'inviteMemberTitle': 'Invitar a alguien',
  'inviteSent': '{email} ya puede unirse a tu familia',
  'liveLocationTitle': 'Ubicación en vivo',
  'locationPermissionDenied': 'Se denegó el permiso de ubicación',
  'locationServicesOff': 'Activa primero los servicios de ubicación',
  'locationUnavailable': 'No se pudo obtener tu ubicación actual',
  'monitoringNotificationBody': 'Vigilando las alertas de tus dispositivos',
  'monitoringNotificationTitle': 'Grizzly está activo',
  'newDevicesDetected': 'Dispositivos nuevos detectados: {n}. Toca para añadir',
  'noPendingInvites': 'No hay invitaciones pendientes',
  'notificationsSectionTitle': 'Notificaciones',
  'orEnterIdManually': 'Selecciona arriba un dispositivo detectado o introduce su ID',
  'ownerLabel': 'Propietario',
  'pendingInvitesTitle': 'Invitaciones pendientes',
  'recenterMapTooltip': 'Centrar en el dispositivo',
  'removeMemberBody': '{email} ya no verá los dispositivos de tu familia.',
  'removeMemberTitle': '¿Eliminar miembro?',
  'removeSafeZoneButton': 'Eliminar zona segura',
  'repairButton': 'Volver a vincular',
  'repairDeviceBody': 'Úsalo cuando el dispositivo se haya vuelto a programar y ya no pueda enviar actualizaciones. Reclamará esta entrada en su próxima conexión.',
  'repairDeviceTitle': 'Volver a vincular el dispositivo',
  'repairDone': 'El dispositivo ya puede reconectarse',
  'revokeInviteTooltip': 'Cancelar invitación',
  'safeZoneNeedsCenter': 'Primero busca una dirección, usa tu ubicación o toca el mapa',
  'safeZoneRemoved': 'Zona segura eliminada',
  'saveFailed': 'No se pudo guardar: {error}',
  'searchAddressTooltip': 'Buscar dirección',
  'searchFailed': 'La búsqueda de direcciones falló. Comprueba tu conexión.',
  'searchNoResults': 'No se encontraron lugares',
  'securityRulesLabel': 'Reglas de seguridad',
  'showMoreButton': 'Mostrar más',
  'simulateGeofenceReturn': 'Simular regreso a la zona segura',
  'statusArmed': 'Armado · último registro {time}',
  'statusCheckInOverdue': 'Último registro {time}. Comprueba la batería y la cobertura',
  'statusNeverConnected': 'Esperando a que el dispositivo se conecte',
  'statusOffline': 'Sin conexión · última actualización {time}',
  'statusOnline': 'En línea · actualizado {time}',
  'stillNotInvited': 'Aún no te han invitado. Pide a un familiar que invite tu correo.',
  'syncErrorBanner': 'No se puede sincronizar con el backend de tu familia. Comprueba la conexión y que las reglas de seguridad estén publicadas.',
  'tapMapToSetCenter': 'Toca el mapa para situar el centro de la zona segura',
  'testNotificationBody': 'Así se ven y se sienten las alertas de Grizzly.',
  'testNotificationButton': 'Enviar una alerta de prueba',
  'testNotificationTitle': 'Alerta de prueba de Grizzly',
  'useMyLocationButton': 'Usar mi ubicación actual',
  'waitingForAlarmLocation': 'Alerta enviada. Esperando la ubicación GPS del botón…',
  'waitingInviteBody': 'Tu cuenta {email} todavía no forma parte de esta familia. Pide a un familiar que abra Ajustes → Miembros de la familia en Grizzly e invite este correo, y luego pulsa Comprobar de nuevo.',
  'waitingInviteHeading': 'Ya casi está',
  'waitingInviteTitle': 'Esperando una invitación',
  'youLabel': 'Tú',
  'deviceUuidLabel': 'ID del dispositivo',
  'deviceUuidHint': 'p. ej. 550e8400-e29b-41d4-a716-446655440000',
};

const Map<String, String> _itValues = {
  'authWelcomeTitle': 'Benvenuto su Grizzly',
  'authSignUpSubtitle': 'Crea il tuo account personale. Ogni contatto ha il proprio accesso separato.',
  'authSignInSubtitle': 'Accedi al tuo account Grizzly.',
  'authEmailLabel': 'Email',
  'authPasswordLabel': 'Password',
  'authEmailInvalid': 'Inserisci un indirizzo email valido',
  'authPasswordTooShort': 'La password deve contenere almeno 6 caratteri',
  'authSignUpButton': 'Crea account',
  'authSignInButton': 'Accedi',
  'authToggleToSignIn': 'Hai già un account? Accedi',
  'authToggleToSignUp': 'Non hai un account? Registrati',
  'authIndividualNote': 'Ogni contatto collegato a un dispositivo accede separatamente — la tua lingua, il tema e il tuo accesso sono solo tuoi.',
  'authStepTitle': 'Passo 4 di 5 · Crea il tuo account',
  'backendFieldsRequired': 'Inserisci sia l\'ID progetto che la chiave API.',
  'profileStepTitle': 'Passo 1 di 5 · Il tuo profilo',
  'profileHeading': 'Personalizziamo il tuo account',
  'profileSubtext': 'Queste informazioni restano legate solo al tuo account e non influenzano le impostazioni di alcun dispositivo.',
  'firstNameLabel': 'Nome',
  'lastNameLabel': 'Cognome',
  'ageLabel': 'Età',
  'fieldRequired': 'Obbligatorio',
  'ageInvalid': 'Inserisci un\'età valida',
  'continueButton': 'Continua',
  'privacyStepTitle': 'Passo 2 di 5 · Privacy',
  'privacyHeading': 'Prima di continuare',
  'privacyBody': 'Grizzly raccoglie e memorizza dati di posizione in tempo reale, eventi di zona sicura e avvisi di allarme per ogni dispositivo registrato, per poterli mostrare a te e ai contatti di emergenza configurati.\n\nI tuoi dati sono memorizzati nel tuo backend privato (da collegare nel passo successivo) e non sono mai visibili ad altre famiglie che usano questa app.\n\nDevi accettare questo prima di usare Grizzly.',
  'privacyCheckboxLabel': 'Comprendo e accetto la raccolta e la memorizzazione dei miei dati di posizione e allarme.',
  'privacyAgreeButton': 'Accetto, continua',
  'backendStepTitle': 'Passo 3 di 5 · Collega il tuo backend',
  'backendHeading': 'Il tuo cloud privato',
  'backendBody': 'Grizzly memorizza i tuoi dati in un progetto Firebase gratuito che appartiene solo a te — non un server condiviso con altre famiglie. Questo mantiene tutto privato e costa 0 \$ per un uso familiare tipico.',
  'backendProjectIdLabel': 'ID progetto Firebase',
  'backendApiKeyLabel': 'Chiave API Web Firebase',
  'backendAppIdLabel': 'ID app Firebase',
  'backendSenderIdLabel': 'ID mittente Firebase Messaging',
  'familyChoiceStepTitle': 'Configurazione famiglia',
  'familyChoiceHeading': 'È una nuova famiglia o ti stai unendo a una esistente?',
  'familyChoiceSubtext':
      'Ogni famiglia usa il proprio progetto Firebase privato per salvare i dispositivi. Scegli l\'opzione giusta per te.',
  'newFamilyOptionTitle': 'Configura una nuova famiglia',
  'newFamilyOptionSubtitle':
      'Creerai un nuovo progetto Firebase e otterrai le regole di sicurezza da distribuire.',
  'joinFamilyOptionTitle': 'Unisciti a una famiglia esistente',
  'joinFamilyOptionSubtitle':
      'Qualcuno della tua famiglia ha già configurato tutto — inserisci gli stessi dati del progetto.',
  'backendJoinStepTitle': 'Connettiti al backend della tua famiglia',
  'backendJoinHeading': 'Inserisci i dati Firebase esistenti della tua famiglia',
  'backendJoinBody':
      'Chiedi questi dati a chi ha configurato Grizzly per la tua famiglia, poi inseriscili qui sotto.',
  'firestoreRulesStepTitle': 'Regole di sicurezza',
  'firestoreRulesHeading': 'Un ultimo passo: distribuisci queste regole di sicurezza',
  'copyRulesButton': 'Copia',
  'downloadRulesButton': 'Scarica',
  'rulesCopiedToast': 'Regole copiate negli appunti',
  'rulesDownloadFailed': 'Impossibile preparare il file. Prova a copiare invece.',
  'rulesLoadFailed': 'Impossibile caricare il file delle regole.',
  'rulesDeployedContinueButton': 'Ho distribuito le regole \u2014 continua',
  'backendLinkButton': 'Collega il mio progetto e continua',
  'backendLinkFailed': "Impossibile connettersi a quel progetto Firebase: controlla l'ID progetto e la chiave API, oppure continua in modalità demo.",
  'backendDemoDividerLabel': 'oppure',
  'backendDemoTitle': 'Vuoi solo provare l\'app?',
  'backendDemoBody': 'Salta questo passaggio e usa Grizzly in modalità demo. Tutte le funzioni — dispositivi, avvisi, contatti, cronologia — funzionano completamente su questo dispositivo, senza bisogno di un progetto Firebase. Collega un backend reale in seguito dalle Impostazioni.',
  'backendDemoButton': 'Continua in modalità demo',
  'deviceTypeStepTitleFirst': 'Passo 5 di 5 · Aggiungi il tuo primo dispositivo',
  'deviceTypeStepTitleAdd': 'Aggiungi un dispositivo',
  'deviceTypeHeading': 'Cosa stai configurando?',
  'deviceTypeSubtext': 'Ogni dispositivo viene configurato in modo indipendente — puoi aggiungere tutti i chip e i pulsanti che ti servono, uno alla volta.',
  'gpsTrackerSubtitle': 'Posizione continua + avvisi di zona sicura personalizzati',
  'alarmButtonSubtitle': 'Silenzioso finché non viene premuto — avviso istantaneo e allarme sonoro',
  'deviceTypeGpsName': 'Localizzatore GPS',
  'deviceTypeAlarmName': 'Pulsante di allarme',
  'deviceSetupTitle': 'Assegna un nome al tuo {type}',
  'deviceSetupHeading': 'Dai a questo dispositivo un nome che riconoscerai',
  'deviceSetupExample': 'Es. "Zaino di Emma" o "Pulsante porta d\'ingresso". Potrai modificarlo in qualsiasi momento dalla schermata del dispositivo.',
  'deviceNameLabel': 'Nome del dispositivo',
  'saveAndFinishButton': 'Salva e termina',
  'dashboardTitle': 'I miei dispositivi',
  'emptyStateTitle': 'Nessun dispositivo ancora',
  'emptyStateSubtitle': 'Aggiungi un localizzatore GPS o un pulsante di allarme per iniziare.',
  'addFirstDeviceButton': 'Aggiungi il tuo primo dispositivo',
  'addDeviceButton': 'Aggiungi dispositivo',
  'deviceNotFound': 'Dispositivo non trovato',
  'renameDeviceTitle': 'Rinomina dispositivo',
  'cancelButton': 'Annulla',
  'saveButton': 'Salva',
  'removeDeviceQuestion': 'Rimuovere il dispositivo?',
  'removeDeviceBody': 'Questo lo rimuove solo dall\'app. Non influisce su nessun altro dispositivo.',
  'removeButton': 'Rimuovi',
  'removeThisDeviceButton': 'Rimuovi questo dispositivo',
  'historyTitle': 'Cronologia',
  'noActivityYet': 'Nessuna attività ancora',
  'testWithoutHardwareTitle': 'Testa senza hardware',
  'waitingForFirstUpdate': 'In attesa del primo aggiornamento di posizione…',
  'justNowShort': 'Proprio ora',
  'minutesAgoShort': '{n} min fa',
  'hoursAgoShort': '{n} h fa',
  'daysAgoShort': '{n} g fa',
  'pollingInfo': 'Aggiornamento ogni {seconds}s · ~{min}-{max} giorni di autonomia',
  'simulateLocationUpdate': 'Simula aggiornamento posizione',
  'simulateGeofenceBreach': 'Simula uscita dalla zona sicura',
  'safeZoneTitle': 'Zona sicura',
  'addressLabel': 'Indirizzo o luogo',
  'radiusLabel': 'Raggio: {radius} m',
  'saveSafeZoneButton': 'Salva zona sicura',
  'safeZoneSaved': 'Zona sicura salvata',
  'emergencyContactsTitle': 'Contatti di emergenza',
  'belowMinimumContacts': 'Aggiungi almeno {min} contatti',
  'contactNameLabel': 'Nome',
  'addContactButton': 'Aggiungi contatto',
  'saveContactsButton': 'Salva contatti',
  'contactsUpToDate': 'Salvato',
  'contactsSaved': 'Contatti salvati',
  'contactsSaveFailed': 'Impossibile salvare i contatti: {error}',
  'alarmActiveLabel': 'ALLARME ATTIVO',
  'standingByLabel': 'In attesa',
  'howItWorksTitle': 'Come funziona',
  'alarmInfoSilent': 'Silenzioso e invisibile finché non viene premuto',
  'alarmInfoDeactivate': 'Disattiva con esattamente {count} pressioni consecutive entro {seconds}s — 1 o 2 pressioni non fanno nulla, per evitare attivazioni accidentali',
  'simulateButtonPress': 'Simula pressione del pulsante',
  'simulateDeactivation': 'Simula {count} pressioni di disattivazione',
  'eventGeofenceBreach': 'Uscita dalla zona sicura',
  'eventAlarmTriggered': 'Allarme attivato',
  'eventAlarmCancelled': 'Allarme annullato (3 pressioni)',
  'eventLocationPing': 'Aggiornamento posizione',
  'settingsTitle': 'Impostazioni',
  'settingsScopeNote': 'Queste impostazioni riguardano solo il tuo account — gli altri contatti sugli stessi dispositivi mantengono le proprie preferenze.',
  'languageLabel': 'Lingua',
  'darkThemeLabel': 'Tema scuro',
  'legalSectionTitle': 'Legale',
  'privacyConsentLabel': 'Consenso privacy',
  'acceptedLabel': 'Accettato',
  'accountSectionTitle': 'Account',
  'signedInAs': 'Accesso effettuato come {email}',
  'signOutButton': 'Esci',
  'backendSectionTitle': 'Backend',
  'backendModeDemo': 'Modalità demo (dati salvati solo su questo dispositivo)',
  'backendModeConnected': 'Connesso al progetto Firebase: {projectId}',
  'backendGuideStep1': 'Vai su console.firebase.google.com e crea un progetto gratuito (il piano gratuito Spark è sufficiente).',
  'backendGuideStep2': 'Build → Authentication → Inizia: attiva Email/Password e Anonimo (i dispositivi Grizzly accedono in modo anonimo).',
  'backendGuideStep3': 'Build → Firestore Database → Crea database (modalità produzione, la località più vicina a te).',
  'deviceUuidInvalid': 'Questo ID dispositivo non sembra valido. Controllalo nella console Firebase e riprova.',
  'deviceUuidDuplicate': 'Un dispositivo con questo ID è già configurato. Ogni unità fisica va aggiunta una sola volta.',
  'deviceUuidHelpTitle': 'Dove trovo l\'ID di questo dispositivo?',
  'deviceUuidHelpBody': 'Ogni dispositivo Grizzly crea un ID permanente alla prima connessione al tuo progetto Firebase. Quando il dispositivo è acceso e connesso, compare in «Dispositivi rilevati». Puoi trovarlo anche nella console Firebase: Firestore Database → families → family → devices. L\'ID del documento è l\'ID del dispositivo. Inseriscilo esattamente, trattini inclusi.',
  'firestoreRulesBody': 'Copia o scarica questo file, incollalo in Firestore Database → Regole nella console Firebase e premi Pubblica. Così solo i membri della tua famiglia vedono i dispositivi e ogni dispositivo Grizzly può aggiornare solo i propri dati.',
  'alarmInfoTrigger': 'Una pressione: l\'allarme suona e i contatti vengono avvisati subito, la posizione arriva dopo',
  'testWithoutHardwareBody': 'Non hai ancora un dispositivo fisico? Simula il suo comportamento per verificare notifiche, avvisi e cronologia. Disponibile solo in modalità demo.',
  'backendGuideStep4': 'Impostazioni progetto → Generali → Le tue app: aggiungi un\'app Android (e un\'app iOS per iPhone), poi copia l\'App ID della piattaforma di questo telefono.',
  'backendGuideStep5': 'Nella stessa pagina copia l\'ID progetto, la chiave API Web e il numero del progetto.',
  'backendGuideStep6': 'Inseriscili qui sotto. Lo stesso ID progetto e la stessa chiave API Web vanno anche nel firmware dei dispositivi (credentials.h).',
  'backendAppIdHelper': 'Ha la forma 1:123456789012:android:abc123… (su iPhone usa l\'App ID iOS)',
  'backendSenderIdHelper': 'Il numero del progetto in Impostazioni progetto → Generali',
  'backendJoinGuideStep1': 'Chiedi a chi ha configurato Grizzly l\'ID progetto, la chiave API Web, l\'App ID e il numero del progetto.',
  'backendJoinGuideStep2': 'Chiedigli di invitare la tua email (Impostazioni → Membri della famiglia) prima di registrarti.',
  'backendRestartRequired': 'È ancora caricato un altro backend familiare. Chiudi e riapri Grizzly, poi riprova.',
  'alarmInfoCheckIn': 'Si segnala in modo discreto circa una volta all\'ora per confermare che funziona. Nessun registro né notifica',
  'alertAlarmTitle': '🚨 ALLARME: {name}',
  'alertAlarmBody': 'Il pulsante di allarme è stato premuto alle {time}. Apri Grizzly per la posizione in tempo reale.',
  'alertAlarmCancelledTitle': '{name}: allarme annullato',
  'alertAlarmCancelledBody': 'L\'allarme è stato annullato alle {time}.',
  'alertBreachTitle': '⚠️ {name} ha lasciato la zona sicura',
  'alertBreachBody': 'Uscito dalla zona sicura alle {time}. Apri Grizzly per vedere dov\'è.',
  'alertReturnTitle': '{name} è tornato nella zona sicura',
  'alertReturnBody': 'Rientrato alle {time}.',
  'alertStyleLabel': 'Notifiche di allerta',
  'alertStyleSound': 'Suono + vibrazione',
  'alertStyleVibrate': 'Solo vibrazione',
  'backgroundMonitoringLabel': 'Monitora in background',
  'backgroundMonitoringHint': 'Continua a ricevere gli avvisi con Grizzly in background. Mostra una piccola notifica permanente.',
  'chargingLabel': 'In carica',
  'checkAgainButton': 'Controlla di nuovo',
  'contactEmailDuplicate': 'Ogni contatto deve avere un\'email diversa',
  'contactEmailInvalid': 'Inserisci un indirizzo email valido',
  'contactEmailLabel': 'Email (il suo accesso Grizzly)',
  'contactPhoneLabel': 'Telefono (facoltativo)',
  'contactsInfo': 'I contatti ricevono gli avvisi sul proprio telefono dopo aver effettuato l\'accesso a Grizzly con questa email. Le nuove email vengono invitate automaticamente nella tua famiglia.',
  'currentLocationLabel': 'La mia posizione attuale',
  'detectedDeviceSubtitle': 'Ultima connessione {time}',
  'detectedDevicesEmpty': 'Nessun nuovo dispositivo. Accendi il dispositivo con la SIM inserita: comparirà qui entro un minuto dalla connessione.',
  'detectedDevicesTitle': 'Dispositivi rilevati',
  'deviceTypeMismatch': 'Questo ID appartiene a un {type}. Scegli quel tipo di dispositivo.',
  'disconnectBackendBody': 'Questo telefono dimenticherà il progetto Firebase della famiglia e uscirà dal tuo account. Nessun dato familiare viene eliminato.',
  'disconnectBackendButton': 'Disconnetti questo telefono dalla famiglia',
  'disconnectBackendTitle': 'Disconnettersi dalla famiglia?',
  'doneButton': 'Fatto',
  'eventGeofenceReturn': 'Rientro nella zona sicura',
  'familyCheckFailed': 'Impossibile verificare la tua appartenenza alla famiglia: {error}. Assicurati che le regole di sicurezza siano pubblicate.',
  'familyMembersInfo': 'Tutte le persone elencate qui possono vedere e gestire i dispositivi della famiglia. Per aggiungere qualcuno, invita la sua email; poi si registrerà in Grizzly con quella email.',
  'familyMembersTitle': 'Membri della famiglia',
  'geofenceInside': 'Nella zona sicura',
  'geofenceNotSet': 'Nessuna zona sicura impostata',
  'geofenceOutside': 'Fuori dalla zona sicura',
  'geofenceUnknown': 'Stato della zona sicura non ancora noto',
  'inviteButton': 'Invita',
  'inviteMemberTitle': 'Invita qualcuno',
  'inviteSent': '{email} ora può unirsi alla tua famiglia',
  'liveLocationTitle': 'Posizione in tempo reale',
  'locationPermissionDenied': 'Autorizzazione alla posizione negata',
  'locationServicesOff': 'Attiva prima i servizi di localizzazione',
  'locationUnavailable': 'Impossibile ottenere la tua posizione attuale',
  'monitoringNotificationBody': 'Monitoraggio degli avvisi dei tuoi dispositivi',
  'monitoringNotificationTitle': 'Grizzly è attivo',
  'newDevicesDetected': 'Nuovi dispositivi rilevati: {n}. Tocca per aggiungere',
  'noPendingInvites': 'Nessun invito in sospeso',
  'notificationsSectionTitle': 'Notifiche',
  'orEnterIdManually': 'Seleziona sopra un dispositivo rilevato oppure inserisci il suo ID',
  'ownerLabel': 'Proprietario',
  'pendingInvitesTitle': 'Inviti in sospeso',
  'recenterMapTooltip': 'Centra sul dispositivo',
  'removeMemberBody': '{email} non vedrà più i dispositivi della tua famiglia.',
  'removeMemberTitle': 'Rimuovere il membro?',
  'removeSafeZoneButton': 'Rimuovi zona sicura',
  'repairButton': 'Riassocia',
  'repairDeviceBody': 'Usalo quando il dispositivo è stato riprogrammato e non riesce più a inviare aggiornamenti. Riprenderà questa voce alla prossima connessione.',
  'repairDeviceTitle': 'Riassocia dispositivo',
  'repairDone': 'Il dispositivo ora può riconnettersi',
  'revokeInviteTooltip': 'Annulla invito',
  'safeZoneNeedsCenter': 'Prima cerca un indirizzo, usa la tua posizione o tocca la mappa',
  'safeZoneRemoved': 'Zona sicura rimossa',
  'saveFailed': 'Impossibile salvare: {error}',
  'searchAddressTooltip': 'Cerca indirizzo',
  'searchFailed': 'Ricerca dell\'indirizzo non riuscita. Controlla la connessione.',
  'searchNoResults': 'Nessun luogo trovato',
  'securityRulesLabel': 'Regole di sicurezza',
  'showMoreButton': 'Mostra altro',
  'simulateGeofenceReturn': 'Simula rientro nella zona sicura',
  'statusArmed': 'Armato · ultimo segnale {time}',
  'statusCheckInOverdue': 'Ultimo segnale {time}. Controlla batteria e copertura',
  'statusNeverConnected': 'In attesa della connessione del dispositivo',
  'statusOffline': 'Offline · ultimo aggiornamento {time}',
  'statusOnline': 'Online · aggiornato {time}',
  'stillNotInvited': 'Non ancora invitato. Chiedi a un membro della famiglia di invitare la tua email.',
  'syncErrorBanner': 'Impossibile sincronizzare con il backend della famiglia. Controlla la connessione e che le regole di sicurezza siano pubblicate.',
  'tapMapToSetCenter': 'Tocca la mappa per posizionare il centro della zona sicura',
  'testNotificationBody': 'Ecco come appaiono gli avvisi di Grizzly.',
  'testNotificationButton': 'Invia un avviso di prova',
  'testNotificationTitle': 'Avviso di prova Grizzly',
  'useMyLocationButton': 'Usa la mia posizione attuale',
  'waitingForAlarmLocation': 'Avviso inviato. In attesa della posizione GPS del pulsante…',
  'waitingInviteBody': 'Il tuo account {email} non fa ancora parte di questa famiglia. Chiedi a un membro di aprire Impostazioni → Membri della famiglia in Grizzly e invitare questa email, poi tocca Controlla di nuovo.',
  'waitingInviteHeading': 'Ci siamo quasi',
  'waitingInviteTitle': 'In attesa di un invito',
  'youLabel': 'Tu',
  'deviceUuidLabel': 'ID del dispositivo',
  'deviceUuidHint': 'es. 550e8400-e29b-41d4-a716-446655440000',
};
