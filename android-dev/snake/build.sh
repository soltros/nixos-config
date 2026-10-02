#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_HOME:?Enter your Android nix-shell first}"
: "${JAVA_HOME:?Enter your Android nix-shell first}"
export PATH="$JAVA_HOME/bin:$PATH"
SDK_TOOLS="$ANDROID_HOME/build-tools/35.0.0"
ANDROID_JAR="$ANDROID_HOME/platforms/android-35/android.jar"
mkdir -p build/classes build/dex build/tests
javac -d build/tests app/src/main/java/dev/soltros/snake/SnakeGame.java tests/SnakeGameTest.java
java -cp build/tests dev.soltros.snake.SnakeGameTest
"$SDK_TOOLS/aapt2" compile --dir app/src/main/res -o build/resources.zip
"$SDK_TOOLS/aapt2" link --version-code 1 --version-name 1.0 -o build/base.apk -I "$ANDROID_JAR" --manifest app/src/main/AndroidManifest.xml build/resources.zip
javac -source 8 -target 8 -Xlint:-options -classpath "$ANDROID_JAR" -d build/classes app/src/main/java/dev/soltros/snake/*.java
jar cf build/classes.jar -C build/classes .
"$SDK_TOOLS/d8" --lib "$ANDROID_JAR" --min-api 26 --output build/dex build/classes.jar
cp build/base.apk build/unsigned.apk
python3 - <<'PY'
from zipfile import ZipFile, ZIP_DEFLATED
from pathlib import Path
with ZipFile('build/unsigned.apk','a',ZIP_DEFLATED) as apk:
    for dex in Path('build/dex').glob('*.dex'): apk.write(dex,dex.name)
PY
"$SDK_TOOLS/zipalign" -f 4 build/unsigned.apk build/aligned.apk
if [ ! -f build/debug.keystore ]; then
    keytool -genkeypair -keystore build/debug.keystore -storepass android -keypass android -alias androiddebugkey -dname 'CN=Android Debug,O=Android,C=US' -keyalg RSA -keysize 2048 -validity 10000
fi
"$SDK_TOOLS/apksigner" sign --ks build/debug.keystore --ks-pass pass:android --out build/snake-debug.apk build/aligned.apk
"$SDK_TOOLS/apksigner" verify build/snake-debug.apk
printf '\nBuilt: %s/build/snake-debug.apk\n' "$PWD"
