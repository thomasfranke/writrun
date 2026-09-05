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

# **An interrupted run must not report.** A handler that only removes the
# file replaces the default terminate action and returns: the loop goes
# on, the remaining cases recreate the tally with `>>`, and the count at
# the end sees only the cases that ran *after* the signal — `fail` can be
# 0 and the run exits green. That is the manufacturable green this file's
# private path exists to remove, one signal over. So the handler exits,
# on the signal's own code, and the count is never reached.
trap 'rm -f "$TALLY"' EXIT
trap 'rm -f "$TALLY"; exit 130' INT
trap 'rm -f "$TALLY"; exit 143' TERM

# **The loop runs in this shell, not a pipeline's subshell.** A trap set
# here does not stop a loop running in a child, so an interrupted run
# went on to the last case before anything could act on the signal —
# which is a terminate handler that does not terminate. The discovery
# list arrives by here-document instead: a redirection, so the `exit`
# above lands between one case and the next.
SUITE_DIRS=$(find "$TESTS_DIR" -name '*_test.sh' -print | sed 's|/[^/]*$||' | sort -u)

while IFS= read -r dir; do
  [ -n "$dir" ] || continue
  echo "${dir#"$TESTS_DIR"/}"
  for case_file in "$dir"/*_test.sh; do
    [ -e "$case_file" ] || continue
    # stdin closed: the discovery list feeds this loop through a
    # redirection, and a case that reads stdin would silently eat the
    # rest of it.
    bash "$case_file" < /dev/null
    echo "case:$?" >> "$TALLY"
  done
  echo
done <<EOT
$SUITE_DIRS
EOT
pass=$(grep -c '^case:0$' "$TALLY" 2>/dev/null || echo 0)
total=$(grep -c '^case:' "$TALLY" 2>/dev/null || echo 0)
fail=$((total - pass))
rm -f "$TALLY"

printf '%s case files passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
