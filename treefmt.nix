# Unified linting/formatting,
# wired into both `nix fmt` and `nix flake check`.
{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true; # formatter
        deadnix.enable = true; # dead code
        statix.enable = true; # anti-patterns

        yamlfmt = {
          enable = true; # the CI workflow
          # Otherwise it strips the blank lines between blocks.
          settings.formatter.retain_line_breaks_single = true;
        };
      };
    };
  };
}
