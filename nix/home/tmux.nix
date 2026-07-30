# Replaces templates/tmux.conf, the nephelaiio.tmux Galaxy role,
# and the hand-rolled tpm clone tasks.
# home-manager wires plugins in directly,
# so there is no tpm, no ~/.tmux/plugins,
# and no `git` tasks to keep in sync.
{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;

    # The original `set -s escape 1` was not a valid tmux option name
    # (`escape-time` is), so it silently did nothing.
    # 10ms keeps the intent without the risk 1ms carries over a laggy SSH link.
    escapeTime = 10;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
      copycat
      yank
      better-mouse-mode
    ];
    # Not carried over from templates/tmux.conf:
    #
    #   - seebi/tmux-colors-solarized and nhdaly/tmux-scroll-copy-mode:
    #     I could not find a nixpkgs `tmuxPlugins` attribute for either.
    #     Add them with `pkgs.tmuxPlugins.mkTmuxPlugin` if you want them back.
    #
    #   - the powerline status-bar config:
    #     `status off` below made it dead weight,
    #     and starship already owns the prompt.
    #
    #   - `bind r source-file`:
    #     the config now lives on a read-only store path,
    #     so `home-manager switch` is the reload path.

    extraConfig = ''
      set  -g  status off
      setw -g  pane-base-index 1

      # Splits that match vim, opening in the current pane's directory
      bind - split-window -c "#{pane_current_path}"
      bind / split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind = select-layout even-vertical

      # The original `bind \ kill-session` left the backslash unescaped,
      # so it bound the wrong thing.
      bind '\' kill-session

      bind x confirm kill-pane
      bind C-s set-window-option synchronize-panes

      # Bring back clear-screen under the prefix
      bind C-l send-keys 'C-l'
    '';
  };
}
