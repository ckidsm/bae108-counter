// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '108 Bows Counter';

  @override
  String get mainTitle => 'Today\'s 108 Bows';

  @override
  String get keepScreenOnNotice => 'Screen stays on until 108 bows';

  @override
  String get historyTooltip => 'Practice history';

  @override
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum – $maximum, in steps of $step';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String counterTarget(int target) {
    return '/ $target';
  }

  @override
  String get preparationLabel => 'Get ready';

  @override
  String segmentRange(int start, int end) {
    return '$start–$end';
  }

  @override
  String guidePreparing(int seconds) {
    return 'Get into position · starting in ${seconds}s';
  }

  @override
  String get guidePaused => 'Stopped · press Start to continue';

  @override
  String get guideCompleted => 'All 108 bows completed';

  @override
  String get alertModeTitle => 'Alert';

  @override
  String get alertModeBell => 'Bell';

  @override
  String get alertModeVibration => 'Vibrate';

  @override
  String get alertModeSilent => 'Silent';

  @override
  String get buttonStart => 'Start';

  @override
  String get buttonDedication => 'Dedicate';

  @override
  String get buttonReset => 'Restart';

  @override
  String get resetConfirmTitle => 'Start over?';

  @override
  String resetConfirmMessage(int count) {
    return 'The $count bows counted so far will be cleared.';
  }

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'OK';

  @override
  String get completionTitle => '108 Bows Dedicated';

  @override
  String get completionSubtitle => 'Dedicating today\'s practice to all beings';

  @override
  String get completionDuration => 'Duration';

  @override
  String get completionAverage => 'Per bow';

  @override
  String get completionStreak => 'Streak';

  @override
  String averageSecondsValue(String seconds) {
    return '${seconds}s';
  }

  @override
  String streakDaysValue(int days) {
    return '$days d';
  }

  @override
  String timeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get memoHint => 'A one-line note for today';

  @override
  String get saveRecord => 'Save record';

  @override
  String get restartPractice => 'Practice again';

  @override
  String get discardConfirmTitle => 'Discard this record?';

  @override
  String get discardConfirmMessage =>
      'If you start again without saving, this practice will not be recorded.';

  @override
  String get discardConfirmAction => 'Don\'t save';

  @override
  String get recordSaved => 'Record saved';

  @override
  String get recordSaveFailed => 'Could not save the record. Please try again';

  @override
  String get historyTitle => 'Practice history';

  @override
  String get streakTitle => 'Streak';

  @override
  String get currentStreakLabel => 'Current';

  @override
  String get longestStreakLabel => 'Longest';

  @override
  String get thisWeekTitle => 'This week';

  @override
  String get thisMonthTitle => 'This month';

  @override
  String get monthlySessionLabel => 'Sessions';

  @override
  String monthlySessionValue(int count) {
    return '$count';
  }

  @override
  String get monthlyBowLabel => 'Total bows';

  @override
  String monthlyBowValue(int count) {
    return '$count';
  }

  @override
  String get recentSessionsTitle => 'Recent practice';

  @override
  String get emptyHistory => 'No saved records yet';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsIntervalSection => 'Count interval';

  @override
  String get settingsIntervalDescription =>
      'One bow is counted at this interval after you press Start';

  @override
  String get settingsThemeSection => 'Color theme';

  @override
  String get themeBlack => 'Black';

  @override
  String get themeCharcoal => 'Charcoal';

  @override
  String get themeWarmBrown => 'Warm brown';

  @override
  String get themeNavy => 'Navy';

  @override
  String get settingsCalendarSection => 'Calendar';

  @override
  String get calendarSyncTitle => 'Add records to calendar';

  @override
  String get calendarSyncDescription =>
      'Saved records are added as events to the chosen calendar, such as Google Calendar';

  @override
  String get calendarTargetLabel => 'Calendar';

  @override
  String get calendarNotSelected => 'Not selected';

  @override
  String get calendarPickerTitle => 'Choose a calendar';

  @override
  String get calendarEmpty =>
      'No writable calendars found. Check that a Google account is added on this device';

  @override
  String get calendarPermissionDenied =>
      'Calendar access was denied. Allow calendar access in the device settings';

  @override
  String get calendarLoadFailed => 'Could not load calendars';

  @override
  String get calendarEventTitle => '108 bows practice';

  @override
  String calendarEventDescription(int count, String duration) {
    return '$count bows · $duration';
  }

  @override
  String get recordSavedToCalendar => 'Record saved and added to your calendar';

  @override
  String get recordSavedCalendarFailed =>
      'Record saved, but it could not be added to your calendar';

  @override
  String get themeBackgroundLabel => 'Background';

  @override
  String get themeAccentLabel => 'Button color';

  @override
  String get themeDarkGray => 'Dark gray';

  @override
  String get themeWhite => 'White';

  @override
  String get themeLightGray => 'Light gray';

  @override
  String get accentGold => 'Gold';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentDeepBlue => 'Deep blue';

  @override
  String get accentGray => 'Gray';

  @override
  String guideRunning(int seconds) {
    return 'Next bow in ${seconds}s';
  }

  @override
  String get buttonStop => 'Stop';

  @override
  String guideIdle(int seconds, String interval) {
    return 'After a $seconds-second countdown, one bow is counted every $interval';
  }

  @override
  String get settingsSoundSection => 'Bell sound';

  @override
  String get settingsSoundDescription =>
      'Played when the alert is set to bell. Tap to hear it';

  @override
  String get soundDeep => 'Deep bell';

  @override
  String get soundClear => 'Clear bell';

  @override
  String get soundChime => 'Wind chime';

  @override
  String get soundMoktak => 'Moktak';

  @override
  String get soundTempleBell => 'Temple bell';

  @override
  String get summaryIntervalLabel => 'Interval';

  @override
  String get summaryAlertLabel => 'Alert';

  @override
  String summaryBellValue(String mode, String sound) {
    return '$mode · $sound';
  }
}
