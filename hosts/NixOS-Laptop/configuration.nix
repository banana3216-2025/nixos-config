{
  pkgs,
  mainUser,
  inputs,
  ...
}: let
  sddm-astronaut =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "hyprland_kath";
      themeConfig = {
        HeaderTextColor = "#d5c4a1";
        Font = "JetBrainsMono Nerd Font";
        FontSize = "12";
        FormPosition = "left";
        Background = "Backgrounds/your-custom-background.jpg";
      };
    }).overrideAttrs (oldAttrs: {
      installPhase =
        oldAttrs.installPhase
        + ''
          chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
          cp ${./program-data/sddm-wallpaper.jpg} \
            $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/your-custom-background.jpg
        '';
    });
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./extra-hardware.nix

    ../../programs/ghostty.nix
    ../../programs/zsh.nix
    ../../programs/starship.nix
    ../../programs/yazi.nix
    ../../programs/wofi.nix
    ../../programs/thunar.nix
    ../../programs/swww.nix
    ../../programs/stylix.nix
    ../../programs/hyprland.nix
    ../../programs/sober.nix
    ../../programs/zellij.nix

    ../../shared/smb-share.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow NixOS to read NTFS(windows) file systems
  boot.supportedFilesystems = ["ntfs"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.kmscon = {
    enable = true;
    config = {
      hwaccel = true;
      font-engine = "pixman";
    };
  };

  networking.hostName = "NixOS-Laptop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  console.useXkbConfig = true;

  # set clock format to 24 hours
  i18n = {
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  services.dbus.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  nix.settings = {
    max-jobs = 4;
    cores = 6;
  };

  users.users.${mainUser} = {
    isNormalUser = true;
    description = "user";
    extraGroups = ["networkmanager" "wheel"];
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "banana3216-2025";
        email = "banana.3216.2025@gmail.com";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gh
    eza
    brightnessctl
    fzf
    fastfetch
    btop
    vim
    direnv
    nix-direnv
    vscode

    quickshell
    gimp
    davinci-resolve

    bibata-cursors

    inputs.nvf-config.packages.${pkgs.stdenv.hostPlatform.system}.default
    sddm-astronaut
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      epson-escpr2
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.helium.enable = true;

  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";

    wayland.enable = true;

    extraPackages = [
      sddm-astronaut
      pkgs.hyprland
      pkgs.bibata-cursors

      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtsvg # Safely handles any custom SVG icon layouts
      pkgs.kdePackages.qt5compat # Resolves older backported component bindings
      pkgs.kdePackages.qtdeclarative # Delivers the main engine framework for QML rendering
    ];
  };
  environment.etc = {
    "X11/Xresources".text = ''
      Xcursor.theme: Bibata-Modern-Ice
      Xcursor.size: 24
    '';

    # Forces the underlying display architecture to fallback directly onto Bibata
    "icons/default/index.theme".text = ''
      [Icon Theme]
      Inherits=Bibata-Modern-Ice
    '';
  };

  services.power-profiles-daemon.enable = false; # Stop stupid KDE from trying to manage the power mode

  custom-modules.terminals.ghostty = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
    transparency = "0.85";
  };

  custom-modules.editors.yazi.enable = true;
  custom-modules.editors.thunar.enable = true;

  custom-modules.shell.zsh.enable = true;
  custom-modules.shell.zsh.targetUsers = ["${mainUser}" "root"];
  custom-modules.shell.starship.enable = true;
  custom-modules.shell.starship.targetUsers = ["${mainUser}" "root"];

  custom-modules.shell.zellij.enable = true;
  custom-modules.shell.zellij.targetUsers = ["${mainUser}" "root"];

  custom-modules.launchers.wofi.enable = true;
  custom-modules.desktop.swww.enable = true;

  environment.variables = {
    SHELL = "qs -d -p /etc/nixos/shared/quickshell/shell.qml";
    NOTIFICATION_OPEN = "qs -p /etc/nixos/shared/quickshell/shell.qml ipc call notifications toggle";

    EDITOR = "nvim";
  };

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
    XDG_DATA_DIRS = ["/run/opengl-driver/share"];
  };

  custom-modules.desktop.stylix = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.hyprland = {
    enable = true;
    targetUsers = ["${mainUser}"];
    useSharedKeybinds = true;
  };

  custom-modules.tools.my-nas.enable = true;

  custom-modules.games.sober.enable = true;

  # This value determines the NixOS release from which the default
  system.stateVersion = "26.05";
}
