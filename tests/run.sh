#!/usr/bin/env bash
# run.sh — discovers and runs every case in the suite.
#
#   bash tests/run.sh
#
# Layout: one tier per directory — unit/ for the skill scripts, integration/
# for the workflow step scripts in .writrun/scripts and the home automation,
# e2e/ for whole-path runs against a copy of this repository. Inside a
# tier, a suite bound to exactly one adoption stage sits under a
# stage-N/ folder (product/adoption.md#three-stages); cross-stage suites
# — the skills, the infrastructure — sit at the tier root. One directory
# per script under test, one file per behaviour, suffixed `_test.sh`. Every case sources the fixture for its domain
# (tests/pipeline_lib.sh, tests/release_lib.sh, tests/mirror_lib.sh —
# all layered on tests/harness.sh) and also runs standalone:
#
#   bash tests/unit/check_state/born_implemented_rejected_test.sh
#
# These exist because check_deltas.sh once shipped with a path-prefix bug
# that meant it had never passed and could not have — caught by reading it,
# not by running it (docs/technical/decisions/). A check nobody
# executes is a check nobody can trust.

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"

pass=0
fail=0

find "$TESTS_DIR" -name '*_test.sh' -print | sed 's|/[^/]*$||' | sort -u \
| while IFS= read -r dir; do
  echo "${dir#"$TESTS_DIR"/}"
  for case_file in "$dir"/*_test.sh; do
    [ -e "$case_file" ] || continue
    bash "$case_file"
    echo "case:$?" >> "$TESTS_DIR/.tally"
  done
  echo
done
pass=$(grep -c '^case:0$' "$TESTS_DIR/.tally" 2>/dev/null || echo 0)
total=$(grep -c '^case:' "$TESTS_DIR/.tally" 2>/dev/null || echo 0)
fail=$((total - pass))
rm -f "$TESTS_DIR/.tally"

printf '%s case files passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
