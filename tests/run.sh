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

# The tally is private to this run. A fixed path under tests/ was shared
# by every invocation in the worktree, so two overlapping runs appended
# to one file and each counted the other's cases as its own — reported
# totals of 795 and 808 against a true 405. What protects the count now
# is the path, not a truncation: no other run can name this file. The
# trap removes it however the run ends, including interrupted, which is
# what the truncation was standing in for.
# The explicit template is the portable form — `mktemp` with no argument
# is not in BSD's dialect (bash 3.2 and macOS, per docs/technical/decisions/).
TALLY="$(mktemp "${TMPDIR:-/tmp}/writrun-tally.XXXXXX")" || exit 1
trap 'rm -f "$TALLY"' EXIT INT TERM

find "$TESTS_DIR" -name '*_test.sh' -print | sed 's|/[^/]*$||' | sort -u \
| while IFS= read -r dir; do
  echo "${dir#"$TESTS_DIR"/}"
  for case_file in "$dir"/*_test.sh; do
    [ -e "$case_file" ] || continue
    # stdin closed: the discovery list feeds this loop through a pipe,
    # and a case that reads stdin would silently eat the rest of it.
    bash "$case_file" < /dev/null
    echo "case:$?" >> "$TALLY"
  done
  echo
done
pass=$(grep -c '^case:0$' "$TALLY" 2>/dev/null || echo 0)
total=$(grep -c '^case:' "$TALLY" 2>/dev/null || echo 0)
fail=$((total - pass))
rm -f "$TALLY"

printf '%s case files passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
