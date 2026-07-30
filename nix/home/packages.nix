# Grouped to mirror roles/workstation/tasks/{main,manjaro}.yml
# so the two trees can be read side by side.
#
# Not included, because the Arch path never had them:
# poetry and awscli were installed only in ubuntu.yml,
# and manjaro.yml left them as `# TODO: Poetry + AWSCLI`.
# Adding either is a modernisation decision, not a parity one.
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
    gnupg # `pass` is useless without it; was implicit on Arch before

    # Networking
    nettools
    nmap
    openvpn # CLI only - see README for the NetworkManager plugin

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
    opentofu # replaces the pinned terraform 1.1.9 tarball

    # Languages & toolchains
    jdk17
    nodejs_22 # was nodejs-lts-gallium (16), long since EOL
    python3
    rustup
    stack
    ghc

    # Terminal tooling (previously built from source by cargo)
    ripgrep
    bat

    # Containers - CLI only, the daemon is system-level (see README)
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
