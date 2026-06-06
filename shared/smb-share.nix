{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.tools.my-nas;
in {
  options.custom-modules.tools.my-nas = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the mounting of my nas";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.cifs-utils];

    fileSystems."/mnt/share" = {
      device = "//192.168.2.45/share";
      fsType = "cifs";
      options = let
        # Prevent system hangs if the network share becomes unavailable
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        "${automount_opts},credentials=/etc/nixos/smb-secrets"
      ];
    };
  };
}
