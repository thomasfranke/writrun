#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# Every text the kit answers on a project's behalf ships twice, once per
# home: the answer under .writrun/defaults/, and a deferring stub at the
# same relative name in the seed the adopter gets
# (docs/product/adoption.md#two-homes). The pair is what the resolver
# assumes — a default with no stub reaches an adopter who never learns
# the file is theirs to write, and a stub with no default resolves to
# nothing at all.

MARKER="/// writrun:default"
DEFAULTS="$REPO_ROOT/.writrun/defaults"
SEED="$REPO_ROOT/kit/writrun"

while IFS= read -r d; do
  rel="${d#"$DEFAULTS"/}"
  if [ -f "$SEED/$rel" ]; then
    echo "ok    $rel — the default has its stub in the seed"; pass=$((pass + 1))
  else
    echo "FAIL  $rel — the kit ships a default the adopter has no file for"; fail=$((fail + 1))
  fi
  # A default carrying the marker would defer to itself.
  if [ "$(sed -n '1p' "$d")" = "$MARKER" ]; then
    echo "FAIL  $rel — a default carries the deferral marker and would resolve to itself"; fail=$((fail + 1))
  else
    echo "ok    $rel — the default states its answer, it does not defer"; pass=$((pass + 1))
  fi
done <<EOF
$(find "$DEFAULTS" -type f -name '*.md' | sort)
EOF

# Every seeded file under the adopter's home either defers or is a real
# answer the kit means to ship. settings.json is the one real answer:
# a fresh copy needs values from the first day (kit_ships_cautious).
while IFS= read -r s; do
  rel="${s#"$SEED"/}"
  case "$rel" in settings.json) continue ;; esac
  if [ "$(sed -n '1p' "$s")" != "$MARKER" ]; then
    echo "FAIL  $rel — the seed ships prose in the adopter's home; it belongs in .writrun/defaults/"; fail=$((fail + 1))
    continue
  fi
  if [ -f "$DEFAULTS/$rel" ]; then
    echo "ok    $rel — the stub defers, and the default it names exists"; pass=$((pass + 1))
  else
    echo "FAIL  $rel — the stub defers to a default the kit does not ship"; fail=$((fail + 1))
  fi
  # The address is computed from the name; a stub that wrote one would
  # freeze it at the version that seeded it.
  if grep -q "\.writrun/defaults" "$s"; then
    echo "FAIL  $rel — the stub writes the address it resolves to"; fail=$((fail + 1))
  else
    echo "ok    $rel — the stub carries no address"; pass=$((pass + 1))
  fi
done <<EOF
$(find "$SEED" -type f | sort)
EOF

# This repository's own home carries the same stubs, hand-seeded: it
# sits outside the mirror list, so nothing else compares the two copies,
# and two hand-kept copies of one boilerplate drift silently — the
# report-0039 failure the two-homes split exists to remove. A root file
# that defers is the seed's stub, byte for byte; one that declared its
# own answer (no marker) is the project's and is skipped.
while IFS= read -r s; do
  rel="${s#"$SEED"/}"
  root="$REPO_ROOT/writrun/$rel"
  [ -f "$root" ] || continue
  [ "$(sed -n '1p' "$root")" = "$MARKER" ] || continue
  if diff -q "$root" "$s" >/dev/null 2>&1; then
    echo "ok    $rel — the root's deferring stub is the seed's, byte for byte"; pass=$((pass + 1))
  else
    echo "FAIL  $rel — the root's deferring stub drifted from the seed's"; fail=$((fail + 1))
  fi
done <<EOF
$(find "$SEED" -type f | sort)
EOF

finish
