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

  # Deletes spent branches, local and on origin. Safety first: a branch only
  # goes if its changes are demonstrably already in the target, and whatever
  # is checked out never goes at all. Edge cases are named, and need --force.
  gitCleanup = pkgs.writeShellScript "git-cleanup" ''
    set -euo pipefail

    protected='main|master|develop|staging|production|release/.*'
    log() { printf '[%s]\t%s\n' "$(date +%H:%M:%S)" "$*" >&2; }
    count() { set -- $*; printf '%s' "$#"; }
    listed() { printf '%s\n' $2 | grep -qxF "$1"; }

    force=""; dry=""; target=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -f | --force) force=1 ;;
        -n | --dry-run) dry=1 ;;
        -*) log "usage: git cleanup [--force] [--dry-run] [target]"; exit 2 ;;
        *) target="$1" ;;
      esac
      shift
    done
    target="''${target:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)}"

    # Load-bearing: a stale ref still looks merged, and pruning is what turns a
    # branch origin has deleted into a `gone` upstream.
    log "Fetching origin and pruning stale remote-tracking refs…"
    git fetch --prune --quiet

    if ! git rev-parse --verify --quiet "$target" >/dev/null; then
      log "No such ref: $target — pass a target, e.g. 'git cleanup origin/develop'."
      exit 1
    fi

    # Covers the current branch as well as any worktree's.
    held="$(git worktree list --porcelain | sed -n 's|^branch refs/heads/||p')"

    # `--merged` only knows ancestry, so it misses every squash merge — nearly
    # all of them, on a forge that squashes by default. Replaying the branch's
    # tree as one commit on the merge base is what a squash looks like from
    # here; `git cherry` prefixes '-' when that patch is already upstream.
    patch_merged() {
      if git merge-base --is-ancestor "$1" "$target"; then return 0; fi
      base="$(git merge-base "$target" "$1" 2>/dev/null)" || return 1
      probe="$(git commit-tree "$1^{tree}" -p "$base" -m squash-probe)"
      case "$(git cherry "$target" "$probe")" in -*) return 0 ;; esac
      return 1
    }

    deletable() {
      [ "$1" = HEAD ] && return 1
      ! printf '%s' "$1" | grep -qxE "$protected"
    }

    # A closed MR leaves the same `gone` upstream a merged one does, and by
    # then the commits are local-only — so `gone` alone is a --force matter.
    gone="$(git for-each-ref --format='%(refname:short) %(upstream:track,nobracket)' refs/heads | awk '$2 == "gone" { print $1 }')"

    locals=""; risky=""; remotes=""
    for b in $(git for-each-ref --format='%(refname:short)' refs/heads); do
      deletable "$b" || continue
      if listed "$b" "$held"; then
        # Only worth saying when it would otherwise have gone.
        if patch_merged "refs/heads/$b" || listed "$b" "$gone"; then log "Checked out, staying put: $b"; fi
      elif patch_merged "refs/heads/$b"; then locals="$locals $b"
      elif listed "$b" "$gone"; then risky="$risky $b"
      fi
    done

    for b in $(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/origin); do
      deletable "$b" || continue
      if [ "origin/$b" = "$target" ] || listed "$b" "$held"; then continue; fi
      if patch_merged "refs/remotes/origin/$b"; then remotes="$remotes $b"; fi
    done

    if [ -n "$risky" ]; then
      if [ -n "$force" ]; then
        log "Gone from origin but not in $target — deleting anyway, you asked:"
        locals="$locals $risky"
      else
        log "Gone from origin but not in $target, so left alone (--force to delete):"
      fi
      printf '\t    %s\n' $risky >&2
    fi

    if [ -z "$locals$remotes" ]; then
      log "Nothing to delete."
      exit 0
    fi

    verb="Deleting"; [ -z "$dry" ] || verb="Would delete"
    log "$verb $(count "$locals $remotes") branch(es):"
    [ -z "$locals" ] || printf '\t    local   %s\n' $locals >&2
    [ -z "$remotes" ] || printf '\t    origin  %s\n' $remotes >&2
    [ -z "$dry" ] || exit 0

    # One call each: a round trip per branch is a different experience once
    # there are dozens. -D because git's own check is the ancestry-only one
    # we just worked around.
    [ -z "$locals" ] || git branch --quiet -D $locals
    [ -z "$remotes" ] || git push --quiet --delete origin $remotes
    log "Done."
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
          # `cleanup` deletes what is provably merged; `--force` adds the
          # branches origin deleted that we can't prove were merged.
          cleanup = "!${gitCleanup}";
          cleanup-force = "!${gitCleanup} --force";
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
