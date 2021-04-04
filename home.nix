{ config, pkgs, ... }:

let
  firstName = "Aaqa";
  lastName = "Ishtyaq";
  personalEmail = "aaqaishtyaq@gmail.com";

  # Set OSes
  isLinux = builtins.currentSystem == "x86_64-linux";
  isDarwin = builtins.currentSystem == "x86_64-darwin";
  onCloud = builtins.getEnv "USER" == "ubuntu";

in {
  imports = [
    ./modules
  ];

  nixpkgs.config = { allowUnfree = true; };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = if isDarwin then
      "${firstName}${lastName}"
    else
      (if onCloud then "ubuntu" else firstName);

    homeDirectory = if isDarwin then
      "/Users/${firstName}${lastName}"
    else
      (if onCloud then "/home/ubuntu" else "/home/${firstName}");

    sessionVariables = {
      EDITOR = "vim";
      HISTCONTROL = "ignoreboth";
      PAGER = "less";
      LESS = "-iR";
    };

    packages = with pkgs; [
      curl
      diffutils
      htop
      jq
      less
      lsof
      rsync
      shellcheck
      unzip
      vim
      wget
      zip
    ];

    stateVersion = "21.05";
  };

  programs.git = {
    enable = true;
    userName = "Aaqa Ishtyaq";
    userEmail = "aaqaishtyaq@gmail.com";
  };
}
