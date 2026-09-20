import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/alert_event.dart';

class HistoryLogList extends StatefulWidget {
  final List<AlertEvent> events;

  const HistoryLogList({super.key, required this.events});

  @override
  State<HistoryLogList> createState() => _HistoryLogListState();
}

class _HistoryLogListState extends State<HistoryLogList> {
  static const _pageSize = 30;
  int _visible = _pageSize;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final events = widget.events;

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(t.noActivityYet, style: const TextStyle(color: Colors.grey))),
      );
    }

    final formatter = DateFormat('MMM d, HH:mm', Localizations.localeOf(context).languageCode);
    final shown = events.take(_visible).toList();

    return Column(
      children: [
        for (final event in shown)
          ListTile(
            leading: Icon(_iconFor(event.type), color: _colorFor(event.type, context)),
            title: Text(_labelFor(event.type, t)),
            subtitle: Text([
              formatter.format(event.timestamp.toLocal()),
              if (event.hasLocation)
                '${event.lat!.toStringAsFixed(5)}, ${event.lng!.toStringAsFixed(5)}',
            ].join(' · ')),
            dense: true,
          ),
        if (events.length > _visible)
          TextButton(
            onPressed: () => setState(() => _visible += _pageSize),
            child: Text(t.showMoreButton),
          ),
      ],
    );
  }

  String _labelFor(AlertEventType type, AppLocalizations t) => switch (type) {
        AlertEventType.geofenceBreach => t.eventGeofenceBreach,
        AlertEventType.geofenceReturn => t.eventGeofenceReturn,
        AlertEventType.alarmTriggered => t.eventAlarmTriggered,
        AlertEventType.alarmCancelled => t.eventAlarmCancelled,
        AlertEventType.locationPing => t.eventLocationPing,
      };

  IconData _iconFor(AlertEventType type) => switch (type) {
        AlertEventType.geofenceBreach => Icons.warning_amber_rounded,
        AlertEventType.geofenceReturn => Icons.home_outlined,
        AlertEventType.alarmTriggered => Icons.emergency,
        AlertEventType.alarmCancelled => Icons.check_circle_outline,
        AlertEventType.locationPing => Icons.location_on_outlined,
      };

  Color _colorFor(AlertEventType type, BuildContext context) => switch (type) {
        AlertEventType.geofenceBreach || AlertEventType.alarmTriggered =>
          Theme.of(context).colorScheme.error,
        AlertEventType.alarmCancelled || AlertEventType.geofenceReturn => Colors.green,
        AlertEventType.locationPing => Colors.grey,
      };
}
