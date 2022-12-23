{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.aaqaishtyaq.zsh;
  dotDir = ".config/zsh.d";
in {
  options.aaqaishtyaq.zsh = {
    enable = mkEnableOption "Enable the Z Shell";
  };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      dotDir = "${dotDir}";
      enableCompletion = true;
      enableAutosuggestions = true;
      history = {
        path = "$HOME/${dotDir}/.zsh_history";
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
        nixclean = "nix-collect-garbage -d";
        mnt-drive = "udisksctl mount -b /dev/sda1";
      };
      sessionVariables = {
        EDITOR = "vim";
        HISTCONTROL = "ignoreboth";
        PAGER = "less";
        LESS = "-iR";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LC_CTYPE = "en_US";
        LC_MESSAGES="en_US";
        IAY_CWD_HOME_COLOR="magenta";
        IAY_CWD_ROOT_COLOR="magenta";
      };
      initExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        eval "$(direnv hook zsh)"
        ZSH_AUTOSUGGEST_USE_ASYNC=true

        for file in "$HOME/${dotDir}/"*.zsh; do
          if [[ -r "$file" ]] && [[ -f "$file" ]]; then
            source "$file"
          fi
        done

        if command -v grep &>/dev/null; then
          if [ -r ~/.config/dircolors/dircolors ]; then
            eval "$(dircolors -b ~/.config/dircolors/dircolors)"
          else
            eval "$(dircolors -b)"
          fi
        fi

        if [ ! "$TERM" = dumb ]; then
          autoload -Uz add-zsh-hook
          _iay_prompt() {
            PROMPT="$(iay -zm)"
          }
          add-zsh-hook precmd _iay_prompt
        fi
      '';
    };

    home.file = {
      ".config/zsh.d/completion.zsh".source = ./completion.zsh;
      ".config/zsh.d/bindings.zsh".source = ./bindings.zsh;
      ".config/zsh.d/functions.zsh".source = ./functions.zsh;
      ".config/zsh.d/options.zsh".source = ./options.zsh;
      ".config/dircolors/dircolors".source = ../dircolors/dircolors;
    };
  };
}
