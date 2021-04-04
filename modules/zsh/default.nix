{config, lib, pkgs, ...}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    history = {
      path = ".config/zsh/.zsh_history";
      size = 50000;
      save = 50000;
    };
  };
}
