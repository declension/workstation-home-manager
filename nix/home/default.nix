{username, ...}: {
  imports = [
    ./packages.nix
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

    # Replaces the hand-rolled `export PATH=...` in templates/zshrc.in,
    # and the `~/.local/bin` mkdir in roles/workstation/tasks/main.yml.
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];

    sessionVariables = {
      EDITOR = "vim";
      # Carried over from templates/zshrc.in (ccache for C/Android work).
      USE_CCACHE = "1";
    };
  };

  programs.home-manager.enable = true;

  # Makes fonts in ~/.nix-profile (the Meslo Nerd Font) visible to fontconfig,
  # replacing the ttf-meslo-nerd-font-powerlevel10k pacman package.
  fonts.fontconfig.enable = true;
}
