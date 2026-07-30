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

      # The Ansible tree is retained for comparison only — don't reformat it.
      settings.global.excludes = [
        "playbook.yml"
        "requirements.yml"
        "group_vars/**"
        "roles/**"
        "templates/**"
        ".circleci/**"
        "Dockerfile"
        "Dockerfile.manjaro"
        ".idea/**"
        "LICENSE"
        "*.lock"
      ];
    };
  };
}
