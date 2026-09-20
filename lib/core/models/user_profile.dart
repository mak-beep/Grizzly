/// How alert notifications ring on this user's phone (a per-user setting).
enum AlertStyle { soundAndVibration, vibrationOnly }

/// Everything here is scoped to a single logged-in user and never bleeds
/// into device configuration or other users' accounts — the "per-user
/// settings independent of device settings" requirement.
class UserProfile {
  String firstName;
  String lastName;
  int age;
  String languageCode; // one of AppConstants.supportedLanguageCodes
  bool isDarkTheme;
  bool hasAcceptedPrivacyConsent;
  bool hasCompletedOnboarding;
  AlertStyle alertStyle;

  /// Android only: keep a foreground service running so alerts still arrive
  /// while the app is in the background.
  bool backgroundMonitoring;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.languageCode = 'en',
    this.isDarkTheme = false,
    this.hasAcceptedPrivacyConsent = false,
    this.hasCompletedOnboarding = false,
    this.alertStyle = AlertStyle.soundAndVibration,
    this.backgroundMonitoring = true,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'languageCode': languageCode,
        'isDarkTheme': isDarkTheme,
        'hasAcceptedPrivacyConsent': hasAcceptedPrivacyConsent,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'alertStyle': alertStyle.name,
        'backgroundMonitoring': backgroundMonitoring,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        languageCode: json['languageCode'] as String? ?? 'en',
        isDarkTheme: json['isDarkTheme'] as bool? ?? false,
        hasAcceptedPrivacyConsent: json['hasAcceptedPrivacyConsent'] as bool? ?? false,
        hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
        alertStyle: AlertStyle.values.where((s) => s.name == json['alertStyle']).firstOrNull ??
            AlertStyle.soundAndVibration,
        backgroundMonitoring: json['backgroundMonitoring'] as bool? ?? true,
      );

  String get displayName => '$firstName $lastName'.trim();

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    int? age,
    String? languageCode,
    bool? isDarkTheme,
    bool? hasAcceptedPrivacyConsent,
    bool? hasCompletedOnboarding,
    AlertStyle? alertStyle,
    bool? backgroundMonitoring,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      languageCode: languageCode ?? this.languageCode,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      hasAcceptedPrivacyConsent: hasAcceptedPrivacyConsent ?? this.hasAcceptedPrivacyConsent,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      alertStyle: alertStyle ?? this.alertStyle,
      backgroundMonitoring: backgroundMonitoring ?? this.backgroundMonitoring,
    );
  }
}
