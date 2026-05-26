{
  config,
  lib,
  ...
}: let
  cfg = config.custom-modules.games.sober;
in {
  options.custom-modules.games.sober = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables roblox via Sober & Flatpak";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;

      packages = [
        "org.vinegarhq.Sober"
      ];
    };

    environment.profiles = [
      "$HOME/.local/share/flatpak/exports"
      "/var/lib/flatpak/exports"
    ];
  };
}
