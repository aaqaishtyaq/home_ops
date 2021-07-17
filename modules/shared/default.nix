{ config, pkgs, ... }: {
  imports = [
    ./home-manager
    ./neovim
    ./starship
    ./tmux
    ./utils
    ./zsh
  ];

  aaqaishtyaq = {
    starship.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
