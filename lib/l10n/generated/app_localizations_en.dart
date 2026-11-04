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
  String get countModeTitle => 'Counting mode';

  @override
  String get countModeTap => 'Tap';

  @override
  String get countModeAuto => 'Auto interval';

  @override
  String get intervalTitle => 'Bow interval';

  @override
  String get intervalCustom => 'Custom';

  @override
  String intervalCustomSelected(String duration) {
    return 'Custom · $duration';
  }

  @override
  String get customIntervalSheetTitle => 'Custom bow interval';

  @override
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum – $maximum, in steps of $step';
  }

  @override
  String get customIntervalApply => 'Apply';

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
  String get guideIdleTap => 'Tap the circle or press Start';

  @override
  String guideIdleAuto(int seconds) {
    return 'Counting begins after a $seconds-second countdown';
  }

  @override
  String guidePreparing(int seconds) {
    return 'Get into position · starting in ${seconds}s';
  }

  @override
  String get guideRunningTap => 'Each tap on the circle counts one bow';

  @override
  String guideRunningAuto(int seconds) {
    return 'Next bow in ${seconds}s';
  }

  @override
  String get guidePaused => 'Paused · press Resume';

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
  String get buttonResume => 'Resume';

  @override
  String get buttonPause => 'Pause';

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
}
