# Replaces templates/zshrc.in, plus the nover.ohmyzsh Galaxy role.
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
        "terraform" # still gives `tf`/`tfp` aliases, now against opentofu
        "stack"
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

  # Stands in for the oh-my-zsh `command-not-found` plugin,
  # which relied on Arch's pkgfile hooks
  # and wouldn't see anything installed via Nix.
  programs.nix-index.enable = true;
}
