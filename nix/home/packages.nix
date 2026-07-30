# CLI-only by design.
#
# Two things deliberately don't live here:
#
#   - Language toolchains (JDK, node, rust, GHC, python).
#     These belong in a per-project `flake.nix` devShell,
#     picked up automatically by direnv — see zsh.nix.
#
#   - GUI applications.
#     On non-NixOS these hit OpenGL, xdg-portal and font-integration friction,
#     so they come from pacman instead — see the README.
#     Their *config* is still managed here where home-manager supports it.
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Core CLI
    git-lfs
    vim
    curl
    httpie
    jq
    pass
    gnupg # `pass` is useless without it

    # Modern replacements for the old coreutils-adjacent set
    eza # was `tree`, and ls
    fd
    ripgrep
    ripgrep-all # ripgrep over pdfs/archives/etc
    bat
    btop # was `htop`

    # Networking
    nmap
    openvpn # CLI only; the NetworkManager plugin is a pacman package

    # Jokes
    cowsay
    lolcat
    figlet

    # I18n
    gettext

    # Ops tooling
    yamllint
    kubectl
    yq-go
    opentofu

    # Docs
    pandoc

    # Containers — CLI only, the daemon is system-level (see README)
    docker-client
    docker-compose

    # Fonts.
    # Kept in Nix even though the terminal is a pacman package:
    # fonts.fontconfig.enable makes these visible to fontconfig system-wide.
    nerd-fonts.meslo-lg
  ];
}
