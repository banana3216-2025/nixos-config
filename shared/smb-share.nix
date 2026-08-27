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
    userID = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "choices what user will own the directory";
    };

    groupID = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "choices what user group owns the directory";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.cifs-utils];

    fileSystems."/mnt/share" = {
      device = "//192.168.2.100/share";
      fsType = "cifs";
      options = let
        # Prevent system hangs if the network share becomes unavailable
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        "${automount_opts},credentials=/etc/nixos/smb-secrets"
        "uid=${toString cfg.userID}"
        "gid=${toString cfg.groupID}"
      ];
    };
    fileSystems."/mnt/extra" = {
      device = "//192.168.2.100/extra-drive";
      fsType = "cifs";
      options = let
        # Prevent system hangs if the network share becomes unavailable
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        "${automount_opts},credentials=/etc/nixos/smb-secrets"
        "uid=${toString cfg.userID}"
        "gid=${toString cfg.groupID}"
      ];
    };
  };
}
