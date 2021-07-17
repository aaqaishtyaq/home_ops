{ config, lib, pkgs, ... }:

with lib;

let cfg = config.aaqaishtyaq.starship;
in {
  options.aaqaishtyaq.starship = {
    enable = mkEnableOption "Enable the Starship prompt";
  };
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
