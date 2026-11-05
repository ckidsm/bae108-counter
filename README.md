[English](README.md) | [한국어](README.ko.md)

# 108 Bows Counter

An Android and iOS app that counts a 108-bow practice by tap or at a fixed interval, then keeps a record of each completed practice. (`pubspec.yaml`, `lib/main.dart`)

## Overview

The app helps a person doing the 108-bow practice keep count without looking away. After Start is pressed, one bow is counted automatically at a chosen interval from 5 seconds to 3 minutes, and a bell, a vibration, or nothing marks each bow. (`lib/controllers/counter_controller.dart`, `lib/services/device_bow_feedback_service.dart`)

When the 108th bow is reached the counter stops, the screen is allowed to turn off again, and a completion screen shows the duration, the average time per bow, and the current streak. The practice can be saved with a one-line memo. (`lib/screens/completion_screen.dart`)

Saved records stay on the device in `shared_preferences`. They can optionally be added as events to a calendar on the device, including Google accounts that are signed in on the device. (`lib/services/practice_record_repository.dart`, `lib/services/device_calendar_sync_service.dart`)

The app has no server component and no user account of its own. It was verified with static analysis and automated tests in a Linux container and rendered as a web build for screenshots; it has not been run on a physical Android or iOS device yet. (`test/`)

## Key Features

- **Interval counting** – 5, 10, or 20-second presets, or a custom value from 5 seconds to 3 minutes in 5-second steps, set on the Settings screen. (`lib/screens/settings_screen.dart`, `lib/widgets/interval_slider.dart`, `lib/controllers/counter_rules.dart`)
- **One-screen main view** – the main screen shows the current interval and alert in one tappable line that opens Settings, and fits without scrolling; the counter ring sizes itself to the remaining height. (`lib/widgets/settings_summary_bar.dart`, `lib/screens/main_screen.dart`, `lib/widgets/counter_ring.dart`)
- **Start | Stop | Restart** – Start begins counting, Stop pauses while keeping the count, and Restart clears it after a confirmation. (`lib/widgets/counter_controls.dart`, `lib/screens/main_screen.dart`)
- **10-second preparation countdown** – starting from 0 runs a 10 → 1 countdown before counting; starting again after Stop continues without it. (`lib/controllers/counter_controller.dart`)
- **Per-bow feedback** – bell, vibration, or silent; the 108th bow is longer. Four bell sounds can be chosen in Settings: deep bell (default), clear bell, wind chime, and moktak. If a sound file is missing, the system click sound is used. (`lib/services/device_bow_feedback_service.dart`, `assets/sounds/`)
- **Screen kept on** until the practice is completed or reset. (`lib/services/wake_lock_service.dart`)
- **Progress display** – an orange outer ring that turns fully green with a green border when completed, a thin inner ring for the time to the next bow, and four 27-bow segment bars. (`lib/widgets/counter_ring.dart`, `lib/widgets/segment_progress_bars.dart`)
- **Practice history** – current and longest streak, Monday-to-Sunday check marks, this month's session count and total bows, and a list of recent practices. (`lib/screens/history_screen.dart`, `lib/services/practice_statistics_calculator.dart`)
- **Settings** – count interval, bell sound, background color (7 presets, including the white, dark gray, and light gray of palette #574), and button color (gold, blue #1976D2, deep blue #1565C0, gray #424242). (`lib/screens/settings_screen.dart`, `lib/theme/app_colors.dart`)
- **Calendar recording** – when enabled, saving a record also adds an event with the start/end time, duration, and memo to the chosen device calendar. (`lib/screens/completion_screen.dart`, `lib/services/device_calendar_sync_service.dart`)
- **App icon and emblem** – a bowing figure with "108" on gold as the app icon, and a round ascetic Buddha emblem next to the main title that follows the selected colors. To change the icon, replace `assets/icon/app_icon.png` and run `dart run flutter_launcher_icons`. (`assets/icon/`, `flutter_launcher_icons.yaml`, `lib/widgets/ascetic_emblem.dart`)
- **Four languages** – Korean, English, Japanese, and Chinese; other device languages fall back to English. (`lib/l10n/`)

## Concepts / Domain Model

### Counter phase

A practice moves through `idle`, `preparing`, `running`, `paused`, and `completed`. Time advances only through `CounterController.tick()`, which the app calls from a 100 ms timer and tests call directly. (`lib/models/counter_phase.dart`, `lib/controllers/counter_controller.dart`)

### Bow session

One completed practice: start and end time, active duration excluding pauses and the preparation countdown, bow count, and memo. Stored as JSON. (`lib/models/bow_session.dart`)

### Counter settings and app settings

Counter settings hold the counting mode, interval, and alert mode. App settings hold the background color, button color, and calendar recording choice. Both are restored on the next launch. (`lib/models/counter_settings.dart`, `lib/models/app_settings.dart`)

### Calendar target

The device calendar (name and account) that receives practice events. (`lib/models/calendar_target.dart`)

## Architecture

The app is a single Flutter client. `main.dart` opens `shared_preferences`, creates the record repository, the app settings controller, and the device services, and passes them to `Bae108App`, which builds the theme from the selected colors and shows the main screen. (`lib/main.dart`, `lib/app.dart`)

Screens only display state and forward user input. Counting rules live in `CounterController`, a `ChangeNotifier`, and theme and calendar choices live in `AppSettingsController`. Device access goes through small interfaces (`BowFeedbackService`, `WakeLockService`, `CalendarSyncService`) so tests can replace them with fakes. Records and settings are read and written only by `PracticeRecordRepository`. (`lib/screens/`, `lib/controllers/`, `lib/services/`)

When the user saves a completed practice, the completion screen writes the record through the repository and, if calendar recording is on, asks the calendar service to add an event. A calendar failure does not undo the saved record. (`lib/screens/completion_screen.dart`)

The app has no authentication or authorization flow; calendar access is granted through the operating system permission prompt. (`lib/services/device_calendar_sync_service.dart`)

## Source Structure

```text
.
├── lib/
│   ├── main.dart              # Entry point: opens storage and creates services
│   ├── app.dart               # MaterialApp, theme, localization
│   ├── controllers/           # CounterController, AppSettingsController, counter rules
│   ├── models/                # Session, settings, enums
│   ├── services/              # Storage, statistics, sound/vibration, wake lock, calendar
│   ├── screens/               # Main, completion, history, settings
│   ├── widgets/               # Counter ring, selectors, swatches, formatters
│   ├── theme/                 # Color palettes and Material 3 theme
│   └── l10n/                  # .arb translations and generated localization code
├── assets/sounds/            # Bell sounds (deep, clear, chime, moktak)
├── assets/icon/               # App icon sources for flutter_launcher_icons
├── flutter_launcher_icons.yaml # App icon generation settings
├── test/
│   ├── unit/                  # Controllers, models, services
│   ├── widget/                # Screen-level functional tests
│   ├── process/               # End-to-end practice flows
│   └── support/               # Fakes and the test app harness
├── android/                   # Android project (permissions, R8 rules)
├── ios/                       # iOS project (Info.plist usage descriptions)
├── l10n.yaml                  # Localization generator settings
└── pubspec.yaml               # Dependencies and assets
```

The app starts in `lib/main.dart`. (`lib/main.dart`)

## How It Works

1. The main screen loads the saved counter settings and creates a `CounterController`. (`lib/screens/main_screen.dart`)
2. Pressing Start enables the wake lock and starts a 100 ms timer that measures real elapsed time and calls `tick()`. (`lib/controllers/counter_controller.dart`)
3. Starting from 0, `tick()` first runs the 10-second preparation countdown, then starts each bow with its sound: bow 1 sounds the moment the countdown ends, and each following bow sounds one interval later, so the user bows when the sound plays. (`lib/controllers/counter_controller.dart`)
4. One interval after bow 108 starts, a long sound marks completion and the controller stops the timer, records the end time, and releases the wake lock. After 1.5 seconds the main screen opens the completion screen. (`lib/controllers/counter_controller.dart`, `lib/screens/main_screen.dart`)
5. Saving stores the session as JSON in `shared_preferences` and, if enabled, adds a calendar event. The main screen then resets the counter. (`lib/screens/completion_screen.dart`, `lib/services/practice_record_repository.dart`)
6. The history screen reads all sessions and computes streaks, the weekly check row, and monthly totals. (`lib/screens/history_screen.dart`, `lib/services/practice_statistics_calculator.dart`)

## Setup & Run

### Requirements

- Flutter 3.44.0 or later with Dart SDK `^3.13.0` (developed with Flutter 3.47.9). (`pubspec.yaml`, `pubspec.lock`)
- Android: Android SDK; `minSdk` follows the Flutter default. (`android/app/build.gradle.kts`)
- iOS: macOS with Xcode and CocoaPods; deployment target iOS 15.0. (`ios/Runner.xcodeproj/project.pbxproj`)

### Install and run

```bash
git clone https://github.com/ckidsm/bae108-counter.git
```

```bash
cd bae108-counter
```

```bash
flutter pub get
```

```bash
flutter run
```

On iOS, open `ios/Runner.xcworkspace` in Xcode once and choose a development team under Signing & Capabilities before running on a device.

### Release builds

```bash
flutter build apk --release
```

```bash
flutter build ios --release
```

The Android release build is currently signed with the debug key; configure your own signing in `android/app/build.gradle.kts` before publishing. (`android/app/build.gradle.kts`)

### Checks

```bash
dart format --output=none --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

Tests are grouped as `test/unit`, `test/widget`, and `test/process` and can be run per folder, for example `flutter test test/process`. (`test/`)

### Environment variables

None. The app reads no environment variables. (`lib/`)

## Server Requirements / Spec

Not applicable. The app runs entirely on the device and has no server. (`lib/`)

- Ports: Not applicable
- Minimum CPU / memory: Not specified
- Storage: Not specified; records are small JSON strings in `shared_preferences`. (`lib/services/practice_record_repository.dart`)

## Operations

- Logging: diagnostic messages use `debugPrint` for storage, feedback, wake lock, and calendar failures. (`lib/services/`, `lib/controllers/counter_controller.dart`)
- Data: records are stored under the `bow_sessions_v1` key; settings under `counter_settings_v1` and `app_settings_v1`. Corrupted stored JSON is logged and treated as empty. (`lib/services/practice_record_repository.dart`)
- Backup / migration / deployment: Not specified.

## Security Notes

- Authentication: none; the app has no account system. (`lib/`)
- Permissions: Android `VIBRATE`, `READ_CALENDAR`, `WRITE_CALENDAR`; iOS calendar usage descriptions. `NSContactsUsageDescription` is present because the calendar plugin requires it; the app does not read contacts. (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`)
- Data: practice records and memos stay on the device unless calendar recording is turned on, in which case they are written to the chosen calendar and synced by that calendar's account. (`lib/services/device_calendar_sync_service.dart`)

## Troubleshooting

### No calendars are listed when turning on calendar recording

- Symptom: "No writable calendars found" appears.
- Check: the Google account must be added to the device and calendar sync must be on for it in the system settings.
- Resolution: add the account, wait for calendar sync, and turn the switch on again. (`lib/screens/settings_screen.dart`)

### Calendar access was denied

- Symptom: the permission message appears and the switch stays off.
- Resolution: allow calendar access for the app in the device settings, then turn the switch on again. (`lib/services/device_calendar_sync_service.dart`)

### Calendar list is empty only in Android release builds

- Check: the R8 keep rule for `com.builttoroam.devicecalendar` must remain in `android/app/proguard-rules.pro`. (`android/app/proguard-rules.pro`, `android/app/build.gradle.kts`)

### No bell sound

- Check: the device is not in silent mode, and `assets/sounds/bell.mp3` exists and is listed under `assets/sounds/` in `pubspec.yaml`. If the file is missing, the system click sound is used instead. (`lib/services/device_bow_feedback_service.dart`)

## License / Disclaimer

License information is not specified.
