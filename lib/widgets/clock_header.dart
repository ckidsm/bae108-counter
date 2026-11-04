import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the current date and 24-hour time, updated every second.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 날짜와 24시간 시계를 1초마다 갱신해 보여 준다.
class ClockHeader extends StatefulWidget {
  /// Creates the live clock.
  const ClockHeader({super.key});

  @override
  State<ClockHeader> createState() => _ClockHeaderState();
}

// 시계 위젯의 상태(타이머 보관)
class _ClockHeaderState extends State<ClockHeader> {
  // 시계 갱신 주기
  static const Duration _refreshInterval = Duration(seconds: 1);

  // 1초마다 다시 그리게 하는 타이머
  Timer? _refreshTimer;
  // 화면에 표시할 현재 시각
  DateTime _now = DateTime.now();

  @override
  void initState() {
    // 부모 초기화를 먼저 한다.
    super.initState();
    // 1초마다 현재 시각을 갱신한다.
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      // 새 시각으로 다시 그린다.
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    // 화면이 사라지면 타이머를 멈춘다.
    _refreshTimer?.cancel();
    // 부모 정리를 이어서 한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 언어 문구로 형식 도우미를 만든다.
    final formatter = DisplayFormatter(AppLocalizations.of(context));
    // 보조 글자색으로 시계를 표시한다.
    return Text(
      // 2026.11.04 (수) 14:32:05 형식
      formatter.formatClock(_now),
      // 작은 글자, 보조 색, 숫자 폭 고정(초가 바뀌어도 흔들리지 않게)
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        // 보조 글자색
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        // 숫자 폭을 일정하게
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}
