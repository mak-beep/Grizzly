Drop the final branded icons here:
  - gps_chip.png      (referenced by DeviceType.gpsTracker.iconAsset)
  - alarm_button.png  (referenced by DeviceType.alarmButton.iconAsset)

Until real artwork is supplied, the app renders Material icons
(Icons.gps_fixed / Icons.emergency_outlined) in matching brand colors
(see lib/core/theme/app_theme.dart), so nothing is blocked by this.
