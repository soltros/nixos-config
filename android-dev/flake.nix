{
  description = "Complete Android development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      mkPkgs = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (mkPkgs system));
    in
    {
      devShells = forAllSystems (pkgs: {
        # Build toolchain: JDK, Gradle, full SDK (platforms, build-tools, adb,
        # NDK, emulator binary) — no system images.
        default = import ./shell.nix { inherit pkgs; };

        # AVD-ready shell: emulator + one x86_64 Play Store system image (API 36).
        # Needs /dev/kvm for usable speed.
        emulator = let
          emu = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ "36" ];
            buildToolsVersions = [ "36.1.0" ];
            includeEmulator = "if-supported";
            includeSystemImages = true;
            systemImageTypes = [ "google_apis_playstore" ];
            abiVersions = [ "x86_64" ];
            includeNDK = false;
            includeSources = false;
          };
          sdk = emu.androidsdk;
          jdk = pkgs.jdk17;
        in pkgs.mkShell {
          name = "android-emulator";
          packages = [ sdk jdk ];
          LANG = "C.UTF-8";
          LC_ALL = "C.UTF-8";
          JAVA_HOME = jdk.home;
          ANDROID_HOME = "${sdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${sdk}/libexec/android-sdk";
          shellHook = ''
            echo "Emulator SDK -> $ANDROID_HOME"
            echo "Create an AVD:"
            echo '  avdmanager create avd -n phone -k "system-images;android-36;google_apis_playstore;x86_64" -d pixel_7'
            echo "  emulator -avd phone -gpu swiftshader_indirect"
          '';
        };
      });
    };
}
