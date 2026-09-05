#!/usr/bin/env bash
. "$(dirname "$0")/../../runner_lib.sh"

# `make test-integration` globbed one level deep while nearly every case
# in the tier sits two — under a stage-N/ folder. It ran 57 of 253 and
# exited 0, so every green it reported was evidence of nothing.
#
# Two assertions, because the fault had two halves. The fixture proves
# the property: over a tree whose every case is an integration case, the
# target and tests/run.sh must reach the same total. The real tree
# proves it holds here today — that is the half a fourth depth would
# break, and run.sh's `find` is the count it would break against.

runner_tree

out=$(make -C "$ROOT" test-integration 2>&1)
code=$?
ran=$(markers "$out")

if [ "$code" -eq 0 ] && [ "$ran" -eq "$TREE_CASES" ]; then
  echo "ok    make test-integration runs the tier at every depth it uses"
  pass=$((pass + 1))
else
  printf 'FAIL  make test-integration ran %s of %s cases (exit %s)\n' \
    "$ran" "$TREE_CASES" "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

run_out=$(bash "$ROOT/tests/run.sh" 2>&1)
total=$(printf '%s\n' "$run_out" | sed -n 's/^\([0-9]*\) case files passed.*/\1/p')

if [ "$total" = "$ran" ]; then
  echo "ok    the target and tests/run.sh agree on the case count"
  pass=$((pass + 1))
else
  printf 'FAIL  tests/run.sh counted %s where the target counted %s\n' \
    "$total" "$ran"
  printf '%s\n' "$run_out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# The real tree. The globs are read out of the Makefile rather than
# retyped here: a copy of them in this file would agree with the recipe
# today and drift the first time either is edited.
globs=$(recipe_globs test-integration)
reached=$(cd "$REPO_ROOT" && for f in $globs; do [ -e "$f" ] || continue; echo "$f"; done | sort -u | wc -l | tr -d ' ')
held=$(cd "$REPO_ROOT" && find tests/integration -name '*_test.sh' | wc -l | tr -d ' ')

if [ "$reached" = "$held" ]; then
  printf 'ok    the integration globs reach all %s of the tier'"'"'s cases\n' "$held"
  pass=$((pass + 1))
else
  printf 'FAIL  the integration globs reach %s of the tier'"'"'s %s cases\n' \
    "$reached" "$held"
  printf '      globs: %s\n' "$globs"
  fail=$((fail + 1))
fi

# The sibling target, against the same property. `test-unit` was left at
# one depth while `test-integration` was fixed to two, and it skips
# nothing today only because every unit suite happens to sit at depth 2
# — a fact no rule holds true. run.sh's header sanctions a stage-N/
# folder in either tier, so the first unit suite placed under one would
# run there and be silently skipped here, which is the fault this file
# exists to end rather than to halve.
u_globs=$(recipe_globs test-unit)
u_reached=$(cd "$REPO_ROOT" && for f in $u_globs; do [ -e "$f" ] || continue; echo "$f"; done | sort -u | wc -l | tr -d ' ')
u_held=$(cd "$REPO_ROOT" && find tests/unit -name '*_test.sh' | wc -l | tr -d ' ')

if [ "$u_reached" = "$u_held" ]; then
  printf 'ok    the unit globs reach all %s of the tier'"'"'s cases\n' "$u_held"
  pass=$((pass + 1))
else
  printf 'FAIL  the unit globs reach %s of the tier'"'"'s %s cases\n' \
    "$u_reached" "$u_held"
  printf '      globs: %s\n' "$u_globs"
  fail=$((fail + 1))
fi

finish
