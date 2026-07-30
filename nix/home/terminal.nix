# Alacritty came from `cargo install` via hurricanehrndz.rustup before,
# with no config at all —
# only an `update-alternatives` call to make it the default x-terminal-emulator.
# That call was Debian-only, and is dropped here.
#
# NOTE: on Arch (non-NixOS),
# a Nix-built Alacritty has to find the system's OpenGL/driver libraries.
# If it fails to start, see the README:
# installing `alacritty` from pacman and keeping just this config
# is the simplest fix.
{
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        normal.family = "MesloLGS Nerd Font";
        size = 11.0;
      };
      window.opacity = 0.95;
      scrolling.history = 50000;
    };
  };
}
