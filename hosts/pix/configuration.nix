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
  tailscaleAuthKey = secrets.tsAuthKey;
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

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "lxd" ]; # Enable ‘sudo’ for the user.
      home = "/home/${user}";
      description = "Aaqa Ishtyaq";
      password = password;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYZjYRGgzYBn6PhTnn4LmQ/AsF5E7RVe10zYYsVQz/w aaqaishtyaq@gmail.com" ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    docker-compose

    # network
    tailscale
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

  # enable the tailscale service
  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey ${tailscaleAuthKey}
    '';
  };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

  services.samba = {
    enable = true;
    securityType = "user";

    shares = {
      public = {
        path = "/media/aaqa/sandisk/Downloads/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "aaqa";
        "force group" = "users";
        "valid users" = "aaqa";
      };

      private = {
        path = "/media/aaqa/sandisk/Downloads/Private";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "aaqa";
        "force group" = "users";
        "valid users" = "aaqa";
      };
    };
  };

 networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [
      config.services.tailscale.port
      137
      138
    ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [
      22
      445
      139
      5357
    ];
  };

  # mDNS
  #
  # This makes connecting from a local Mac possible.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };
  system.stateVersion = "23.05"; # Did you read the comment?
}

