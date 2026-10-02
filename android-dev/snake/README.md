# Snake

A small, offline native Android game. Dark forest colors, mint snake, peach food, swipe controls and on-screen arrows. No ads, accounts, network permissions, or external runtime dependencies.

## Build

From the Android development shell:

```sh
cd /home/derrik/android-dev/snake
./build.sh
```

The script runs the simulation checks, compiles with the installed Android 35 SDK and JDK, and produces `build/snake-debug.apk`. It uses Python 3 to package the dex files. The local debug signing key is kept in `build/debug.keystore`; keep that file to update an existing installation without uninstalling.

The Gradle project is also available for Android Studio (AGP 8.7.3; compatible Gradle 8.9+, JDK 17). The direct SDK build above is the verified build path and needs no downloads.

## Install

Connect an Android phone with USB debugging enabled, or start an emulator, then:

```sh
adb install -r build/snake-debug.apk
adb shell am start -n dev.soltros.snake/.MainActivity
```

Requires Android 8.0 or newer. This is a development APK, not a Play Store release.

## Play

Tap “Let's play,” then swipe anywhere on the board or use the arrow buttons. Eat peach dots to grow; avoid the walls and your body. The game gently speeds up as you score. Pause anytime; leaving the app pauses automatically. Best scores are saved on the device. Keyboard arrows or WASD steer; Space starts, pauses, resumes, or restarts.

## Validation

Eleven deterministic checks cover reversal prevention, growth, food placement, queued turns, wall and self collisions, movement into a vacated tail, pause, full-board victory, and reset. The Android sources compile, and the APK signature verifies. Visual layout and touch behavior still need a device/emulator playtest.
