{ config, pkgs, ... }: {
  imports = [
    ./home-manager/default.nix
    ./neovim/default.nix
    ./starship/default.nix
    ./tmux/default.nix
    ./utils/default.nix
    ./zsh/default.nix
  ];

  aaqaishtyaq = {
    starship.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
