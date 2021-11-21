{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  nixBin = writeShellScriptBin "nix" ''
    exec ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
  '';

in mkShell {
  buildInputs = [
    git
  ];
  shellHook = ''
    export FLAKE="$(pwd)"
    export PATH="$FLAKE/bin:${nixBin}/bin:$PATH"
    # HOME_MANAGER_CONFIG=$PWD/modules/common/home-manager/default.nix
  '';
}
