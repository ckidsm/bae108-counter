#!/usr/bin/env bash
# 108배 카운터 → 아이폰 실기기 배포 (OneDrive 폴더에서는 iOS 코드사인이 실패하므로 ~/Library/Caches 로 복사해 빌드)
#
#   ./tool/deploy_ios.sh                # release 빌드 → 연결된 아이폰(iPhoneDeoksoo)에 설치·실행
#   ./tool/deploy_ios.sh --debug        # debug 빌드 (flutter attach 가능)
#   ./tool/deploy_ios.sh --device <UDID>
#
# 전제: 케이블 연결 + 아이폰 잠금 해제 + 개발자 모드 ON. 서명: Xcode 자동(Team RRTB256N59, Apple Development 인증서 키체인에 있음).
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="$HOME/Library/Caches/bae108-ios-build"
MODE=release
DEVICE="00008120-000C08A63A5BC01E"   # iPhoneDeoksoo
while [ $# -gt 0 ]; do
  case "$1" in
    --debug) MODE=debug ;;
    --release) MODE=release ;;
    --device) DEVICE="$2"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

echo "▶ 1/4 복사 → $DST"
mkdir -p "$DST"
rsync -a --delete --exclude build --exclude .dart_tool --exclude ios/Pods --exclude .idea "$SRC/" "$DST/"
xattr -rc "$DST" 2>/dev/null || true

echo "▶ 2/4 flutter build ios --$MODE"
cd "$DST"
flutter pub get >/dev/null
flutter build ios --"$MODE" 2>&1 | grep -v "Provisioning Profiles/ios_development.cer" | tail -5
APP="$DST/build/ios/iphoneos/Runner.app"

echo "▶ 3/4 설치 → $DEVICE (잠겨 있으면 잠금 해제 후 자동 재시도, 최대 4분)"
for i in $(seq 1 24); do
  out=$(xcrun devicectl device install app --device "$DEVICE" "$APP" 2>&1) && { echo "$out" | grep -E "bundleID|installationURL"; break; }
  if echo "$out" | grep -q "DeviceLocked"; then echo "  … 아이폰이 잠겨 있음 ($i)"; sleep 10; continue; fi
  echo "$out" | tail -15; exit 1
done

echo "▶ 4/4 실행 (잠겨 있으면 잠금 해제 후 자동 재시도, 최대 2분)"
for i in $(seq 1 12); do
  out=$(xcrun devicectl device process launch --device "$DEVICE" com.ckidsm.bae108Counter 2>&1) && { echo "$out" | tail -1; break; }
  if echo "$out" | grep -qi "unlock"; then echo "  … 아이폰이 잠겨 있음 ($i)"; sleep 10; continue; fi
  echo "$out" | tail -8; break
done
[ "$MODE" = debug ] && echo "   디버그 로그 붙이기: cd \"$DST\" && flutter attach -d $DEVICE"
echo "✓ 완료"
