# Alacritty itself comes from pacman.
# A Nix-built Alacritty on non-NixOS has to find the system's OpenGL drivers,
# which means wrapping it in nixGL;
# using the distro package sidesteps that entirely.
#
# The *config* is still managed here — `package = null` tells home-manager to
# write ~/.config/alacritty/alacritty.toml without installing the binary.
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
