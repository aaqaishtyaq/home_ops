# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = (import ../../secrets);
  user = secrets.user;
  interface = secrets.interface;
  hostname = secrets.hostname;
  SSID = secrets.SSID;
  SSIDpassword = secrets.SSIDpassword;
  password = secrets.password;
  pi4 = fetchTarball {url=https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz;sha256="06g0061xm48i5w7gz5sm5x5ps6cnipqv1m483f8i9mmhlz77hvlw";};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${pi4}/raspberry-pi/4"
    ];

  # Make it boot on the RP, taken from here: https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4
  boot = {
    tmpOnTmpfs = true;
    kernelPackages = pkgs.linuxPackages_rpi4; # Mainline doesn't work yet
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      raspberryPi.enable = true;
      raspberryPi.version = 4;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };
  };

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ interface ];
    };
    useDHCP = false;
    interfaces = {
      eth0.useDHCP = true;
      wlan0.useDHCP = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "lxd" ]; # Enable ‘sudo’ for the user.
      home = "/home/${user}";
      description = "Aaqa Ishtyaq";
      password = password;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/8WD1TXx6EitWjXg8o8kfGXllS5OBovtxinMqWox4jH0bBvzO0r2cEMslxGL+zvQP0ruQeqTq5TFiRNuo4XeGb8NoJhCBmELKVQBXepgW0Kp3PtAoXCiYytidUVloZffbhLV+6mMdPpnNqiWfHRrmf1n+Kf64xpiobInKIDv3OGoe/HvvQSAX4hgiOmj76n7fGmDFQco0C++BVNVoMAQmHwGxC8lW2RFhjeTxjHSwxQdsupaEJ0IXjEmzx823zzK7fB4eNYVaDGttuKnmTzPmH8vzwkpoMSKaZ+X8rzMYrzODnyJPWtdhro9ab/VAiwps/6Qv5te1oYD9+Eu5q3VJlvgBtQmQJB14X4HdcUSlAwkQms/qxfOj5DDfSIkKT9eTAdhraDgkPnkiEkEZxogtOucoqFBeGqsEsQ+hpcB07YWq5JbgH9PjrT/POAZH2Bugr1oR/ra+5MjpF69aYqtIbZtH3VsQW1SXNEJWiGbIDPp988AqU2tGCUTeZVJLhkLpnrlUYn3vqsvwUO/9ZNBQsylQ1hfTU4EfmcIZEOQL1CYIV1mk5iiTNwO8/wVk+bd9uHoVgDMYZiWtwboR7sLdCUsxd/Mbo4O+PxnHpJsH1ehuv8ArKZbsTAE+ARciJ/Z0TgG1h2WaYpgSpu7Wb6oVdoGr5mNOm7rwwuNTgEYNxQ== aaqaishtyaq@gmail.com" ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    neofetch
    docker-compose
  ];

  # programs.zsh = {
  #   enable = true;
  #   syntaxHighlighting.enable = true;
  #   interactiveShellInit = ''
  #     source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
  #   '';
  #   promptInit = ""; # otherwise it'll override the grml prompt
  # };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Enable the X11 windowing system.
  # services.xserver = {
  #   enable = true;
  #   displayManager.lightdm.enable = true;
  #   desktopManager.xfce.enable = true;
  #   windowManager.i3.enable = true;
  #   videoDrivers = [ "fbdev" ];
  # };
  services.xserver.videoDrivers = [ "fbdev" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
  '';

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

