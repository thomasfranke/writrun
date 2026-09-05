#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# `checks.md` enumerates the PR_* names a workflow step passes, and the
# paragraph exists to name a silent-miswiring hazard. It went short by
# one when apply_pr_event.sh grew PR_NUMBER: a doc sentence that
# enumerates a code contract goes stale without anything going red, and
# this paragraph most of all — a name it omits is a name nobody checks
# the wiring of.
#
# The enumeration is read from the doc and the contract from the script,
# so neither side is retyped here. A third copy would be one more thing
# to keep true.

CHECKS="$REPO_ROOT/docs/technical/distribution/checks.md"
SCRIPT="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/apply_pr_event.sh"

# The enumerating sentence alone — from the bold lead to "that way." —
# and not the paragraph around it. The paragraph goes on to name several
# of these in true sentences about what a miswired one costs, and a
# reading that counted those would pass a list with a name missing from
# it, which is the exact fault this case exists for.
paragraph=$(awk '
  /A `PR_\*` name carries pull-request event data/ { inside = 1 }
  inside { print }
  inside && /that way\./ { exit }
' "$CHECKS")

read_names=$(grep -o 'PR_[A-Z][A-Z_]*' "$SCRIPT" | sort -u)
listed=$(printf '%s\n' "$paragraph" | grep -o 'PR_[A-Z][A-Z_]*' | sort -u)

missing=""
for n in $read_names; do
  printf '%s\n' "$listed" | grep -qx "$n" || missing="${missing}${n} "
done

if [ -n "$paragraph" ] && [ -z "$missing" ]; then
  echo "ok    the PR_* enumeration names every name the script reads"
  pass=$((pass + 1))
else
  [ -n "$paragraph" ] || echo "FAIL  the PR_* paragraph was not found in checks.md"
  [ -z "$paragraph" ] || printf 'FAIL  the PR_* enumeration omits: %s\n' "${missing% }"
  fail=$((fail + 1))
fi

# The other direction. A name the enumeration carries and the script
# never reads is the same hazard read backwards: the reader wires it,
# nothing consumes it, and nothing is loud about that either.
stale=""
for n in $listed; do
  printf '%s\n' "$read_names" | grep -qx "$n" || stale="${stale}${n} "
done

if [ -z "$stale" ]; then
  echo "ok    the enumeration names nothing the script does not read"
  pass=$((pass + 1))
else
  printf 'FAIL  the PR_* enumeration names what the script never reads: %s\n' "${stale% }"
  fail=$((fail + 1))
fi

finish
