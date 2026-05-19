{
  pkgs,
  mainUser,
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
    ../../programs/gtk.nix.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "NixOS-Desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim
    vscode
  ];

  programs.helium.enable = true;

  custom-modules.terminals.kitty = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
    transparency = "0.85";
  };

  custom-modules.editors.nvf = {
    enable = true;
  };

  custom-modules.editors.yazi.enable = true;
  custom-modules.editors.thunar.enable = true;

  custom-modules.shell.zsh = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
  };

  custom-modules.shell.starship = {
    enable = true;
    targetUsers = ["${mainUser}" "root"];
  };

  custom-modules.launchers.wofi.enable = true;

  custom-modules.desktop.swww = {
    enable = true;
    autoStartup = true;
  };

  custom-modules.desktop.waybar = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  custom-modules.desktop.gtk = {
    enable = true;
    targetUsers = ["${mainUser}"];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
