#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The kit is a copy of this repository, and this repository runs at Stage
# 3 with every conduct flag open. Copied whole, that file would start an
# adopter with four workflows armed and an Issues mirror opening issues on
# their first pull request — while the guide is still telling them to
# declare a stage. So the kit's settings file leaves the byte mirror, and
# ships closed: nothing happens until the project says it should.
READ_SETTING="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/read_setting.sh"
CHECK_SETTINGS="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/check_settings.sh"

cd "$REPO_ROOT/template" || exit 1

check "the kit adopts at Stage 1" 0 "^1$" -- bash "$READ_SETTING" stage
for flag in auto_commit auto_pr auto_push; do
  check "the kit gates ${flag}" 0 "^false$" \
    -- bash "$READ_SETTING" "stage_2.${flag}"
done
check "and the kit's own file is canonical" 0 "is canonical" \
  -- bash "$CHECK_SETTINGS"

# The root's file is the opposite choice, deliberately — the difference is
# what tests/template_exceptions.txt exists for, and a kit that had drifted
# into agreement would mean the exception stopped working.
cd "$REPO_ROOT" || exit 1
check "the root runs at Stage 3, which is why the two differ" 0 "^3$" \
  -- bash "$READ_SETTING" stage

# Keys are alphabetical inside each section — the schema's rule, stated in
# docs/technical/README.md#settings with nothing enforcing it there,
# because a fault over an adopter's working file would cost more than the
# order buys. Here, over the two files this repository owns, it is cheap.
ordered() {   # ordered <file> — every section's keys, in order
  awk '
    /^  "[A-Za-z0-9_]+": [{]/ { sec = $1; gsub(/[":]/, "", sec); prev = ""; next }
    /^  [}]/               { sec = ""; prev = top_prev; next }
    /^  "[A-Za-z0-9_]+":/     { key = $1; gsub(/[":]/, "", key)
                             if (key < prev) { print "top level: " key " follows " prev; bad = 1 }
                             prev = key; top_prev = key; next }
    /^    "[A-Za-z0-9_]+":/   { key = $1; gsub(/[":]/, "", key)
                             if (key < prev) { print sec ": " key " follows " prev; bad = 1 }
                             prev = key; next }
    END { exit bad ? 1 : 0 }
  ' "$1"
}
for f in .writrun/settings.json template/.writrun/settings.json; do
  if out=$(ordered "$f"); then
    echo "ok    $f keeps its keys alphabetical inside each section"
    pass=$((pass + 1))
  else
    echo "FAIL  $f keeps its keys alphabetical inside each section"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1))
  fi
done

finish
