#!/usr/bin/env bash
. "$(dirname "$0")/../../runner_lib.sh"

# The `test-%` pattern rule carried the same one-level gap as
# test-integration, one level over: a suite directory nested under a
# tier's stage-N/ folder was unreachable through it, and so was a tier
# whose suites sit two deep. The explicit test-unit and test-integration
# targets shadow the pattern for the two names anybody types, which is
# how the gap stayed invisible.
#
# The refusal is asserted beside the resolutions on purpose. Widening a
# glob until everything matches something is the way a "no such suite"
# stops being reachable, and a runner that silently runs nothing for a
# name nobody has is the fault this whole spec is about.

runner_tree
runner_extra_tier

out=$(make -C "$ROOT" test-deep_suite 2>&1)
code=$?
ran=$(markers "$out")
if [ "$code" -eq 0 ] && [ "$ran" -eq 2 ]; then
  echo "ok    a suite under a stage folder resolves by its own name"
  pass=$((pass + 1))
else
  printf 'FAIL  test-deep_suite ran %s of 2 cases (exit %s)\n' "$ran" "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

out=$(make -C "$ROOT" test-wide 2>&1)
code=$?
ran=$(markers "$out")
if [ "$code" -eq 0 ] && [ "$ran" -eq 1 ]; then
  echo "ok    a tier reached through the pattern finds its deep suites"
  pass=$((pass + 1))
else
  printf 'FAIL  test-wide ran %s of 1 case (exit %s)\n' "$ran" "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# `make` reports its own 2 for any failed recipe, so the recipe's 3 is
# read where make names it rather than from `$?` — asserting on `$?`
# here would be asserting on make's vocabulary, not on the rule.
out=$(make -C "$ROOT" test-nothing_named_this 2>&1)
code=$?
if [ "$code" -ne 0 ] \
   && printf '%s' "$out" | grep -q 'no such suite: nothing_named_this' \
   && printf '%s' "$out" | grep -q 'Error 3'; then
  echo "ok    a name that matches nothing still exits 3"
  pass=$((pass + 1))
else
  printf 'FAIL  an unknown suite exited %s without naming itself\n' "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
