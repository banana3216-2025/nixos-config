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
    ../../programs/waybar.nix
    ../../programs/gtk.nix
    ../../programs/hyprland.nix
    ../../programs/sober.nix
    ../../programs/tmux.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.settings = {
    max-jobs = 4; # Scale this based on your RAM (e.g., 1 or 2 max)
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

  custom-modules.launchers.wofi.enable = true;
  custom-modules.desktop.swww.enable = true;

  custom-modules.desktop.waybar = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.gtk = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.hyprland = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

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
