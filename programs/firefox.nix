{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.firefox;
in {
  options.custom-modules.desktop.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable librewolf with ad blocking";
    };

    targetUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["desktopUser"];
      description = "Users to apply Home Manager settings to.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Install LibreWolf cleanly at the system level
    environment.systemPackages = [pkgs.librewolf];

    # 2. Hand off the user configuration directly to Home Manager
    home-manager.users = lib.genAttrs cfg.targetUsers (username: {
      # Tell Home Manager to configure LibreWolf
      programs.librewolf = {
        enable = true;

        profiles = {
          # Use 'default' or whatever profile name you prefer
          default = {
            id = 0;
            isDefault = true;

            # Natively enforce the settings at the user profile level
            settings = {
              "sidebar.verticalTabs" = true;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
              "startup.homepage_override_url" = "about:blank";
              "startup.homepage_welcome_url" = "about:blank";
              "browser.newtabpage.enabled" = false;
              "browser.uidensity" = 1;

              # Include your target privacy policies here as user overrides
              "cookiebanners.service.mode.privateBrowsing" = 2;
              "cookiebanners.service.mode" = 2;
              "privacy.donottrackheader.enabled" = true;
              "privacy.fingerprintingProtection" = true;
              "privacy.resistFingerprinting" = false;
              "privacy.trackingprotection.emailtracking.enabled" = true;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.fingerprinting.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
            };

            # 3. PURE NATIVE USERCHROME INJECTION
            # Home Manager automatically calculates your profile path and handles the symlink safely.
            userChrome = builtins.readFile ../shared/librewolf-userChrome.css;
          };
        };
      };
    });

    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "Open-reader" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4450495/reader_view-0.3.1.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    environment.etc."librewolf/policies/policies.json".text =
      builtins.toJSON {inherit (config.programs.firefox) policies;};
  };
}
