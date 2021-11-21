{config, lib, pkgs, ...}:

with lib;

let cfg = config.aaqaishtyaq.zsh;
in {
  options.aaqaishtyaq.zsh = {
    enable = mkEnableOption "Enable the Z Shell";
  };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      # dotDir = ".config/zsh.d";
      enableCompletion = true;
      enableAutosuggestions = true;
      history = {
        path = "~/.zsh_history";
        save = 50000;
        ignoreDups = true;
        share = true;
        extended = true;
      };
      autocd = true;
      shellAliases = {
        k = "kubectl";
        kctx = "kubectx";
        kns = "kunens";
        kx = "kubectx";
        ls = "ls --color=auto";
        l = "ls -lah";
        la = "ls -lAh";
        ll = "ls -lh";
        lsa = "ls -lah";
        sl = "ls -al";
        tree = "tree -C";
        chmox = "chmod u+x";
        cl = "clear";
        ctags = "/usr/local/bin/ctags";
        e = "nvim";
        grep = "grep --color=auto";
        ipaddr = "dig +short myip.opendns.com @resolver1.opendns.com";
        ipinfo = "curl ipinfo.io";
        more = "less -R";
        weather = "curl wttr.in";
      };
      sessionVariables = {
        EDITOR = "vim";
        HISTCONTROL = "ignoreboth";
        PAGER = "less";
        LESS = "-iR";
        LANG = "en_US.UTF-8";
        LC_ALL = "C";
        LC_CTYPE = "en_US";
        LC_MESSAGES="en_US";
      };
      initExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
      '';
    };
  };
}
