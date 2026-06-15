{
  pkgs,
  mainUser,
  config,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../programs/kitty.nix
    ../../programs/nvf.nix
    ../../programs/zsh.nix
    ../../programs/starship.nix
    ../../programs/yazi.nix
    ../../programs/wofi.nix
    ../../programs/thunar.nix
    ../../programs/swww.nix
    ../../programs/gtk.nix
    ../../programs/hyprland.nix
    ../../programs/sober.nix
    ../../programs/tmux.nix
    ../../programs/zellij.nix

    ../../shared/smb-share.nix
  ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";

    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"]; # needed for modern EFI systems

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

  # Allow NixOS to read NTFS(windows) file systems
  boot.supportedFilesystems = ["ntfs"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Support for nvidia graphics cards
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

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
    powerManagement.enable = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  networking.hostName = "NixOS-Desktop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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
    fzf
    fastfetch
    btop
    vim
    direnv
    nix-direnv
    vscode

    inputs.quickshell.packages.${stdenv.hostPlatform.system}.default
  ];

  programs.helium.enable = true;

  custom-modules.terminals.kitty = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
    transparency = "0.85";
  };

  custom-modules.editors.nvf.enable = true;

  custom-modules.editors.yazi.enable = true;
  custom-modules.editors.thunar.enable = true;

  custom-modules.shell.zsh.enable = true;
  custom-modules.shell.zsh.targetUsers = ["${mainUser}" "root"];
  custom-modules.shell.starship.enable = true;
  custom-modules.shell.starship.targetUsers = ["${mainUser}" "root"];

  custom-modules.shell.tmux.enable = true;
  custom-modules.shell.zellij.enable = true;
  custom-modules.shell.zellij.targetUsers = ["${mainUser}" "root"];

  custom-modules.launchers.wofi.enable = true;
  custom-modules.desktop.swww.enable = true;

  environment.sessionVariables = {
    BAR = "qs -d -p /etc/nixos/shared/quickshell-bar.qml"; # Map the system bar to quickshell bar
  };

  custom-modules.desktop.gtk = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.hyprland = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.tools.my-nas.enable = true;

  specialisation = {
    gamer-mode = {
      inheritParentConfig = true;
      configuration = {
        custom-modules.games.sober.enable = true;

        environment.systemPackages = with pkgs; [
          steam
          discord
        ];

        # Changing bootloader label for clarity
        system.nixos.tags = ["gamer-mode"];
      };
    };
  };

  # This value determines the NixOS release from which the default
  system.stateVersion = "26.05";
}
