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
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
  nix-shell '<home-manager>' -A install
}

# Install nix experimental feature flakes
install_flake() {
  nix-env -iA nixpkgs.nixFlakes
}

# TODO:
#      1. can i move back home_ops to nix?
#      2. pull aaqaishtyaq/dotfiles repo
clone_repo() {
  local home_ops_repo="aaqaishtyaq/home_ops"
  local config_dir="${HOME}/projects/src/github.com/${home_ops_repo}"
  printf "Cloning ${home_ops_repo} to ${config_dir}"
  mkdir -p "${config_dir}"
  git clone https://github.com/aaqaishtyaq/home_ops.git "${config_dir}"
}

# Install required dependency
install_dependency() {
  sudo apt update \
    && sudo apt install -y \
    git
    rsync
}

add_post_hook() {
  touch /tmp/home_ops.post.lock
}

remove_post_hook() {
  rm /tmp/home_ops.post.lock
}

check_post_repo_lock() {
  local post
  post=0
  if [[ -f /tmp/home_ops.post.lock ]]; then
    post=1
  fi
  printf "$post"
}

run() {
  local post
  post="$1"

  if [[ "${post}" == 1 ]]; then
    configure_nix
    exec bash
    install_flake && remove_post_hook
  else
    install_dependency
    clone_repo
    install_nix && add_post_hook
  fi
}

run $(check_post_repo_lock)
