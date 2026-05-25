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
      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org";
        }
      ];

      packages = ["flathub:org.vinegarhq.Sober"];
    };
  };
}
