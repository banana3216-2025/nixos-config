{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom-modules.desktop.printing;
in {
  options.custom-modules.desktop.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables support for print via cups and avahi";
    };
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
        epson-escpr2
      ];
    };
  };
}
