# Alacritty itself comes from pacman:
# a Nix-built one on non-NixOS has to find the system's OpenGL drivers,
# which means wrapping it in nixGL.
# Using the distro package sidesteps that entirely.
#
# `package = null` tells home-manager to write the config
# without also installing the binary.
#
# The font comes from nerd-fonts.meslo-lg in packages.nix,
# which fontconfig picks up via fonts.fontconfig.enable.
{
  programs.alacritty = {
    enable = true;
    package = null;

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
