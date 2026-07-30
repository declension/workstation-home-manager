{username, ...}: {
  imports = [
    ./packages.nix
    ./shell-tools.nix
    ./zsh.nix
    ./tmux.nix
    ./git.nix
    ./terminal.nix
    ./desktop.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # Deliberately conservative:
    # bump only when you've read the release notes for the versions in between.
    stateVersion = "25.05";

    # Supersedes the playbook's hand-rolled `export PATH=...`
    # and its `~/.local/bin` mkdir task.
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];

    sessionVariables = {
      EDITOR = "vim";
      # Carried over from the old zshrc (ccache for C/Android work).
      USE_CCACHE = "1";
    };
  };

  programs.home-manager.enable = true;

  # Makes fonts in ~/.nix-profile (the Meslo Nerd Font) visible to fontconfig
  # system-wide — including to the pacman-installed Alacritty.
  fonts.fontconfig.enable = true;
}
