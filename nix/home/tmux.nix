# Plugins are wired in by home-manager,
# so there's no tpm and no ~/.tmux/plugins to keep in sync.
{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;

    # Low, but not so low that ESC-prefixed sequences break over a laggy link.
    escapeTime = 10;

    # Needed for the 24-bit colours the status line and starship use.
    # tmux-sensible leaves an explicitly-set default-terminal alone.
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
      copycat
      yank
      better-mouse-mode
    ];
    # `seebi/tmux-colors-solarized` and `nhdaly/tmux-scroll-copy-mode` are
    # absent: neither appears to have a nixpkgs `tmuxPlugins` attribute.
    # Add them with `pkgs.tmuxPlugins.mkTmuxPlugin` if you want them.

    extraConfig = ''
      setw -g  pane-base-index 1

      set -as terminal-features ",*:RGB"

      # ---- Status line ----------------------------------------------------
      # Deliberately not tmux-powerline: that runs a tree of shell scripts on
      # every redraw. Everything here is a native tmux format string, so a
      # redraw costs nothing and the only reason for an interval is the clock.
      #
      # Mostly unfilled, like the prompt in prompt.nix — but the *active*
      # window is one real powerline segment, filled with arrow caps. It's the
      # only fill on the bar, which is what makes it read as "you are here"
      # rather than as a row of blocks.
      #
      # `bg=default` everywhere else, rather than a literal colour, so the bar
      # inherits the terminal's own background — including its translucency.
      # That is also why the arrow caps work: they are the accent colour on
      # whatever happens to be behind the bar.
      set -g status on
      set -g status-position bottom
      set -g status-interval 5
      set -g status-justify left
      set -g status-style "fg=#8894ab,bg=default"
      set -g status-left-length 40
      set -g status-right-length 60

      set -g status-left "#[fg=#88c0d0,bold] #S#[fg=#5b6b8a,nobold]  "

      # Two spaces, not a chevron: the active segment's caps already divide
      # things, and a chevron on top of them reads as clutter.
      set -g window-status-separator "  "
      set -g window-status-format "#[fg=#5b6b8a]#I #[fg=#8894ab]#W#[fg=#ebcb8b]#{?window_zoomed_flag, ,}"
      set -g window-status-current-format "#[fg=#81a1c1,bg=default]#[fg=#2e3440,bg=#81a1c1,bold] #I #W#{?window_zoomed_flag, ,} #[fg=#81a1c1,bg=default,nobold]"

      # The prefix indicator earns its keep with a two-key prefix like C-a.
      set -g status-right "#{?client_prefix,#[fg=#ebcb8b]● ,}#[fg=#8894ab] %H:%M#[fg=#5b6b8a]  #[fg=#88c0d0] #h "

      # An inactive window that wants attention gets colour, not a fill.
      setw -g monitor-activity on
      set -g window-status-activity-style "fg=#ebcb8b,bg=default,nobold"
      set -g window-status-bell-style "fg=#bf616a,bg=default,bold"

      set -g pane-border-style "fg=#3b4252"
      set -g pane-active-border-style "fg=#4c566a"
      set -g message-style "fg=#ebcb8b,bg=default,bold"
      set -g mode-style "fg=#2e3440,bg=#88c0d0"
      # ---------------------------------------------------------------------

      # Splits that match vim, opening in the current pane's directory
      bind - split-window -c "#{pane_current_path}"
      bind / split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind = select-layout even-vertical

      bind '\' kill-session
      bind x confirm kill-pane
      bind C-s set-window-option synchronize-panes

      # Bring back clear-screen under the prefix
      bind C-l send-keys 'C-l'
    '';
  };
}
