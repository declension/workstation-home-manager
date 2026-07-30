# NOTE: on Arch (non-NixOS),
# a Nix-built Alacritty has to find the system's OpenGL/driver libraries.
# If it fails to start, see the README:
# installing `alacritty` from pacman and keeping just this config
# is the simplest fix.
#
# The font comes from nerd-fonts.meslo-lg in packages.nix.
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
