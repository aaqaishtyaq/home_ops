#!/usr/bin/env bash


# install nix for ubuntu
install_nix() {
  sh <(curl -L https://nixos.org/nix/install) --daemon
}

configure_nix() {
  # switch to nixos-unstable
  nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs

  # configure nix
  mkdir -p ~/.config/nix/
  echo 'max-jobs = auto' >>~/.config/nix/nix.conf

  # install home-manager
  echo "export NIX_PATH=/nix/var/nix/profiles/per-user/$USER/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs:/nix/var/nix/profiles/per-user/root/channels" | sudo tee -a /etc/profile
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
}

# TODO: Make it platform agnostic
# param: pkg => string | array[string]
install_pkg() {
  local pkg="${1}"
  local os_type=$(uname)
  if [[ "${os_type}" == "Linux" ]]; then
    sudo apt install -y "${pkg}"
  elif [[ "${os_type}" == "Darwin" ]]; then
    brew install "${pkg}"
  fi
}

check_and_install() {
  local pkg="${1}"

  # command -v "${pkg}" &>/dev/null && \
  install_pkg "${pkg}"
}

# TODO:
#      1. can i move back home_ops to nix?
#      2. pull aaqaishtyaq/dotfiles repo
clone_repo() {
  local home_ops_repo="aaqaishtyaq/home_ops"
  local config_dir="${HOME}/repos/github.com/${home_ops_repo}"
  check_and_install git rsync
  printf "Cloning ${home_ops_repo} to ${config_dir}"
  mkdir -p "${config_dir}"
  git clone https://github.com/aaqaishtyaq/home_ops.git "${config_dir}"
}

clone_repo
install_nix
configure_nix
