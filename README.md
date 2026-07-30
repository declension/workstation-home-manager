Workstation Setup
=================

[![Check](https://github.com/declension/workstation-home-manager/actions/workflows/check.yml/badge.svg)](https://github.com/declension/workstation-home-manager/actions/workflows/check.yml)

My workstation as a Nix [home-manager](https://nix-community.github.io/home-manager/) configuration,
built with [flake-parts](https://flake.parts/).

Target: **Arch / EndeavourOS**, standalone home-manager (no NixOS).


Layout
------

```
flake.nix                     inputs + mkFlake, imports the spokes below
treefmt.nix                   linting/formatting for `nix fmt` + `nix flake check`
nix/
  shells.nix                  devShells.default
  home-configurations.nix     wires homeConfigurations.nick -> nix/home
  home/
    default.nix               home.* basics, imports the rest
    packages.nix              home.packages
    shell-tools.nix           direnv, fzf, zoxide, eza, btop, lazygit
    zsh.nix                   zsh + oh-my-zsh + starship
    tmux.nix                  tmux + plugins
    git.nix                   git + LFS + delta
    terminal.nix              alacritty config
    desktop.nix               dconf / GNOME keybindings
```

flake-parts handles the flake-level plumbing:
per-system `pkgs`, devShells, treefmt, and the `homeConfigurations` output.
The files under `nix/home/` are plain home-manager modules —
wrapping those in flake-parts would buy nothing.


What Nix owns, and what it doesn't
----------------------------------

The split is pragmatic rather than dogmatic.

**home-manager owns** the shell, terminal config, CLI tooling, dotfiles and fonts.

**pacman owns** anything needing root, kernel modules or direct GPU access.
That means the Docker daemon, VirtualBox, and the GUI applications —
Nix-built GUI apps on non-NixOS hit OpenGL, xdg-portal and font-integration
friction that isn't worth fighting.
Where home-manager can still manage an app's *config* without installing it,
it does: see `terminal.nix`.

**Per-project flakes own** language toolchains.
There's no global JDK, node, rust, GHC or python here on purpose.
`direnv` + `nix-direnv` load a project's devShell on `cd`,
which is a better answer than a system-wide version of anything.


Usage
-----

### One-time: install Nix
```shell
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
```

### Apply the configuration
```shell
nix run github:nix-community/home-manager -- switch --flake .#nick
```

After the first switch, `home-manager` is on `$PATH`:

```shell
home-manager switch --flake .#nick
```

### Develop
```shell
nix develop          # or just `cd` in, with direnv
nix fmt              # apply formatting
nix flake check      # validate formatting + evaluate the config
```

`nix flake check` only shallow-checks `homeConfigurations`,
because it isn't a standard flake output.
To actually typecheck the home config, build it:

```shell
nix build .#homeConfigurations.nick.activationPackage
```

CI runs both, on every push and PR.

### Update inputs
```shell
nix flake update
```


System bootstrap
----------------

Run once per machine.
This is deliberately a checklist rather than automation:
a half-working automation of privileged setup is worse than documentation.

```shell
# GUI applications and the terminal
sudo pacman -S --needed alacritty signal-desktop slack-desktop gimp mpv

# Docker daemon + group membership
sudo pacman -S --needed docker docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"

# VirtualBox needs kernel modules matching your running kernel
sudo pacman -S --needed virtualbox virtualbox-host-modules-arch
sudo usermod -aG vboxusers "$USER"

# Make zsh the login shell
chsh -s /usr/bin/zsh

# adm group, for reading logs
sudo usermod -aG adm "$USER"

# Raise inotify watchers
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-watches.conf
sudo sysctl --system

# OpenVPN NetworkManager GUI integration, if you want it in the applet
sudo pacman -S --needed networkmanager-openvpn
```

Log out and back in for the group changes to take effect.

Note `slack-desktop` is in the AUR,
so it needs an AUR helper (`yay -S slack-desktop`) rather than plain pacman.


Known gaps
----------

- **`dconf` settings are GNOME-only.**
  On Xfce use `xfconf-query`; on KDE, `kwriteconfig5`.
  Neither has a first-class home-manager module.
- **Two tmux plugins are missing.**
  `seebi/tmux-colors-solarized` and `nhdaly/tmux-scroll-copy-mode`
  don't appear to have nixpkgs `tmuxPlugins` attributes.
  Add them with `pkgs.tmuxPlugins.mkTmuxPlugin` if you want them.
- **Single host.**
  `homeConfigurations` has one entry, hardcoded to `nick` on `x86_64-linux`.
  Worth generalising if this ever needs to cover a second machine.
- **Nothing here has been run on a real desktop yet.**
  CI proves it evaluates and builds;
  it can't prove Alacritty renders or that the dconf keys land.
