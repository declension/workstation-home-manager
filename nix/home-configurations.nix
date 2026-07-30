# Standalone home-manager:
# on Arch/EndeavourOS there's no NixOS module to hang this off,
# so the config is exposed as a top-level `homeConfigurations` output.
{
  inputs,
  withSystem,
  ...
}: let
  username = "nick";
in {
  flake.homeConfigurations.${username} = withSystem "x86_64-linux" ({pkgs, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./home];
      extraSpecialArgs = {inherit username;};
    });
}
