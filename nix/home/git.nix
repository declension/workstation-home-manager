# `lfs.enable` registers the smudge/clean filters,
# which installing the git-lfs package alone does not do.
{
  lib,
  username,
  ...
}: let
  # Work accounts are declared via $HM_WORK_USERNAMES (comma-separated),
  # loaded from a local, gitignored `.env` — see `.env.example`.
  # Nothing work-specific is committed here; unset means "treat as personal".
  workUsernames = lib.splitString "," (builtins.getEnv "HM_WORK_USERNAMES");
  isWork = builtins.elem username workUsernames;
in {
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      # Identity follows the account, not the checkout, so a personal repo
      # cloned on a work machine still commits as work.
      # Override those with `git config user.email ...` in the repo.
      settings = {
        alias = {
          # `cleanup` lists; `cleanup-force` deletes.
          # Merged against the default branch, not HEAD: bare `--merged` sweeps up
          # whatever's merged into the current checkout, including itself.
          # `fetch --prune` is load-bearing — a stale ref still looks merged.
          cleanup = ''!f() { t="''${1:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)}"; git fetch --prune --quiet || return 1; git rev-parse --verify --quiet "$t" >/dev/null || { echo "cleanup: no such ref: $t" >&2; return 1; }; git for-each-ref --format='%(refname:lstrip=3)%09%(symref)' --merged "$t" refs/remotes/origin | awk -F'\t' '$2 == "" { print $1 }' | grep -vxE 'main|master|develop|staging|production|release/.*' | grep -vxF "$(git symbolic-ref --quiet --short HEAD || echo)" || true; }; f'';
          cleanup-force = ''!f() { git cleanup "$@" | xargs --no-run-if-empty -n1 git push --delete origin; }; f'';
        };
        user = {
          name = "Nick Boultbee";
          email =
            if isWork
            then "nick.boultbee@generative.vision"
            else "declension@users.noreply.github.com";
        };
      };
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };
  };
}
