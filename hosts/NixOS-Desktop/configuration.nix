{
  pkgs,
  mainUser,
  config,
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

    ../../programs/ghostty.nix
    ../../programs/zsh.nix
    ../../programs/starship.nix
    ../../programs/yazi.nix
    ../../programs/wofi.nix
    ../../programs/thunar.nix
    ../../programs/swww.nix
    ../../programs/gtk.nix
    ../../programs/hyprland.nix
    ../../programs/sober.nix
    ../../programs/zellij.nix
    ../../programs/firefox.nix

    ../../shared/smb-share.nix
    ../../shared/plymouth-theme-nix-apple/theme.nix
  ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";

    timeout = 2;

    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"]; # needed for modern EFI systems

      #timeoutStyle = "hidden";
      #splashImage = null;
      #backgroundColor = "#000000";

      useOSProber = false;
      extraEntries = ''
        menuentry "Windows 10" --class windows --class os {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root A0FE-8C72
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }

        menuentry "Fedora Linux" --class fedora --class os {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root A0FE-8C72
            chainloader /EFI/fedora/grubx64.efi
        }
      ''; # add boot entries munually to speed up rebuilds
    };
  };

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/F0C693B5C6937A94";
    fsType = "ntfs3";
    options = [
      "nofail"
      "rw"
      "dmask=0022" # Sets directory permissions (755)
      "fmask=0022" # Sets file permissions (755)
      "uid=${toString 1000}"
      "gid=${toString 100}"
      "x-systemd.automount"
    ];
  };

  # enable plymouth with my theme
  custom-modules.boot.nix-plymouth-theme.enable = true;

  # Allow NixOS to read NTFS(windows) file systems
  boot.supportedFilesystems = ["ntfs"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Support for nvidia graphics cards
  boot.kernelParams = ["nvidia-drm.fbdev=1"];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerDefaultAC=0x1"
  '';

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      libva-vdpau-driver
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  networking.hostName = "NixOS-Desktop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Configure keyboard layout
  services.xserver.xkb = {
    layout = "us,us";
    variant = ",dvorak"; # Empty string before the comma keeps the first layout standard
    options = ""; # shortcut definied in hyprland config
  };

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

  nix.settings = {
    max-jobs = 4; # Scale this based on your RAM(about 1/2 your RAM +- ~2)
    cores = 6; # Limit the number of cores used per build job
  };

  users.users.${mainUser} = {
    isNormalUser = true;
    description = "user";
    extraGroups = ["networkmanager" "wheel" "uinput" "cdrom" "disk"];
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
    fzf
    lsd
    fastfetch
    btop
    vim
    quickshell
    bat
    virt-viewer
    grim
    slurp
    wl-clipboard
    cliphist
    feh

    vscode
    gimp
    davinci-resolve
    kicad
    tetrio-desktop

    inputs.nvf-config.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.subtui.packages.${pkgs.stdenv.hostPlatform.system}.default
    mpv
    sddm-astronaut
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "heluim.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";

      "image/*" = "feh.desktop";
      "inode/directory" = "yazi.desktop";
    };
  };

  programs.zoxide.enable = true;

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

  custom-modules.terminals.ghostty = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
    transparency = "0.85";
  };

  custom-modules.editors.yazi.enable = true;
  custom-modules.editors.thunar.enable = true;

  custom-modules.shell.zsh.enable = true;
  custom-modules.shell.zsh.targetUsers = ["${mainUser}" "root"];
  custom-modules.shell.zsh.aliases = {
    ls = "lsd -al --icon always --size short";
    clear-history = "/etc/nixos/shared/clear_history.sh";
    cat = "bat";
  };

  custom-modules.shell.starship.enable = true;
  custom-modules.shell.starship.targetUsers = ["${mainUser}" "root"];

  custom-modules.shell.zellij.enable = true;
  custom-modules.shell.zellij.targetUsers = ["${mainUser}" "root"];

  custom-modules.launchers.wofi.enable = true;
  custom-modules.desktop.swww.enable = true;

  custom-modules.desktop.firefox.enable = true;
  custom-modules.desktop.firefox.targetUsers = ["${mainUser}" "root"];

  environment.variables = {
    EDITOR = "nvim";

    DESKTOP_SHELL = "qs -d -p /etc/nixos/shared/quickshell/shell.qml";
    NOTIFICATION_OPEN = "qs -p /etc/nixos/shared/quickshell/shell.qml ipc call notifications toggle";
  };

  custom-modules.desktop.gtk = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.hyprland = {
    enable = true;
    targetUsers = ["${mainUser}"];
    allow-impure-lua = true;
  };

  custom-modules.tools.my-nas.enable = true;
  custom-modules.desktop.printing.enable = true;

  programs.driftwm.enable = true; # Testing Out DriftWM

  specialisation = {
    gamer-mode = {
      inheritParentConfig = true;
      configuration = {
        custom-modules.games.sober.enable = true;

        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
          openFirewall = true;
        };

        environment.systemPackages = with pkgs; [
          steam
          discord
          prismlauncher
          supertuxkart
        ];

        # Changing bootloader label for clarity
        system.nixos.tags = ["gamer-mode"];
      };
    };
  };

  # This value determines the NixOS release from which the default
  system.stateVersion = "26.05";
}
