import '../localization/app_localizations.dart';

/// Coarse "how long ago" text (just now / minutes / hours / days).
String relativeTime(DateTime time, AppLocalizations t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return t.justNowShort;
  if (diff.inMinutes < 60) return t.minutesAgoShort(diff.inMinutes);
  if (diff.inHours < 24) return t.hoursAgoShort(diff.inHours);
  return t.daysAgoShort(diff.inDays);
}
