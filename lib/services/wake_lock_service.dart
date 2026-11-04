import 'package:wakelock_plus/wakelock_plus.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts keeping the screen on while a practice is in progress.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 중 화면이 꺼지지 않게 하는 서비스 계약.
abstract interface class WakeLockService {
  /// Keeps the screen on until [disable] is called.
  Future<void> enable();

  /// Allows the screen to turn off again.
  Future<void> disable();
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Keeps the screen on by using the wakelock_plus plugin.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// wakelock_plus 플러그인으로 화면 켜짐을 유지하는 구현.
final class PluginWakeLockService implements WakeLockService {
  /// Creates the plugin-backed wake lock service.
  const PluginWakeLockService();

  @override
  Future<void> enable() {
    // 화면 꺼짐 방지를 켠다.
    return WakelockPlus.enable();
  }

  @override
  Future<void> disable() {
    // 화면 꺼짐 방지를 끈다.
    return WakelockPlus.disable();
  }
}
