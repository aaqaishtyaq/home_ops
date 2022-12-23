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
      terminal = "xterm-256color";
      shell = "zsh";
      extraConfig = ''
        # Fix environment variables
        set-option -g update-environment "SSH_AUTH_SOCK \
                                          SSH_CONNECTION \
                                          DISPLAY"
        # Configuration
        setw -g automatic-rename off
        setw -g aggressive-resize on

        set -g default-terminal "xterm-256color"
        set -g history-limit 10000
        set -g mouse on
        set-window-option -g xterm-keys on

        # Start index of window/pane with 1, because we're humans, not computers
        set -g base-index 1
        setw -g pane-base-index 1

        # Reload tmux configuration
        bind C-r source-file ~/.tmux.conf \; display "Config reloaded"

        # new window and retain cwd
        bind c new-window -c "#{pane_current_path}"

        # Rename session and window
        bind r command-prompt -I "#{window_name}" "rename-window '%%'"
        bind R command-prompt -I "#{session_name}" "rename-session '%%'"

        # Split panes
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Zoom pane
        bind z resize-pane -Z

        # Kill pane/window/session shortcuts
        bind x kill-pane
        bind X kill-window

        # Detach from session
        bind d detach
        bind D if -F '#{session_many_attached}' \
            'confirm-before -p "Detach other clients? (y/n)" "detach -a"' \
            'display "Session has only 1 client attached"'

        # Hide status bar on demand
        bind C-s if -F '#{s/off//:status}' 'set status off' 'set status on'

        # Activity bell and whistles
        set -g visual-activity on

        # Appearance and Theme

        color_black="colour232"
        color_white="colour15"
        color_blue="colour4"
        color_green="colour076"
        color_yellow="colour215"
        color_orange="colour166"
        color_red="colour160"
        color_gray="colour252"

        color_dark="$color_black"
        color_light="$color_white"
        color_session_text="$color_blue"
        color_status_text="colour245"
        color_main="$color_blue"

        color_window_off_indicator="colour088"
        color_window_off_status_bg="colour236"
        color_window_off_status_current_bg="colour254"

        wg_session="#[fg=$color_session_text, bold] #S #[default]"
        wg_date="#[fg=$color_light]%H:%M#[default] | #[fg=$color_light]%A, %d %B %Y#[default]"
        wg_is_zoomed="#[fg=$color_dark,bg=$color_orange]#{?window_zoomed_flag,[Z],}#[default] "
        wg_is_keys_off="#[fg=$color_light,bg=$color_window_off_indicator]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'OFF')#[default]"

        set -g status on
        set -g status-position bottom
        set -g status-justify left
        set -g status-left-length 20
        set -g status-right-length 100
        set -g status-style "fg=$color_status_text"
        set -g window-status-format " #I:#W "
        set -g window-status-separator ""
        set -g window-status-current-format "#[fg=$color_light,bg=$color_main,bold] #I:#W #[fg=$color_main,bg=$color_dark]#[default]"
        set -g window-status-activity-style "fg=$color_main"

        set -g mode-style "fg=$color_dark,bg=$color_light"
        set -g message-style "fg=$color_main,bg=$color_dark"
        set -g pane-active-border-style "fg=$color_main"

        set -g status-left "$wg_session"
        set -g status-right "#{prefix_highlight} $wg_is_keys_off $wg_is_zoomed $wg_date"

        set -g base-index 1
        setw -g pane-base-index 1

        # Nesting local and remote sessions

        bind -T root F12  \
            set prefix None \;\
            set key-table off \;\
            set status-style "fg=$color_status_text,bg=$color_window_off_status_bg" \;\
            set window-status-current-format "#[fg=$color_window_off_status_bg,bg=$color_window_off_status_current_bg]#[default] #I:#W #[fg=$color_window_off_status_current_bg,bg=$color_window_off_status_bg]#[default]" \;\
            set window-status-current-style "fg=$color_dark,bold,bg=$color_window_off_status_current_bg" \;\
            if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
            refresh-client -S \;\

        bind -T off F12 \
          set -u prefix \;\
          set -u key-table \;\
          set -u status-style \;\
          set -u window-status-current-style \;\
          set -u window-status-current-format \;\
          refresh-client -S

        # Edit configuration and reload
        bind C-e new-window -n 'tmux.conf' "sh -c '\${EDITOR:-vim} ~/.tmux.conf && tmux source ~/.tmux.conf && tmux display \"Config reloaded\"'"

        # Reload tmux configuration
        bind C-r source-file ~/.tmux.conf \; display "Config reloaded"

        # new window and retain cwd
        bind c new-window -c "#{pane_current_path}"

        # Prompt to rename window right after it's created
        #  set-hook -g after-new-window 'command-prompt -I "#{window_name}" "rename-window '%%'"'

        # Rename session and window
        bind r command-prompt -I "#{window_name}" "rename-window '%%'"
        bind R command-prompt -I "#{session_name}" "rename-session '%%'"

        # Split panes
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Select pane and windows
        bind -r C-[ previous-window
        bind -r C-] next-window
        bind -r [ select-pane -t :.-
        bind -r ] select-pane -t :.+
        bind -r Tab last-window   # cycle thru MRU tabs
        bind -r C-o swap-pane -D

        # Resize windows
        bind k resize-pane -U 5
        bind j resize-pane -D 5
        bind h resize-pane -L 5
        bind l resize-pane -R 5

        # Zoom pane
        bind + resize-pane -Z

        # Link window
        bind L command-prompt -p "Link window from (session:window): " "link-window -s %% -a"

        # Kill pane/window/session shortcuts
        bind x kill-pane
        bind X kill-window
        bind C-x confirm-before -p "kill other windows? (y/n)" "kill-window -a"
        bind Q confirm-before -p "kill-session #S? (y/n)" kill-session

        # Merge session with another one (e.g. move all windows)
        # If you use adhoc 1-window sessions, and you want to preserve session upon exit
        # but don't want to create a lot of small unnamed 1-window sessions around
        # move all windows from current session to main named one (dev, work, etc)
        bind C-u command-prompt -p "Session to merge with: " \
          "run-shell 'yes | head -n #{session_windows} | xargs -I {} -n 1 tmux movew -t %%'"

        # Detach from session
        bind d detach
        bind D if -F '#{session_many_attached}' \
            'confirm-before -p "Detach other clients? (y/n)" "detach -a"' \
            'display "Session has only 1 client attached"'

        # Hide status bar on demand
        bind C-s if -F '#{s/off//:status}' 'set status off' 'set status on'
      '';
    };
  };
}
