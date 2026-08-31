#!/usr/bin/env bash
# sync_template.sh — refreshes template/'s mirrored paths from the root.
#
# Usage: sync_template.sh [mirror-list [exceptions-list]]
#   Default lists: tests/template_mirrors.txt and
#   tests/template_exceptions.txt. Run from the repository root —
#   template/ and every listed path are resolved relative to it.
#
# Home-repository automation, never shipped to adopters — which is why
# it lives here and not in .writrun/scripts/: an adopter has no
# template/ to sync.
#
# The adoption kit is a deliberate full copy, and a copy is a second
# source of truth — legal only because it is mechanical: the mirror list
# is the single source of what ships, this script is the single writer,
# and a unit test holds every mirrored path byte-identical to the root.
# Hand-editing template/ is never the fix.
#
# A listed path missing at the root is a named error, and its stale
# template copy is left in place rather than deleted — reporting
# "synced" after destroying the only remaining copy is the silent lie
# the old inline Makefile recipe told.
#
# **The exceptions list is where the kit differs on purpose.**
# `.writrun/settings.json` is the adopter's file, and the kit's copy
# ships cautious — Stage 1, every conduct flag `false` — so a fresh copy
# does nothing on its own. Preserving it is not a matter of skipping a
# write: the mirror list names `.writrun`, a whole directory, and a
# directory is refreshed by removing it and copying it back, so the
# exception is deleted before any copy happens. It is stashed before the
# mirror runs and restored after, and every kept path is named in the
# output — an exception nobody can see is drift with a rationale.
#
# An exception the kit does not carry yet is not stashed, so it arrives
# from the root like any other path, reported as adopted. Writing the
# kit's own version is then a deliberate act, never something the sync
# guesses at.
#
# Exit codes: 0 synced; 1 a listed path is missing at the root; 3 no
# mirror list.

set -euo pipefail

LIST="${1:-tests/template_mirrors.txt}"
EXCEPTIONS="${2:-tests/template_exceptions.txt}"
[ -f "$LIST" ] || { echo "No mirror list: $LIST" >&2; exit 3; }

# Stash the kit's own versions before the mirror removes the trees they
# live in. A temporary directory rather than a rename in place, because
# an exception may sit at any depth under a mirrored path.
STASH=""
if [ -f "$EXCEPTIONS" ]; then
  while IFS= read -r x; do
    [ -n "$x" ] || continue
    [ -e "template/$x" ] || continue
    [ -n "$STASH" ] || STASH=$(mktemp -d)
    mkdir -p "$STASH/$(dirname "$x")"
    cp -R "template/$x" "$STASH/$x"
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
  rm -rf "template/$p"
  mkdir -p "template/$(dirname "$p")"
  cp -R "$p" "template/$p"
  echo "synced $p"
done < "$LIST"

# Restore what the kit keeps, and say so — a difference the output never
# names is indistinguishable from drift.
if [ -f "$EXCEPTIONS" ]; then
  while IFS= read -r x; do
    [ -n "$x" ] || continue
    if [ -n "$STASH" ] && [ -e "$STASH/$x" ]; then
      mkdir -p "template/$(dirname "$x")"
      rm -rf "template/$x"
      cp -R "$STASH/$x" "template/$x"
      echo "kept    $x — the kit's own, not the root's"
    elif [ -e "template/$x" ]; then
      echo "adopted $x — the kit had none, so the root's was copied; write the kit's when it should differ"
    fi
  done < "$EXCEPTIONS"
fi
[ -z "$STASH" ] || rm -rf "$STASH"

exit "$status"
