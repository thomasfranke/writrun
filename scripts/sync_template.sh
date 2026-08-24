#!/usr/bin/env bash
# sync_template.sh — refreshes template/'s mirrored paths from the root.
#
# Usage: sync_template.sh [mirror-list]
#   Default list: tests/template_mirrors.txt. Run from the repository
#   root — template/ and every listed path are resolved relative to it.
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
# Exit codes: 0 synced; 1 a listed path is missing at the root; 3 no
# mirror list.

set -euo pipefail

LIST="${1:-tests/template_mirrors.txt}"
[ -f "$LIST" ] || { echo "No mirror list: $LIST" >&2; exit 3; }

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

exit "$status"
