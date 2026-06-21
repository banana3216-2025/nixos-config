{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.boot.nix-plymouth-theme;

  nix-apple-theme = pkgs.stdenv.mkDerivation {
    pname = "nix-apple-theme";
    version = "1.0.0";

    src = ./.;

    dontBuild = true;

    installPhase = ''
      TARGET_DIR="$out/share/plymouth/themes/nix-apple-theme"
      mkdir -p "$TARGET_DIR"

      # 🌟 Step 1: Copy absolutely everything safely into the build output
      cp -r * "$TARGET_DIR/"

      # 🌟 Step 2: Dynamically normalize files to what NixOS expects, no matter how you named them on disk
      cd "$TARGET_DIR"

      if [ -f nix-apple.plymouth ]; then
        mv nix-apple.plymouth nix-apple-theme.plymouth
      fi

      if [ -f nix-apple.script ]; then
        mv nix-apple.script nix-apple-theme.script
      fi

      # 🌟 Step 3: Fix path replacements inside the finalized file layout
      if [ -f nix-apple-theme.plymouth ]; then
        sed -i "s@\/usr\/@$out\/@g" nix-apple-theme.plymouth
        sed -i "s/nix-apple.script/nix-apple-theme.script/g" nix-apple-theme.plymouth
      else
        echo "ERROR: No plymouth configuration file found!"
        exit 1
      fi
    '';
  };
in {
  options.custom-modules.boot.nix-plymouth-theme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables plymouth & my custom nix based theme";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "nix-apple-theme";
        themePackages = [nix-apple-theme];
      };

      # Silent boot optimization defaults
      consoleLogLevel = 0;
      initrd.verbose = false;
      initrd.systemd.enable = true;
      kernelParams = [
        "quiet"
        "splash"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
        "vt.global_cursor_default=0"
      ];
    };
  };
}
