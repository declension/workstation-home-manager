# Interactive shell tooling that home-manager can wire into zsh itself,
# rather than us hand-rolling `eval "$(... init)"` lines.
{
  # The enabler for keeping language toolchains out of the global profile:
  # `cd` into a project with an .envrc and its devShell loads automatically.
  # nix-direnv adds caching, so that isn't painfully slow.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.btop.enable = true;
  programs.lazygit.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  # Set explicitly rather than relying on the eza module's own alias option,
  # whose name has changed across home-manager releases.
  programs.zsh.shellAliases = {
    ls = "eza";
    ll = "eza --long --group";
    la = "eza --long --group --all";
    tree = "eza --tree";
  };
}
