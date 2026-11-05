import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Draws the circular counter with the progress ring and inner interval ring.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 진행 링과 다음 절까지의 안쪽 링을 가진 원형 카운터.
class CounterRing extends StatelessWidget {
  /// Creates the circular counter.
  const CounterRing({
    super.key,
    required this.progress,
    required this.innerProgress,
    required this.isCompleted,
    required this.valueText,
    required this.captionText,
  });

  // 원의 최대 지름
  static const double _maximumDiameter = 320;
  // 화면 폭 대비 원 지름 비율
  static const double _widthRatio = 0.9;
  // 원 지름 대비 가운데 큰 숫자 글자 크기 비율
  static const double _valueFontRatio = 0.3;

  /// The overall progress from 0.0 to 1.0.
  final double progress;

  /// The inner ring progress from 0.0 to 1.0.
  final double innerProgress;

  /// Whether the practice is completed.
  final bool isCompleted;

  /// The large number shown in the center.
  final String valueText;

  /// The caption below the number, such as "/ 108" or "준비".
  final String captionText;

  @override
  Widget build(BuildContext context) {
    // 화면 폭에 맞춰 원 크기를 정한다.
    return LayoutBuilder(
      builder: (context, constraints) {
        // 폭의 90%, 남은 높이, 최대 지름 중 가장 작은 값을 지름으로 쓴다.
        final diameter = math.min(
          math.min(constraints.maxWidth * _widthRatio, constraints.maxHeight),
          _maximumDiameter,
        );
        // 가운데 정렬
        return Center(
          // 고정 크기 상자
          child: SizedBox.square(
            // 원 지름
            dimension: diameter,
            // 링 그림
            child: CustomPaint(
              // 링을 그리는 페인터
              painter: _CounterRingPainter(
                // 전체 진행률
                progress: progress,
                // 안쪽 링 진행률
                innerProgress: innerProgress,
                // 완료 여부
                isCompleted: isCompleted,
                // 테마의 바탕 면 색(링 바탕)
                trackColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                // 안쪽 링 색(버튼색)
                innerRingColor: context.accentColor,
              ),
              // 가운데 숫자와 설명
              child: _CounterLabel(
                // 큰 숫자
                valueText: valueText,
                // 아래 설명
                captionText: captionText,
                // 완료 시 녹색 글자
                isCompleted: isCompleted,
                // 원 크기에 맞춘 숫자 크기
                valueFontSize: diameter * _valueFontRatio,
              ),
            ),
          ),
        );
      },
    );
  }
}

// 원 가운데의 큰 숫자와 설명
class _CounterLabel extends StatelessWidget {
  // 숫자·설명·완료 여부를 받는다.
  const _CounterLabel({
    required this.valueText,
    required this.captionText,
    required this.isCompleted,
    required this.valueFontSize,
  });

  // 큰 숫자
  final String valueText;
  // 아래 설명
  final String captionText;
  // 완료 여부
  final bool isCompleted;
  // 큰 숫자 글자 크기
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    // 글자 스타일을 가져온다.
    final textTheme = Theme.of(context).textTheme;
    // 세로로 가운데 정렬
    return Column(
      // 세로 가운데
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // 큰 숫자
        Text(
          // 현재 절 수 또는 준비 카운트다운
          valueText,
          // 큰 글자, 완료 시 녹색
          style: textTheme.displayLarge?.copyWith(
            // 글자 크기
            fontSize: valueFontSize,
            // 굵게
            fontWeight: FontWeight.w600,
            // 완료 시 녹색, 아니면 기본 글자색
            color: isCompleted ? AppColors.completed : context.textPrimaryColor,
            // 숫자 폭 고정
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        // 설명 문구
        Text(
          // "/ 108" 또는 "준비"
          captionText,
          // 보조 글자색
          style: textTheme.titleMedium?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

// 바깥 진행 링, 완료 테두리, 안쪽 간격 링을 그린다.
class _CounterRingPainter extends CustomPainter {
  // 진행률과 완료 여부를 받는다.
  _CounterRingPainter({
    required this.progress,
    required this.innerProgress,
    required this.isCompleted,
    required this.trackColor,
    required this.innerRingColor,
  });

  // 바깥 진행 링 두께
  static const double _progressStrokeWidth = 14;
  // 안쪽 간격 링 두께
  static const double _innerStrokeWidth = 4;
  // 바깥 진행 링과 안쪽 링 사이 간격
  static const double _innerRingGap = 14;
  // 완료 테두리 두께
  static const double _completedBorderWidth = 3;
  // 완료 테두리를 진행 링 바깥으로 띄우는 거리
  static const double _completedBorderGap = 6;
  // 12시 방향에서 시작하는 각도
  static const double _startAngle = -math.pi / 2;
  // 한 바퀴 각도
  static const double _fullSweep = math.pi * 2;

  // 전체 진행률
  final double progress;
  // 안쪽 링 진행률
  final double innerProgress;
  // 완료 여부
  final bool isCompleted;
  // 링 바탕 색
  final Color trackColor;
  // 안쪽 링 색(버튼색)
  final Color innerRingColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 원의 중심
    final center = size.center(Offset.zero);
    // 완료 테두리까지 들어가도록 바깥 링 반지름을 정한다.
    final outerRadius =
        size.shortestSide / 2 -
        _completedBorderWidth -
        _completedBorderGap -
        _progressStrokeWidth / 2;
    // 안쪽 링 반지름
    final innerRadius = outerRadius - _progressStrokeWidth / 2 - _innerRingGap;
    // 바깥 링 바탕을 그린다.
    _drawArc(
      canvas,
      center,
      outerRadius,
      _fullSweep,
      trackColor,
      _progressStrokeWidth,
    );
    // 완료면 녹색으로 가득, 아니면 주황색으로 진행률만큼 그린다.
    final progressColor = isCompleted
        ? AppColors.completed
        : AppColors.progress;
    // 진행 링 각도
    final progressSweep = _fullSweep * (isCompleted ? 1 : progress.clamp(0, 1));
    // 진행 링을 그린다.
    _drawArc(
      canvas,
      center,
      outerRadius,
      progressSweep,
      progressColor,
      _progressStrokeWidth,
    );
    // 안쪽 링 바탕을 그린다.
    _drawArc(
      canvas,
      center,
      innerRadius,
      _fullSweep,
      trackColor,
      _innerStrokeWidth,
    );
    // 안쪽 링(다음 절까지 남은 시간)을 버튼색으로 그린다.
    _drawArc(
      canvas,
      center,
      innerRadius,
      _fullSweep * innerProgress.clamp(0, 1),
      innerRingColor,
      _innerStrokeWidth,
    );
    // 완료면 바깥 녹색 테두리를 그린다.
    if (isCompleted) {
      // 테두리 반지름
      final borderRadius =
          outerRadius + _progressStrokeWidth / 2 + _completedBorderGap;
      // 녹색 테두리 원
      _drawArc(
        canvas,
        center,
        borderRadius,
        _fullSweep,
        AppColors.completed,
        _completedBorderWidth,
      );
    }
  }

  // 12시 방향에서 시계 방향으로 호를 그린다.
  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double sweepAngle,
    Color color,
    double strokeWidth,
  ) {
    // 그릴 각도가 없으면 끝낸다.
    if (sweepAngle <= 0) {
      // 그릴 것 없음
      return;
    }
    // 선 스타일
    final paint = Paint()
      // 테두리만 그린다.
      ..style = PaintingStyle.stroke
      // 선 두께
      ..strokeWidth = strokeWidth
      // 끝을 둥글게
      ..strokeCap = StrokeCap.round
      // 선 색
      ..color = color;
    // 호를 그린다.
    canvas.drawArc(
      // 원을 감싸는 사각형
      Rect.fromCircle(center: center, radius: radius),
      // 시작 각도
      _startAngle,
      // 그릴 각도
      sweepAngle,
      // 중심과 잇지 않는다.
      false,
      // 선 스타일
      paint,
    );
  }

  @override
  bool shouldRepaint(_CounterRingPainter oldDelegate) {
    // 값이 하나라도 바뀌었을 때만 다시 그린다.
    return oldDelegate.progress != progress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.innerRingColor != innerRingColor;
  }
}
