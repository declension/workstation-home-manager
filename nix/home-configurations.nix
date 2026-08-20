# Standalone home-manager:
# on Arch/EndeavourOS there's no NixOS module to hang this off,
# so the config is exposed as a top-level `homeConfigurations` output.
#
# No real username is ever committed here. home-manager already looks for
# `homeConfigurations.$USER` by convention, so building/switching with
# `--impure` picks up whoever is actually running the command.
# `example` is a fixed, non-personal entry that CI builds against instead.
{
  inputs,
  withSystem,
  ...
}: let
  mkHome = username:
    withSystem "x86_64-linux" ({pkgs, ...}:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./home];
        extraSpecialArgs = {inherit username;};
      });

  envUser = builtins.getEnv "USER";
in {
  flake.homeConfigurations =
    {example = mkHome "example";}
    // (
      if envUser == "" || envUser == "example"
      then {}
      else {${envUser} = mkHome envUser;}
    );
}
