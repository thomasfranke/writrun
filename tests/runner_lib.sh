#!/usr/bin/env bash
# runner_lib.sh — the fixture for the test runner's own discovery.
#
# The runner is the one script the suite cannot check by running it: a
# case that invoked `bash tests/run.sh` would re-enter the suite it is
# part of. So these cases build a miniature repository — the real
# Makefile and the real tests/run.sh over a handful of fixture cases —
# and read what the two of them find there.
#
# The fixture case files print a marker and exit 0. `make` reports a
# verdict and nothing else, so counting markers in its output is how a
# target's case count is read at all.

. "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

MARKER="FIXTURE-CASE"
ROOT=""
TREE_CASES=0

# runner_case <path> — one fixture case, at whatever depth the caller
# names. It honours RUNNER_FIXTURE_SLEEP so a case can be made slow
# enough for two runs to overlap.
runner_case() {
  mkdir -p "$(dirname "$1")"
  cat > "$1" <<'CASE'
#!/usr/bin/env bash
[ -n "${RUNNER_FIXTURE_SLEEP:-}" ] && sleep "$RUNNER_FIXTURE_SLEEP"
echo "FIXTURE-CASE $0"
exit 0
CASE
}

# runner_tree — the miniature repository, in $WORK/root. Three
# integration cases at the two depths the tier really uses: one suite at
# the tier root, one under a stage-N/ folder. Every case in it is an
# integration case, so `make test-integration` and `tests/run.sh` are
# asking the same question there and their answers must match.
runner_tree() {
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/writrun-runner.XXXXXX")"
  ROOT="$WORK/root"
  mkdir -p "$ROOT/tests"
  cp "$REPO_ROOT/Makefile" "$ROOT/Makefile"
  cp "$REPO_ROOT/tests/run.sh" "$ROOT/tests/run.sh"
  runner_case "$ROOT/tests/integration/root_suite/one_test.sh"
  runner_case "$ROOT/tests/integration/stage-9/deep_suite/two_test.sh"
  runner_case "$ROOT/tests/integration/stage-9/deep_suite/three_test.sh"
  TREE_CASES=3
}

# runner_extra_tier — a second tier whose only suite sits two levels
# down. It exists for the `test-%` pattern rule, which is the only way a
# tier name reaches those globs: the explicit test-unit and
# test-integration targets shadow the pattern for the two names anybody
# types, which is why the gap in it survived unseen.
runner_extra_tier() {
  runner_case "$ROOT/tests/wide/stage-9/wide_suite/four_test.sh"
}

# markers <output> — how many fixture cases a `make` run actually ran.
markers() { printf '%s\n' "$1" | grep -c "$MARKER"; }

# recipe_globs <target> — the glob list a Makefile recipe iterates, read
# out of the Makefile itself. The real tree is checked against this
# rather than by running the target, because running the integration
# tier from inside the unit tier is the re-entry this fixture avoids.
recipe_globs() {
  sed -n "/^$1:/,/^\$/p" "$REPO_ROOT/Makefile" \
  | tr '\n' ' ' | sed 's/\\ / /g' \
  | sed -n 's/.*for f in \(.*\); do.*/\1/p'
}
