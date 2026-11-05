// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '108拝カウンター';

  @override
  String get mainTitle => '今日の108拝';

  @override
  String get keepScreenOnNotice => '108拝まで画面をオンに保持';

  @override
  String get historyTooltip => '修行記録';

  @override
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum〜$maximum、$step単位';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String counterTarget(int target) {
    return '/ $target';
  }

  @override
  String get preparationLabel => '準備';

  @override
  String segmentRange(int start, int end) {
    return '$start–$end';
  }

  @override
  String guidePreparing(int seconds) {
    return '姿勢を整えてください · $seconds秒後に開始';
  }

  @override
  String get guidePaused => '停止中 · スタートで続きから数えます';

  @override
  String get guideCompleted => '108拝をすべて終えました';

  @override
  String get alertModeTitle => '通知方法';

  @override
  String get alertModeBell => '鐘の音';

  @override
  String get alertModeVibration => 'バイブ';

  @override
  String get alertModeSilent => '無音';

  @override
  String get buttonStart => 'スタート';

  @override
  String get buttonDedication => '回向する';

  @override
  String get buttonReset => '最初から';

  @override
  String get resetConfirmTitle => '最初からやり直しますか？';

  @override
  String resetConfirmMessage(int count) {
    return 'これまでに数えた$count拝が消えます。';
  }

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get dialogConfirm => 'OK';

  @override
  String get completionTitle => '108拝 回向';

  @override
  String get completionSubtitle => '今日の精進を一切に回向します';

  @override
  String get completionDuration => '所要時間';

  @override
  String get completionAverage => '1拝平均';

  @override
  String get completionStreak => '連続日数';

  @override
  String averageSecondsValue(String seconds) {
    return '$seconds秒';
  }

  @override
  String streakDaysValue(int days) {
    return '$days日';
  }

  @override
  String timeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get memoHint => '今日のひとことメモ';

  @override
  String get saveRecord => '記録を保存';

  @override
  String get restartPractice => 'もう一度';

  @override
  String get discardConfirmTitle => '記録を保存しませんか？';

  @override
  String get discardConfirmMessage => '保存せずに再開すると、今回の修行は記録に残りません。';

  @override
  String get discardConfirmAction => '保存しない';

  @override
  String get recordSaved => '記録を保存しました';

  @override
  String get recordSaveFailed => '記録を保存できませんでした。もう一度お試しください';

  @override
  String get historyTitle => '修行記録';

  @override
  String get streakTitle => '連続修行';

  @override
  String get currentStreakLabel => '現在';

  @override
  String get longestStreakLabel => '最長';

  @override
  String get thisWeekTitle => '今週';

  @override
  String get thisMonthTitle => '今月';

  @override
  String get monthlySessionLabel => '修行回数';

  @override
  String monthlySessionValue(int count) {
    return '$count回';
  }

  @override
  String get monthlyBowLabel => '累計拝数';

  @override
  String monthlyBowValue(int count) {
    return '$count拝';
  }

  @override
  String get recentSessionsTitle => '最近の修行';

  @override
  String get emptyHistory => '保存された記録はまだありません';

  @override
  String get settingsTooltip => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsIntervalSection => 'カウント間隔';

  @override
  String get settingsIntervalDescription => 'スタート後、この間隔ごとに1拝ずつ数えます';

  @override
  String get settingsThemeSection => 'カラーテーマ';

  @override
  String get themeBlack => 'ブラック';

  @override
  String get themeCharcoal => 'チャコール';

  @override
  String get themeWarmBrown => 'ウォームブラウン';

  @override
  String get themeNavy => 'ネイビー';

  @override
  String get settingsCalendarSection => 'カレンダー記録';

  @override
  String get calendarSyncTitle => '修行記録をカレンダーに追加';

  @override
  String get calendarSyncDescription =>
      '記録を保存すると、選択したカレンダー（Googleカレンダーなど）に予定として追加します';

  @override
  String get calendarTargetLabel => '記録するカレンダー';

  @override
  String get calendarNotSelected => '未選択';

  @override
  String get calendarPickerTitle => 'カレンダーを選択';

  @override
  String get calendarEmpty =>
      '書き込めるカレンダーがありません。端末にGoogleアカウントが追加されているか確認してください';

  @override
  String get calendarPermissionDenied => 'カレンダーへのアクセスが許可されていません。端末の設定で許可してください';

  @override
  String get calendarLoadFailed => 'カレンダーを読み込めませんでした';

  @override
  String get calendarEventTitle => '108拝 修行';

  @override
  String calendarEventDescription(int count, String duration) {
    return '$count拝 · 所要時間 $duration';
  }

  @override
  String get recordSavedToCalendar => '記録を保存し、カレンダーに追加しました';

  @override
  String get recordSavedCalendarFailed => '記録は保存しましたが、カレンダーに追加できませんでした';

  @override
  String get themeBackgroundLabel => '背景色';

  @override
  String get themeAccentLabel => 'ボタンの色';

  @override
  String get themeDarkGray => 'ダークグレー';

  @override
  String get themeWhite => 'ホワイト';

  @override
  String get themeLightGray => 'ライトグレー';

  @override
  String get accentGold => 'ゴールド';

  @override
  String get accentBlue => 'ブルー';

  @override
  String get accentDeepBlue => 'ディープブルー';

  @override
  String get accentGray => 'グレー';

  @override
  String guideRunning(int seconds) {
    return '次の拝まで$seconds秒';
  }

  @override
  String get buttonStop => '停止';

  @override
  String guideIdle(int seconds, String interval) {
    return 'スタート後、$seconds秒の準備ののち$intervalごとに1拝ずつ数えます';
  }

  @override
  String get settingsSoundSection => '鐘の音';

  @override
  String get settingsSoundDescription => '通知方法が鐘の音のときに鳴る音です。タップすると試聴できます';

  @override
  String get soundDeep => '低音の鐘';

  @override
  String get soundClear => '澄んだ鐘';

  @override
  String get soundChime => '風鈴';

  @override
  String get soundMoktak => '木魚';

  @override
  String get soundTempleBell => '梵鐘';

  @override
  String get summaryIntervalLabel => '間隔';

  @override
  String get summaryAlertLabel => '通知';

  @override
  String summaryBellValue(String mode, String sound) {
    return '$mode · $sound';
  }

  @override
  String guideFinalBow(int seconds) {
    return '最後の拝 · $seconds秒後に完了';
  }

  @override
  String watchSessionsImported(int count) {
    return 'Apple Watchの修行記録を$count件保存しました';
  }
}
