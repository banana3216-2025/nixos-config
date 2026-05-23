{
  config,
  lib,
  pkgs,
  mainUser,
  ...
}: let
  cfg = config.custom-modules.desktop.swww;
in {
  options.custom-modules.desktop.swww = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables swww wallpaper service";
    };

    autoStartup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Added the swww daemon to startup";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [pkgs.awww];
    })

    (lib.mkIf cfg.autoStartup {
      systemd.user.services.custom-modules-swww = {
        description = "swww wallpaper daemon";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
          Restart = "on-failure";
          User = "${mainUser}";
        };
      };
    })
  ];
}
