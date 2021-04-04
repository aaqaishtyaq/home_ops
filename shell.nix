with import <nixpkgs> {};

mkShell {
  buildInputs = [jq];

  shellHook = ''
    HOME_MANAGER_CONFIG=$PWD/home.nix
  '';
}
