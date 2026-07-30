{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      extended = true;
      ignoreDups = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";

      # The language-toolchain plugins are just aliases,
      # and come into their own inside a project devShell.
      plugins = [
        "git"
        "git-extras"
        "cp"
        "gnu-utils"
        "history"
        "rsync"
        "ssh-agent"
        "tmux"
        "python"
        "pip"
        "node"
        "npm"
        "docker"
        "httpie"
        "aws"
        "kubectl"
        "terraform" # `tf`/`tfp` aliases, against opentofu
      ];

      # Placed *before* oh-my-zsh.sh is sourced, which is what these need.
      extraConfig = ''
        ZSH_TMUX_AUTOSTART=false
        # The aws plugin's prompt conflicts with starship.
        SHOW_AWS_PROMPT=false
      '';
    };

    initContent = ''
      # It's annoying, IMO
      unsetopt autocd
    '';
  };

  programs.starship.enable = true;

  # command-not-found for Nix packages.
  # Arch's own pkgfile hooks can't see the Nix store.
  programs.nix-index.enable = true;
}
