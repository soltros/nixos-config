#!/usr/bin/env bash
# Non-interactive verification of the Android dev shell.
set -u
ok=1

say() { printf '\n== %s ==\n' "$*"; }

say "toolchain"
java -version 2>&1 | head -2 || ok=0
echo "JAVA_HOME=${JAVA_HOME:-<unset>}"
gradle --version 2>&1 | grep -E '^Gradle ' || { echo "gradle MISSING"; ok=0; }

say "android env"
echo "ANDROID_HOME=${ANDROID_HOME:-<unset>}"
[ -n "${ANDROID_HOME:-}" ] || { echo "ANDROID_HOME unset"; ok=0; }

say "adb / fastboot"
adb version 2>&1 | head -1 || ok=0
fastboot --version 2>&1 | head -1 || ok=0

say "sdkmanager"
sdkmanager --version 2>&1 | head -1 || ok=0

say "sdk layout"
ls "$ANDROID_HOME" 2>&1 || ok=0
echo "-- platforms --"; ls "$ANDROID_HOME/platforms" 2>&1
echo "-- build-tools --"; ls "$ANDROID_HOME/build-tools" 2>&1
echo "-- ndk --"; ls "$ANDROID_HOME/ndk-bundle" 2>&1 | head -5
echo "-- licenses --"; ls "$ANDROID_HOME/licenses" 2>&1

say "emulator binary"
if command -v emulator >/dev/null 2>&1; then
  emulator -version 2>&1 | head -1 || true
else
  echo "emulator NOT on PATH"; ok=0
fi

echo
if [ "$ok" = 1 ]; then echo "RESULT: OK"; else echo "RESULT: FAIL"; fi
exit $((1 - ok))
