# Grizzly — Flutter app

Companion app for the GPS Tracking Chip and the Alarm Button. Manages any
number of both device types from one account, with a separate login per family
member.

Each family stores everything in **their own free Firebase project**; the app
and the devices talk to that project directly. There is no shared server and
no server run by us.

## What changed in this version (0.2)

- **Devices and app now speak the same language.** Firmware writes Firestore
  server timestamps; the app previously read them as text and stopped syncing
  on the first real update. All incoming data is now converted and validated,
  and one malformed document can no longer hide the rest.
- **Real alerts.** A geofence breach, an alarm press or a cancellation from a
  real device now raises a phone notification with vibration, an in-app
  banner, and a history entry — previously only the "simulate" buttons did.
- **Emergency contacts are people, not just text.** A contact is identified by
  the email they sign in with; adding one invites them to the family
  automatically, and alerts for a device go to its contacts.
- **Maps without an API key.** A built-in OpenStreetMap view (tiles +
  attribution, no key, no billing) replaces Google Maps: live position, safe
  zone circle, recent route, and tap-to-place for the safe zone.
- **Safe zones actually have a location.** Address search (OpenStreetMap
  Nominatim), "use my current location", or tapping the map. The old version
  saved every zone at (0,0), which made trackers report a breach constantly.
- **Pairing that matches the hardware.** Devices register themselves on first
  connection and appear under *Detected devices*; the ID can also be copied
  from the Firebase console. (The old text told users to read it over USB,
  which the PCB doesn't have.)
- **Security rules that mean something.** Family membership with invites, and
  per-device permissions, replace "any signed-in user can read and write
  everything". See *Security model* below.

## Requirements → where they are implemented

| Requirement | Where |
|---|---|
| Individual login per contact | `AuthScreen`, `AuthNotifier`, router gates |
| Multiple devices, fully independent | `DeviceRepository`, keyed by device UUID |
| Distinct icon + custom name, shown in alerts | `DeviceCard`, `AlertMonitor` |
| Safe zone by address + radius, editable remotely | `GeofenceEditor` + `GeocodingService` |
| 3–5 emergency contacts per device | `ContactsEditor`, `AppConstants.min/maxEmergencyContacts` |
| Push notification + vibration on breach / alarm | `AlertMonitor` + `NotificationService` |
| Alarm: silent until pressed, 3-press cancel | `AlarmButtonDetailScreen` (firmware enforces it) |
| Location & alert history | `HistoryLogList`, `AlertEvent` |
| Device settings shared, personal settings private | `families/family/devices` vs per-user profile |
| Languages EN / FR / ES / IT | `AppLocalizations` |
| Privacy consent before any data collection | `PrivacyConsentScreen` |
| HTTPS/TLS, per-device auth, data validation | Firebase SDKs + `firestore.rules` |

## Running it

```
flutter pub get
flutter run
```

The delivery contains Dart sources only. Run `flutter create .` once in this
folder to generate the `android/` and `ios/` projects, then add the entries
below to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_REMOTE_MESSAGING"/>

<!-- inside <application> : background monitoring service -->
<service
    android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
    android:exported="false"
    android:stopWithTask="false"
    android:foregroundServiceType="remoteMessaging"/>
```

For iOS, `ios/Runner/Info.plist` needs `NSLocationWhenInUseUsageDescription`
(used only for the "use my current location" button in the safe zone editor).

## Trying it without hardware or Firebase

1. Run the app and sign up with any email/password.
2. On "Connect your backend", tap **Continue in demo mode**.
3. Add a GPS Tracker and/or an Alarm Button.
4. Use the **Test without hardware** card on each device screen to simulate a
   location update, a geofence breach or return, an alarm press and a 3-press
   cancellation. These drive the same code path as real device data, so the
   map, history, banner, notification and vibration all behave as in
   production. The panel is hidden once a real backend is linked, so nobody
   can fake an alert to real contacts.

## Setting up a family (production)

1. **Create a Firebase project** (free Spark plan) at console.firebase.google.com.
2. **Authentication → Sign-in method**: enable **Email/Password** *and*
   **Anonymous** (devices sign in anonymously).
3. **Firestore Database → Create database** (production mode).
4. **Project settings → General → Your apps**: register an Android app (and an
   iOS app if iPhones are used) to get the **App ID**; copy the **Project ID**,
   **Web API Key** and **Project number**.
5. Enter those four values in the app's "Connect your backend" step.
6. The app then shows `firestore.rules` — copy or share it into
   **Firestore Database → Rules** and press **Publish**.
7. Create the first account: whoever signs up first becomes the family owner.
   Everyone else must be invited (Settings → Family members, or simply by
   being added as an emergency contact) and then signs up with that email.
8. Put the same **Project ID** and **Web API Key** into each device's firmware
   (`include/credentials.h`), flash it, and insert the SIM.
9. When a device connects it appears under **Add device → Detected devices**.

## Security model (`firestore.rules`)

- All family data lives under `families/family`.
- **People** (email/password) must be listed in `families/family/members`.
  Knowing the project's API key is therefore not enough to read a family's
  data. The first user of a new project claims ownership; the others join via
  an invite created by a member.
- **Devices** (anonymous sign-in) may create their own document and write only
  their own status fields and history entries, and may read only their own
  document (to fetch the safe zone). They cannot read the family's other data.
- Coordinates, radii, event types and sizes are validated in the rules, and
  `lastSeen`/`timestamp` must equal the server time, so timestamps cannot be
  forged.
- If a device is re-flashed and loses its Firebase identity, a member uses
  **Re-pair device** to let it claim its entry again.

## How alerts reach a phone

There is no push server (a Firebase Cloud Function would require the paid
Blaze plan), so alerts are delivered by the app's live Firestore listener:

- **App open or in the background (Android)** — alerts arrive within seconds
  and produce a notification, vibration and an in-app banner. Settings →
  *Monitor in the background* keeps this alive with a small ongoing
  notification.
- **App fully closed (swiped away), or iOS in the background** — the phone is
  not listening, so alerts are shown the next time the app is opened
  (anything older than 15 minutes is added to the history without ringing).
- Each alert rings once per phone, even across restarts.

If alerts on a fully closed phone become a requirement, the step to add is a
Cloud Function on `families/family/devices/{id}/history/{eventId}` that sends
FCM messages to the device's contacts — this needs the Blaze plan.

## Project structure

```
lib/
  main.dart                         app entry, theme, locale, alert wiring
  core/
    constants/app_constants.dart    every agreed rule in one place
    localization/                   hand-written EN/FR/ES/IT strings
    models/                         Device, Geofence, EmergencyContact,
                                    AlertEvent, UserProfile
    services/
      auth_service.dart             sign in/up, per-family Firebase link
      device_repository.dart        devices, history, live sync, alerts
      family_service.dart           membership, invites
      alert_monitor.dart            decides who gets alerted, once
      notification_service.dart     notifications, vibration, background service
      geocoding_service.dart        OpenStreetMap address search
      firestore_codec.dart          Firestore values → plain Dart
      persistence_service.dart      on-device cache (works offline)
    utils/                          projection maths, parsing, relative time
    widgets/osm_map.dart            OpenStreetMap tile map
  features/
    auth/ onboarding/ dashboard/ device_detail/ settings/
test/                               contract, alert, map and smoke tests
```

## Tests

```
flutter test
```

Covers what the firmware actually writes (server timestamps, all event types,
unknown types, legacy cached data), who gets alerted and when, the map
projection and address parsing, and a first-launch smoke test.

## Known limits

- Background alerts: see *How alerts reach a phone* above.
- OpenStreetMap tiles are fetched from the public tile server. That is fine for
  family-scale use; a heavier deployment should use its own tile provider.
- Address search uses public Nominatim (one request per search, as their
  policy requires).
- Switching this phone to a *different* family's Firebase project requires
  restarting the app (Firebase allows one project per process).
