import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../models/alert_mode.dart';
import '../models/bell_sound.dart';
import 'bow_feedback_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the asset path and timings used by device feedback.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 기기 알림에 쓰는 리소스 경로와 시간 값.
abstract final class FeedbackSettings {
  // 에셋 폴더 접두어(audioplayers는 이 아래 상대 경로를 받는다)
  /// The prefix audioplayers adds in front of [AssetSource] paths.
  static const String assetPrefix = 'assets/';

  // 짧은 소리(목탁)를 108배째에 반복할 때의 간격
  /// The gap between strikes of a short sound for the final bow.
  static const Duration finalShortSoundGap = Duration(milliseconds: 450);

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the bundled file of a bell sound, relative to assets/.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the path of [bellSound] relative to the `assets/` folder.
  static String sourcePathOf(BellSound bellSound) {
    // 소리별 파일
    return switch (bellSound) {
      // 중저음 종(처음부터 있던 파일)
      BellSound.deep => 'sounds/bell.mp3',
      // 맑은 종
      BellSound.clear => 'sounds/bell_clear.mp3',
      // 풍경
      BellSound.chime => 'sounds/chime.mp3',
      // 목탁
      BellSound.moktak => 'sounds/moktak.mp3',
    };
  }

  // 108배째 종소리를 울리는 횟수
  /// How many times the bell rings for the final bow.
  static const int finalBellRepeatCount = 3;

  // 108배째 종소리 사이 간격
  /// The gap between bell strikes for the final bow.
  static const Duration finalBellGap = Duration(milliseconds: 1400);

  // 108배째 클릭음(종소리 파일이 없을 때)을 울리는 횟수
  /// How many times the fallback click plays for the final bow.
  static const int finalClickRepeatCount = 3;

  // 108배째 클릭음 사이 간격
  /// The gap between fallback clicks for the final bow.
  static const Duration finalClickGap = Duration(milliseconds: 250);

  // 일반 1배 진동 길이(ms)
  /// The vibration length of a regular bow, in milliseconds.
  static const int regularVibrationMilliseconds = 200;

  // 108배째 진동 패턴(ms): 대기, 진동, 쉼, 진동, 쉼, 긴 진동
  /// The vibration pattern of the final bow, in milliseconds.
  static const List<int> finalVibrationPatternMilliseconds = <int>[
    0,
    400,
    150,
    400,
    150,
    900,
  ];
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Plays bell, vibration, or no feedback using the device hardware.
 Remarks  : Falls back to the system click sound when bell.mp3 is not bundled.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 실제 기기의 소리와 진동으로 1배 알림을 내보내는 서비스.
final class DeviceBowFeedbackService implements BowFeedbackService {
  /// Creates the service with its own audio player.
  DeviceBowFeedbackService() : _audioPlayer = AudioPlayer();

  // 종소리를 재생할 플레이어
  final AudioPlayer _audioPlayer;

  // 소리 파일마다 존재 여부를 한 번만 확인하도록 결과를 보관한다.
  final Map<BellSound, Future<bool>> _bellAvailability =
      <BellSound, Future<bool>>{};

  @override
  Future<void> notifyBow(
    AlertMode alertMode, {
    required BellSound bellSound,
    required bool isFinalBow,
  }) async {
    // 선택된 알림 방식에 따라 처리를 나눈다.
    switch (alertMode) {
      // 종소리 방식
      case AlertMode.bell:
        // 종소리(또는 대체 클릭음)를 울린다.
        await _playBell(bellSound, isFinalBow: isFinalBow);
      // 진동 방식
      case AlertMode.vibration:
        // 진동을 울린다.
        await _vibrate(isFinalBow: isFinalBow);
      // 무음 방식
      case AlertMode.silent:
        // 아무것도 하지 않는다.
        return;
    }
  }

  @override
  Future<void> previewBell(BellSound bellSound) {
    // 한 번만 울린다.
    return _playBell(bellSound, isFinalBow: false);
  }

  @override
  Future<void> dispose() async {
    // 오디오 플레이어가 잡고 있는 네이티브 자원을 해제한다.
    await _audioPlayer.dispose();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Rings the bell, or the system click when the bell asset is missing.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  Future<void> _playBell(
    BellSound bellSound, {
    required bool isFinalBow,
  }) async {
    // 선택한 소리의 파일 경로(assets/ 기준)
    final sourcePath = FeedbackSettings.sourcePathOf(bellSound);
    // 소리 파일이 앱에 포함되어 있는지 확인한다(소리마다 처음 한 번만 실제로 확인).
    final isBellAvailable = await _bellAvailability.putIfAbsent(
      bellSound,
      () => _checkBellAsset(FeedbackSettings.assetPrefix + sourcePath),
    );
    // 종소리 파일이 없으면 시스템 클릭음으로 대신한다.
    if (!isBellAvailable) {
      // 클릭음을 울린다(108배째는 여러 번).
      await _playClick(isFinalBow: isFinalBow);
      // 클릭음으로 대신했으니 끝낸다.
      return;
    }
    // 108배째는 여러 번, 그 외에는 한 번 울린다.
    final repeatCount = isFinalBow ? FeedbackSettings.finalBellRepeatCount : 1;
    // 정해진 횟수만큼 종을 친다.
    for (var strikeIndex = 0; strikeIndex < repeatCount; strikeIndex++) {
      // 두 번째 타종부터는 앞 소리가 울릴 시간을 둔다.
      if (strikeIndex > 0) {
        // 타종 사이 간격만큼 기다린다(짧은 목탁은 더 촘촘히).
        await Future<void>.delayed(
          bellSound == BellSound.moktak
              ? FeedbackSettings.finalShortSoundGap
              : FeedbackSettings.finalBellGap,
        );
      }
      // 앞 소리가 남아 있으면 멈추고 처음부터 다시 친다.
      await _audioPlayer.stop();
      // 종소리를 재생한다.
      await _audioPlayer.play(AssetSource(sourcePath));
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Checks whether the bell asset is bundled with the app.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  Future<bool> _checkBellAsset(String assetKey) async {
    // 에셋을 읽어 보고 성공하면 파일이 있는 것으로 본다.
    try {
      // 소리 에셋을 읽는다.
      await rootBundle.load(assetKey);
      // 읽기에 성공했으니 종소리를 쓸 수 있다.
      return true;
    } on FlutterError catch (error) {
      // 파일이 없다는 사실을 남기고 클릭음으로 대신하도록 false를 돌려준다.
      debugPrint('[BowFeedback] 소리 파일 없음 $assetKey, 시스템 클릭음 사용: $error');
      // 종소리를 쓸 수 없다.
      return false;
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Plays the system click as a substitute for the bell.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  Future<void> _playClick({required bool isFinalBow}) async {
    // 108배째는 여러 번, 그 외에는 한 번 울린다.
    final repeatCount = isFinalBow ? FeedbackSettings.finalClickRepeatCount : 1;
    // 정해진 횟수만큼 클릭음을 울린다.
    for (var clickIndex = 0; clickIndex < repeatCount; clickIndex++) {
      // 두 번째 클릭음부터는 간격을 둔다.
      if (clickIndex > 0) {
        // 클릭음 사이 간격만큼 기다린다.
        await Future<void>.delayed(FeedbackSettings.finalClickGap);
      }
      // 시스템 클릭음을 울린다.
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Vibrates briefly for a bow, or with a long pattern for the final bow.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  Future<void> _vibrate({required bool isFinalBow}) async {
    // 진동 모터가 없는 기기(일부 태블릿 등)는 햅틱으로 대신한다.
    final hasVibrator = await Vibration.hasVibrator();
    // 진동 모터가 없으면 햅틱 피드백만 준다.
    if (!hasVibrator) {
      // 가장 강한 햅틱을 준다.
      await HapticFeedback.heavyImpact();
      // 대체 처리를 마쳤으니 끝낸다.
      return;
    }
    // 108배째는 긴 패턴으로 진동한다.
    if (isFinalBow) {
      // 대기-진동-쉼 패턴으로 길게 울린다.
      await Vibration.vibrate(
        pattern: FeedbackSettings.finalVibrationPatternMilliseconds,
      );
      // 긴 진동을 시작했으니 끝낸다.
      return;
    }
    // 일반 1배는 짧게 진동한다.
    await Vibration.vibrate(
      duration: FeedbackSettings.regularVibrationMilliseconds,
    );
  }
}
