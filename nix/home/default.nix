{username, ...}: {
  imports = [
    ./packages.nix
    ./shell-tools.nix
    ./zsh.nix
    ./prompt.nix
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

    # For things installed outside Nix.
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];

    sessionVariables = {
      EDITOR = "vim";
      USE_CCACHE = "1"; # ccache, for C/Android work
    };
  };

  programs.home-manager.enable = true;

  # Makes fonts installed here visible to fontconfig —
  # including to the pacman-installed Alacritty.
  fonts.fontconfig.enable = true;
}
