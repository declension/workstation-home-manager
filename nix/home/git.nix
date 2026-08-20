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
          cleanup = "!git branch -r --merged | grep -v main | sed 's@origin/@@' | xargs --no-run-if-empty -n 1 git push --delete origin";
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
