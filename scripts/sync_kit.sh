#!/usr/bin/env bash
# sync_kit.sh — refreshes kit/'s mirrored paths from the root.
#
# Usage: sync_kit.sh [mirror-list [exceptions-list]]
#   Default lists: tests/kit_mirrors.txt and
#   tests/kit_exceptions.txt. Run from the repository root —
#   kit/ and every listed path are resolved relative to it.
#
# Home-repository automation, never shipped to adopters — which is why
# it lives here and not in .writrun/scripts/: an adopter has no
# kit/ to sync.
#
# The adoption kit is a deliberate full copy, and a copy is a second
# source of truth — legal only because it is mechanical: the mirror list
# is the single source of what ships, this script is the single writer,
# and a unit test holds every mirrored path byte-identical to the root.
# Hand-editing kit/ is never the fix.
#
# A listed path missing at the root is a named error, and its stale
# kit copy is left in place rather than deleted — reporting
# "synced" after destroying the only remaining copy is the silent lie
# the old inline Makefile recipe told.
#
# **The exceptions list is where the kit differs on purpose.** Since
# the two homes split it is empty: the adopter's files — settings,
# gates, conventions — live in `writrun/`, outside every mirrored path,
# and the kit's cautious seed of them ships as `kit/writrun/`,
# which this script never touches. The mechanism stays for the next
# exception that earns it: a listed path is stashed before the mirror
# runs and restored after (the mirror list names `.writrun`, a whole
# directory, refreshed by removing and copying back), and every kept
# path is named in the output — an exception nobody can see is drift
# with a rationale.
#
# An exception the kit does not carry yet is not stashed, so it arrives
# from the root like any other path, reported as adopted. Writing the
# kit's own version is then a deliberate act, never something the sync
# guesses at.
#
# Exit codes: 0 synced; 1 a listed path is missing at the root; 3 no
# mirror list.

set -euo pipefail

LIST="${1:-tests/kit_mirrors.txt}"
EXCEPTIONS="${2:-tests/kit_exceptions.txt}"
[ -f "$LIST" ] || { echo "No mirror list: $LIST" >&2; exit 3; }

# Stash the kit's own versions before the mirror removes the trees they
# live in. A temporary directory rather than a rename in place, because
# an exception may sit at any depth under a mirrored path.
STASH=""
if [ -f "$EXCEPTIONS" ]; then
  while IFS= read -r x; do
    [ -n "$x" ] || continue
    [ -e "kit/$x" ] || continue
    [ -n "$STASH" ] || STASH=$(mktemp -d)
    mkdir -p "$STASH/$(dirname "$x")"
    cp -R "kit/$x" "$STASH/$x"
  done < "$EXCEPTIONS"
fi

status=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if [ ! -e "$p" ]; then
    echo "MISSING: '$p' is in the mirror list but not at the root — the list and the root disagree" >&2
    status=1
    continue
  fi
  rm -rf "kit/$p"
  mkdir -p "kit/$(dirname "$p")"
  cp -R "$p" "kit/$p"
  echo "synced $p"
done < "$LIST"

# Restore what the kit keeps, and say so — a difference the output never
# names is indistinguishable from drift.
if [ -f "$EXCEPTIONS" ]; then
  while IFS= read -r x; do
    [ -n "$x" ] || continue
    if [ -n "$STASH" ] && [ -e "$STASH/$x" ]; then
      mkdir -p "kit/$(dirname "$x")"
      rm -rf "kit/$x"
      cp -R "$STASH/$x" "kit/$x"
      echo "kept    $x — the kit's own, not the root's"
    elif [ -e "kit/$x" ]; then
      echo "adopted $x — the kit had none, so the root's was copied; write the kit's when it should differ"
    fi
  done < "$EXCEPTIONS"
fi
[ -z "$STASH" ] || rm -rf "$STASH"

exit "$status"
