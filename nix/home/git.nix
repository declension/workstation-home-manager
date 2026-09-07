# `lfs.enable` registers the smudge/clean filters,
# which installing the git-lfs package alone does not do.
{
  lib,
  pkgs,
  username,
  ...
}: let
  # Work accounts are declared via $HM_WORK_USERNAMES (comma-separated),
  # loaded from a local, gitignored `.env` — see `.env.example`.
  # Nothing work-specific is committed here; unset means "treat as personal".
  workUsernames = lib.splitString "," (builtins.getEnv "HM_WORK_USERNAMES");
  isWork = builtins.elem username workUsernames;

  # Lists remote branches already merged into the default branch, one per line.
  # Merged-ness is measured against that branch and not HEAD: bare `--merged`
  # means "merged into whatever I have checked out", which on a develop-style
  # branch sweeps up every open PR branch merged there, plus the branch itself.
  # `fetch --prune` is load-bearing — a stale ref still looks merged.
  # Chatter goes to stderr and branch names to stdout, so `cleanup-force` can
  # pipe this into xargs without eating the commentary.
  gitCleanup = pkgs.writeShellScript "git-cleanup" ''
    set -euo pipefail

    protected='main|master|develop|staging|production|release/.*'
    log() { printf '[%s]\t%s\n' $(date +%H:%M:%S) "$*" >&2; }
    count() { grep -c . || true; }

    target="''${1:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)}"

    log "Fetching origin and pruning stale remote-tracking refs…"
    git fetch --prune --quiet

    if ! git rev-parse --verify --quiet "$target" >/dev/null; then
      log "No such ref: $target — pass a target, e.g. 'git cleanup origin/develop'."
      exit 1
    fi

    current="$(git symbolic-ref --quiet --short HEAD || echo)"
    branches() { git for-each-ref --format='%(refname:lstrip=3)%09%(symref)' "$@" refs/remotes/origin | awk -F'\t' '$2 == "" { print $1 }'; }

    all="$(branches)"
    merged="$(branches --merged "$target")"

    # Every grep here can legitimately match nothing, and pipefail would kill
    # the script mid-report if it did — hence a guard on each one.
    kept="$(printf '%s\n' "$merged" | { grep -xE "$protected" || true; })"
    candidates="$(printf '%s\n' "$merged" | { grep -vxE "$protected" || true; })"
    if [ -n "$current" ]; then
      candidates="$(printf '%s\n' "$candidates" | { grep -vxF "$current" || true; })"
    fi

    log "Comparing against $target — $(printf '%s\n' "$all" | count) branches on origin, $(printf '%s\n' "$merged" | count) merged in."
    if [ -n "$kept" ]; then
      log "Protected, skipping: $(printf '%s\n' "$kept" | paste -sd' ' -)"
    fi
    if [ -n "$current" ] && printf '%s\n' "$merged" | grep -qxF "$current" && ! printf '%s\n' "$kept" | grep -qxF "$current"; then
      log "Skipping $current (checked out here)."
    fi

    if [ -z "$candidates" ]; then
      log "Nothing to delete — every merged branch is protected or checked out."
      exit 0
    fi

    log "$(printf '%s\n' "$candidates" | count) branch(es) merged into $target and safe to delete:"
    if [ -t 1 ]; then
      printf '%s\n' "$candidates"
      log "Run 'git cleanup-force' to delete these from origin."
    else
      # Being piped (i.e. into `cleanup-force`), so stdout is the machine's:
      # echo the names to stderr too, or they'd scroll past unseen.
      log "$(printf '%s\n' "$candidates" | sed 's/^/  /')"
      printf '%s\n' "$candidates"
    fi
  '';
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
          # `cleanup` only lists; `cleanup-force` is the one that deletes.
          cleanup = "!${gitCleanup}";
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
