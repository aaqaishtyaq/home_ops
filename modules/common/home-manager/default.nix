{ config, pkgs, libs, ... }:

let
  firstName = "aaqa";
  lastName = "ishtyaq";
  personalEmail = "aaqaishtyaq@gmail.com";

  isLinux =
  (builtins.currentSystem == "x86_64-linux") ||
  (builtins.currentSystem == "aarch64-linux");

  isDarwin = builtins.currentSystem == "x86_64-darwin";
  onCloud = builtins.getEnv "USER" == "ubuntu";
in {
  programs.home-manager.enable = true;
  # programs.man.enable = false;

  home = {
    # username = (if onCloud then "ubuntu" else firstName);

    # homeDirectory = (if onCloud then "/home/ubuntu" else "/home/${firstName}");

    packages = with pkgs; [
      curl
      diffutils
      htop
      jq
      less
      lsof
      neofetch
      ripgrep
      rsync
      shellcheck
      unzip
      vim
      wget
      zip
    ];

    extraOutputsToInstall = [ "man" ];
    stateVersion = "22.11";
  };

  programs.git = {
    enable = true;
    userName = "Aaqa Ishtyaq";
    userEmail = "aaqaishtyaq@gmail.com";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide.enable = true;
}
