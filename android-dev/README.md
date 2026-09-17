# Android development environment (nix)

A self-contained, reproducible Android toolchain for NixOS. Two shells:

| Shell              | Command             | Contents                                                        |
| ------------------ | ------------------- | --------------------------------------------------------------- |
| `default` (build)  | `nix develop`       | JDK 17, Gradle, full SDK (platforms 34–37, build-tools, adb, NDK, emulator binary) |
| `emulator`         | `nix develop .#emulator` | emulator + one AVD-ready x86_64 Play Store system image (API 36) |

The build shell is also available via legacy `nix-shell` (uses `<nixpkgs>`).

## Usage

```sh
cd /home/derrik/android-dev

# Build shell (JDK, Gradle, sdkmanager, adb, ndk, emulator)
nix develop
# or: nix-shell

# Emulator shell (has a system image, ready for an AVD)
nix develop .#emulator
```

Inside the build shell, everything is on `PATH`:

```sh
java -version        # OpenJDK 17
gradle --version     # Gradle
adb version          # platform-tools
sdkmanager --list    # installed SDK packages
emulator -version    # emulator binary
echo "$ANDROID_HOME" # Nix store SDK root
```

### Building an app

`ANDROID_HOME` and `JAVA_HOME` are set automatically. In a Gradle Android
project directory, entering the shell also appends an `sdk.dir=` line to
`local.properties` (only if the file doesn't already declare one), which is
what Android Studio and AGP look for.

If AGP can't find the right aapt2, the shell sets
`aapt2FromMavenOverride` to the store's newest patched aapt2 — a NixOS/FHS
workaround. For unusual AGP versions you can unset it:

```sh
unset GRADLE_OPTS
```

### Running an emulator

```sh
nix develop .#emulator
avdmanager create avd -n phone -k "system-images;android-36;google_apis_playstore;x86_64" -d pixel_7
emulator -avd phone -gpu swiftshader_indirect   # or -gpu host if GL works
```

Requires `/dev/kvm` (present on this machine) and that your user can open it.
The emulator shell and the build shell are independent — run the emulator in
one terminal and build in another; they both expose `adb`, so `adb install`
works from the build shell.

## Customizing

Edit `shell.nix` (build shell) or the `emulator` block in `flake.nix`:

- `platformVersions` / `buildToolsVersions` — add or remove API levels.
  Valid keys come from nixpkgs' `androidenv/repo.json`.
- `includeNDK` — set `false` to drop the ~1 GB NDK.
- `includeEmulator` — set `false` to drop the ~300 MB emulator binary.
- `includeSources` — set `true` to include platform sources.
- `includeSystemImages`, `systemImageTypes`, `abiVersions` — control the
  emulator shell's system images (`x86_64` for Intel/AMD hosts; `arm64-v8a`
  only makes sense on Apple Silicon).

## Notes

- SDK packages are downloaded from `cache.nixos.org` (and Google's CDN for the
  raw archives) on first build; the first `nix develop` will take a while.
- Licenses (`unfree` + the explicit Android SDK license) are accepted
  declaratively in `flake.nix`/`shell.nix` via `allowUnfree` and
  `android_sdk.accept_license`. You still agreed to Google's terms by using it.
- To point Android Studio at this SDK, set its SDK location to the value of
  `$ANDROID_HOME` (printed on shell entry). Note: Android Studio manages its own
  SDK by default and cannot write into the read-only Nix store; prefer the CLI
  toolchain here, or use Android Studio with its own `~/Android/Sdk`.
