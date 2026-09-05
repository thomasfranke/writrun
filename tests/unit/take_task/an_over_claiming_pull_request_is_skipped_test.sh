#!/usr/bin/env bash
# Another pull request's over-ceiling claim is its author's fault, and
# failing this take over it would let one hostile title stop all work —
# the denial the ceiling exists to prevent. The row is **skipped**, not
# emptied: an empty carried set is what routes a pull request into the
# amendment-candidate list and its paginated files probe, so a title
# claiming everything would buy a suspended take (spec-0069).
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
publish_main

# Nine distinct tasks — the branch's own and eight tags, task-0001 among
# them — on a pull request that also touches this task's spec. Both
# routes that could stop the take are claimed at once.
forge_open_pr 9 task/0002-everything \
  "[TASK-0001][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][Feat][Ci] Everything at once" \
  someone
forge_pr 9 modified work/specs/spec-001.md

out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" 2>&1); code=$?

if [ "$code" -eq 0 ] && printf '%s' "$out" | grep -q "draft pull request open"; then
  printf 'ok    %s\n' "the take proceeds past the over-claiming row"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n      expected the take to complete, exit was %s\n' \
    "the take proceeds past the over-claiming row" "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if printf '%s' "$out" | grep -q "pull request #9 claims 9 distinct tasks"; then
  printf 'ok    %s\n' "and the notice names the pull request it skipped"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n      expected a notice naming #9\n' "and the notice names the pull request it skipped"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if grep -q "pulls/9/files" "$FORGE_LOG"; then
  printf 'FAIL  %s\n      the skipped row was probed for its files\n' \
    "no files probe is made for the skipped row"
  sed 's/^/      | /' "$FORGE_LOG"
  fail=$((fail + 1))
else
  printf 'ok    %s\n' "no files probe is made for the skipped row"; pass=$((pass + 1))
fi

finish
