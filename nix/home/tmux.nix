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
      set  -g  status off
      setw -g  pane-base-index 1

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
