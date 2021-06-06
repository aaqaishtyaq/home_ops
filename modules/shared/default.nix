{ config, pkgs, ... }: {
  imports = [
    ./home-manager
    ./neovim
    ./tmux
    ./utils
    ./zsh
  ];

  aaqaishtyaq = {
    tmux.enable = true;
  };
}
