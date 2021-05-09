{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    coreutils
    curl
    fzf
    nix-zsh-completions
    ripgrep
    rsync
    socat
    tmux
    tree
    unzip
    watch
    zsh
  ];


  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.fzf.enable = true;
}
