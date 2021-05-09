{ config, lib, pkgs, ... }:

with lib;

let cfg = config.aaqaishtyaq.tmux;
in {
  options.aaqaishtyaq.tmux = {
    enable = mkEnableOption "set up tmux";
    shortcut = mkOption {
      type = types.str;
      description = "The tmux prefix key, default is C-b";
      default = "b";
      example = "a";
    };
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      shortcut = cfg.shortcut;
      baseIndex = 1; # Widows numbers begin with 1
      customPaneNavigationAndResize = true;
      aggressiveResize = true;
      historyLimit = 100000;
      resizeAmount = 5;
      escapeTime = 0;
      newSession = true;

      extraConfig = ''
        # Fix environment variables
        set-option -g update-environment "SSH_AUTH_SOCK \
                                          SSH_CONNECTION \
                                          DISPLAY"
        # Mouse works as expected
        set-option -g mouse on
        # Use default shell
        set-option -g default-shell ''${SHELL}

        # default statusbar color
        set-option -g status-style bg=colour237,fg=colour223 # bg=bg1, fg=fg1

        # default window title colors
        set-window-option -g window-status-style bg=colour214,fg=colour237 # bg=yellow, fg=bg1

        # default window with an activity alert
        set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3

        # active window title colors
        set-window-option -g window-status-current-style bg=red,fg=colour237 # fg=bg1

        # pane border
        set-option -g pane-active-border-style fg=colour250 #fg2
        set-option -g pane-border-style fg=colour237 #bg1

        # message infos
        set-option -g message-style bg=colour239,fg=colour223 # bg=bg2, fg=fg1

        # writing commands inactive
        set-option -g message-command-style bg=colour239,fg=colour223 # bg=fg3, fg=bg1

        # pane number display
        set-option -g display-panes-active-colour colour250 #fg2
        set-option -g display-panes-colour colour237 #bg1

        # clock
        set-window-option -g clock-mode-colour colour109 #blue

        # bell
        set-window-option -g window-status-bell-style bg=colour167,fg=colour235 # bg=red, fg=bg
      '';
    };
  };
}
