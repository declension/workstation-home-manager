{pkgs, ...}: {
  home.packages = with pkgs; [
    # Core CLI
    git-lfs
    vim
    curl
    httpie
    jq
    htop
    tree
    multitail
    pass
    gnupg # `pass` is useless without it

    # Networking
    nettools
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

    # Languages & toolchains
    jdk17
    nodejs_22
    python3
    rustup
    stack
    ghc

    # Terminal tooling
    ripgrep
    bat

    # Containers — CLI only, the daemon is system-level (see README)
    docker-client
    docker-compose

    # Desktop apps
    gimp
    pandoc
    mplayer
    signal-desktop
    slack

    # Fonts
    nerd-fonts.meslo-lg
  ];
}
