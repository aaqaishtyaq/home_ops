# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user = "aaqa";
  hostname = "altair";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Kolkata";

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = true;
    users."${user}" = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "lxd" "sudo" ];
      home = "/home/${user}";
      description = "Aaqa Ishtyaq";
      initialHashedPassword = "$y$j9T$5tdjcCUYBZcTTEmO4Dj081$LAr0RbkzDP3Z2jQ7XIQDAgp7JuCA6h7gYmVVBvq6W40";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYZjYRGgzYBn6PhTnn4LmQ/AsF5E7RVe10zYYsVQz/w aaqaishtyaq@gmail.com" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  nixpkgs.config = {
    allowUnfree = true;
  };


  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = true;

  networking.hostName = "${hostname}";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  system.stateVersion = "23.05";
}
