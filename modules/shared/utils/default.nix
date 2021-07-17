{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    coreutils
    curl
    diffutils
    fzf
    htop
    jq
    less
    lsof
    nix-zsh-completions
    ripgrep
    rsync
    shellcheck
    skim
    socat
    tmux
    tree
    unzip
    vim
    watch
    wget
    zip
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Aaqa Ishtyaq";
    userEmail = "aaqaishtyaq@gmail.com";
  };
}
