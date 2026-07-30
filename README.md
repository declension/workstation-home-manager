Workstation Setup
=================

My workstation as a Nix [home-manager](https://nix-community.github.io/home-manager/) configuration,
built with [flake-parts](https://flake.parts/).

Target: **Arch / EndeavourOS**, standalone home-manager (no NixOS).

> **Migration in progress.**
> The original Ansible playbook is still present in this repo
> (`playbook.yml`, `roles/`, `group_vars/`, `templates/`)
> so the two can be compared.
> It is **not** wired into anything,
> and will be deleted once the Nix config is signed off.
> See [Migration notes](#migration-notes).


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
    zsh.nix                   zsh + oh-my-zsh + starship
    tmux.nix                  tmux + plugins
    git.nix                   git + LFS
    terminal.nix              alacritty
    desktop.nix               dconf / GNOME keybindings
```

flake-parts handles the flake-level plumbing:
per-system `pkgs`, devShells, treefmt, and the `homeConfigurations` output.
The files under `nix/home/` are plain home-manager modules —
wrapping those in flake-parts would buy nothing.


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

Note that `nix flake check` only shallow-checks `homeConfigurations`,
because it isn't a standard flake output.
To actually typecheck the home config, build it:

```shell
nix build .#homeConfigurations.nick.activationPackage
```

### Update inputs
```shell
nix flake update
```


System bootstrap (not managed by Nix)
-------------------------------------

Home-manager configures a *user*.
The bits below need root and stay with the distro,
so run them once per machine.
This split is deliberate:
a half-working automation of privileged setup
is worse than a documented checklist.

```shell
# Docker daemon + group membership (replaces geerlingguy.docker)
sudo pacman -S --needed docker docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"

# VirtualBox needs kernel modules matching your running kernel
sudo pacman -S --needed virtualbox virtualbox-host-modules-arch
sudo usermod -aG vboxusers "$USER"

# Make zsh the login shell (replaces the `user:` task in roles/configure)
chsh -s /usr/bin/zsh

# adm group, for reading logs
sudo usermod -aG adm "$USER"

# Raise inotify watchers (replaces the broken `echo ... >>>` task)
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-watches.conf
sudo sysctl --system

# OpenVPN NetworkManager GUI integration, if you want it in the applet
sudo pacman -S --needed networkmanager-openvpn
```

Log out and back in for the group changes to take effect.


Migration notes
---------------

### Things that got simpler
| Ansible | Now |
| --- | --- |
| `nover.ohmyzsh` role + `templates/zshrc.in` | `programs.zsh.oh-my-zsh` |
| `nephelaiio.tmux` role + tpm git-clone tasks + `templates/tmux.conf` | `programs.tmux.plugins` (no tpm at all) |
| `hurricanehrndz.rustup` building alacritty/ripgrep/starship from source | prebuilt from nixpkgs |
| `gsettings set` shell-outs guarded by a `stat` check | `dconf.settings` |
| terraform 1.1.9 zip downloaded to `~/.local/bin` | `pkgs.opentofu` |
| `get.haskellstack.org` install script | `pkgs.stack` + `pkgs.ghc` |
| Ubuntu apt keys/repos for yarn, k8s, Signal | irrelevant — nixpkgs |

### Deliberate behaviour changes
- **Ubuntu/Debian support dropped.**
  `roles/workstation/tasks/ubuntu.yml`, and everything tagged `ubuntu`,
  is not carried over, per the Arch/EndeavourOS target.
  That also drops the build-dep packages (`libssl-dev`, `libfreetype6-dev`, …),
  which only existed to compile Alacritty from source.
- **`export TERM="xterm-256color"` dropped.**
  Setting `TERM` from `.zshrc` overrides what the terminal actually advertises,
  and loses Alacritty's capabilities.
  Removed rather than ported.
- **`export PATH=...` dropped** in favour of `home.sessionPath`.
  The old line hardcoded a full path,
  and had already needed one fix (`c4239b2`).
- **`. ~/.profile` dropped** — home-manager owns session variables now.
- **Node 16 → 22.**
  `nodejs-lts-gallium` has been EOL for a long time.
- **terraform → opentofu.**
  Also matches what I use at work.
- **`git lfs install` now actually happens**, via `programs.git.lfs.enable`.
  The playbook installed the package but never registered the filters.
- **`powerline` dropped.**
  It only themed the tmux status bar, which `set -g status off` disables anyway,
  and starship already owns the prompt.
- **`update-alternatives` for x-terminal-emulator dropped** — Debian-only.
- **tmux `escape-time`.**
  The original `set -s escape 1` was not a valid option name,
  so it silently did nothing.
  Now `escapeTime = 10`.
- **tmux `bind \ kill-session` fixed.**
  The backslash was unescaped, so it bound the wrong key.

### Scope: parity, not modernisation
This port aims to reproduce what the playbook actually did **on Arch**,
so that the two can be compared like for like.
Modernisation comes after.

The clearest consequence:
`poetry` and `awscli` are **not** here.
They were installed only by `ubuntu.yml`,
and `manjaro.yml` left them as `# TODO: Poetry + AWSCLI`,
so on the Arch target they were never actually installed.
No `uv` either — per-project flakes are the better answer for that.

### Modernisation backlog
Deliberately *not* done in this pass:

- **Global language toolchains are the obvious next thing to cut.**
  `jdk17`, `nodejs_22`, `rustup`, `stack`, `ghc` and `python3`
  are all here purely for parity with the playbook.
  A per-project `flake.nix` with a `devShell`
  is a better home for every one of them.
- **Revisit the package list from scratch.**
  It's years old;
  some of it is certainly no longer wanted.

### Verified
`nix build .#homeConfigurations.nick.activationPackage` succeeds,
so every package attribute, tmux plugin and home-manager option here
resolves against the pinned inputs.

### Known gaps
- **Alacritty + OpenGL on non-NixOS.**
  A Nix-built Alacritty may not find the system GL drivers.
  If it won't start,
  either wrap it with [nixGL](https://github.com/nix-community/nixGL),
  or install `alacritty` from pacman and drop it from `packages.nix`,
  keeping the config in `terminal.nix`.
- **`dconf` settings are GNOME-only.**
  On Xfce use `xfconf-query`; on KDE, `kwriteconfig5`.
  Neither has a first-class home-manager module.
- **Two tmux plugins not carried over.**
  I could not find a nixpkgs `tmuxPlugins` attribute
  for `seebi/tmux-colors-solarized` or `nhdaly/tmux-scroll-copy-mode`.
  Add them with `pkgs.tmuxPlugins.mkTmuxPlugin` if you want them back.
- **`rustup` is still imperative** — it writes to `~/.rustup`.
  Kept to match the old behaviour;
  [fenix](https://github.com/nix-community/fenix)
  or [rust-overlay](https://github.com/oxalica/rust-overlay)
  would make the toolchain declarative.
- **`stack` + `ghc` together.**
  Stack normally manages its own GHC,
  so with the nixpkgs one you'll want `--system-ghc`
  (or `system-ghc: true` in `~/.stack/config.yaml`).
- **CI.**
  `.circleci/config.yml` still builds the two Ansible Dockerfiles.
  A GitHub Actions job running `nix flake check` would be the replacement,
  but isn't done yet.
