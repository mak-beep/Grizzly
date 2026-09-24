app_icon.png  - the Grizzly logo (monogram on white), used on the splash-free launcher icons.
                Platform launcher icons (android/ios/macos/web/windows) were generated from it.

The GPS chip and the alarm button use standard Material icons (location pin and
active bell). They are defined once in lib/core/constants/app_constants.dart
(DeviceType.icon), so changing them there changes every screen.
