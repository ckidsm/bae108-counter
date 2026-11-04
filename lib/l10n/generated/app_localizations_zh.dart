// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '108拜计数器';

  @override
  String get mainTitle => '今日108拜';

  @override
  String get keepScreenOnNotice => '108拜完成前屏幕保持常亮';

  @override
  String get historyTooltip => '修行记录';

  @override
  String get countModeTitle => '计数方式';

  @override
  String get countModeTap => '点击';

  @override
  String get countModeAuto => '自动间隔';

  @override
  String get intervalTitle => '礼拜间隔';

  @override
  String get intervalCustom => '自定义';

  @override
  String intervalCustomSelected(String duration) {
    return '自定义 · $duration';
  }

  @override
  String get customIntervalSheetTitle => '自定义礼拜间隔';

  @override
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum ~ $maximum，以$step为单位';
  }

  @override
  String get customIntervalApply => '应用';

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
    return '$hours小时$minutes分';
  }

  @override
  String counterTarget(int target) {
    return '/ $target';
  }

  @override
  String get preparationLabel => '准备';

  @override
  String segmentRange(int start, int end) {
    return '$start–$end';
  }

  @override
  String get guideIdleTap => '点击圆圈或按开始';

  @override
  String guideIdleAuto(int seconds) {
    return '开始后准备$seconds秒，然后开始计数';
  }

  @override
  String guidePreparing(int seconds) {
    return '请调整姿势 · $seconds秒后开始';
  }

  @override
  String get guideRunningTap => '每点击一次圆圈计一拜';

  @override
  String guideRunningAuto(int seconds) {
    return '距下一拜还有$seconds秒';
  }

  @override
  String get guidePaused => '已暂停 · 请按继续';

  @override
  String get guideCompleted => '已完成全部108拜';

  @override
  String get alertModeTitle => '提醒方式';

  @override
  String get alertModeBell => '钟声';

  @override
  String get alertModeVibration => '振动';

  @override
  String get alertModeSilent => '静音';

  @override
  String get buttonStart => '开始';

  @override
  String get buttonResume => '继续';

  @override
  String get buttonPause => '暂停';

  @override
  String get buttonDedication => '回向';

  @override
  String get buttonReset => '重新开始';

  @override
  String get resetConfirmTitle => '要重新开始吗？';

  @override
  String resetConfirmMessage(int count) {
    return '已计的$count拜将被清除。';
  }

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogConfirm => '确定';

  @override
  String get completionTitle => '108拜 回向';

  @override
  String get completionSubtitle => '将今日的精进回向一切众生';

  @override
  String get completionDuration => '用时';

  @override
  String get completionAverage => '每拜平均';

  @override
  String get completionStreak => '连续天数';

  @override
  String averageSecondsValue(String seconds) {
    return '$seconds秒';
  }

  @override
  String streakDaysValue(int days) {
    return '$days天';
  }

  @override
  String timeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get memoHint => '今日一句话备注';

  @override
  String get saveRecord => '保存记录';

  @override
  String get restartPractice => '再来一次';

  @override
  String get discardConfirmTitle => '不保存记录吗？';

  @override
  String get discardConfirmMessage => '不保存就重新开始，本次修行将不会被记录。';

  @override
  String get discardConfirmAction => '不保存';

  @override
  String get recordSaved => '记录已保存';

  @override
  String get recordSaveFailed => '无法保存记录，请重试';

  @override
  String get historyTitle => '修行记录';

  @override
  String get streakTitle => '连续修行';

  @override
  String get currentStreakLabel => '当前';

  @override
  String get longestStreakLabel => '最长';

  @override
  String get thisWeekTitle => '本周';

  @override
  String get thisMonthTitle => '本月';

  @override
  String get monthlySessionLabel => '修行次数';

  @override
  String monthlySessionValue(int count) {
    return '$count次';
  }

  @override
  String get monthlyBowLabel => '累计拜数';

  @override
  String monthlyBowValue(int count) {
    return '$count拜';
  }

  @override
  String get recentSessionsTitle => '最近修行';

  @override
  String get emptyHistory => '还没有保存的记录';

  @override
  String get settingsTooltip => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsIntervalSection => '计数间隔';

  @override
  String get settingsIntervalDescription => '自动间隔模式下每计一拜的间隔';

  @override
  String get settingsThemeSection => '颜色主题';

  @override
  String get themeBlack => '黑色';

  @override
  String get themeCharcoal => '炭灰';

  @override
  String get themeWarmBrown => '暖棕';

  @override
  String get themeNavy => '藏青';

  @override
  String get settingsCalendarSection => '日历记录';

  @override
  String get calendarSyncTitle => '将修行记录添加到日历';

  @override
  String get calendarSyncDescription => '保存记录时，将其作为日程添加到所选日历（如 Google 日历）';

  @override
  String get calendarTargetLabel => '记录到的日历';

  @override
  String get calendarNotSelected => '未选择';

  @override
  String get calendarPickerTitle => '选择日历';

  @override
  String get calendarEmpty => '没有可写入的日历。请确认设备上已添加 Google 账号';

  @override
  String get calendarPermissionDenied => '未获得日历权限。请在设备设置中允许访问日历';

  @override
  String get calendarLoadFailed => '无法加载日历';

  @override
  String get calendarEventTitle => '108拜 修行';

  @override
  String calendarEventDescription(int count, String duration) {
    return '$count拜 · 用时 $duration';
  }

  @override
  String get recordSavedToCalendar => '记录已保存并添加到日历';

  @override
  String get recordSavedCalendarFailed => '记录已保存，但未能添加到日历';

  @override
  String get themeBackgroundLabel => '背景色';

  @override
  String get themeAccentLabel => '按钮颜色';

  @override
  String get themeDarkGray => '深灰';

  @override
  String get themeWhite => '白色';

  @override
  String get themeLightGray => '浅灰';

  @override
  String get accentGold => '金色';

  @override
  String get accentBlue => '蓝色';

  @override
  String get accentDeepBlue => '深蓝';

  @override
  String get accentGray => '灰色';
}
