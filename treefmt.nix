# Unified linting/formatting,
# wired into both `nix fmt` and `nix flake check`.
{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };

      # The Ansible tree is kept only for side-by-side comparison
      # during the migration.
      # Don't reformat it — that would add noise to the diff.
      # Delete these excludes (and the files) once the migration is signed off.
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
