#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The row skipped for claiming over the ceiling may be the very pull
# request the amendment suspends. Reporting that as "no open pull request
# works it — its flight state is stale" states something this check does
# not know, and turns the cross-reference gate off in silence: an
# amendment then merges without naming the pull request it suspends. The
# skip stays a skip and the act still passes — failing a person's own
# amendment over somebody else's title is the denial the ceiling exists
# to prevent — but the narrow view is said, not dressed as a clean
# answer (spec-0069).
#
# And the notice is owed once per pull request. The lookup runs once per
# suspended task, so a notice printed inside it said the same pull
# request was skipped once for each task that asked.
setup
task_file task-0007 in-progress spec-0009 "" dana
task_file task-0008 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
forge_open_pr 7 task/0007-thing \
  "[TASK-0007][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0008][TASK-0009][TASK-0010][Feat] the work"
export PR_BODY=$'## What\nThe promise was wrong, so the spec goes back to draft.'

out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" \
  main...HEAD o/r 9 2>&1); code=$?

if [ "$code" -eq 0 ]; then
  echo "ok    somebody else's over-long title does not fail this amendment"; pass=$((pass + 1))
else
  echo "FAIL  somebody else's over-long title does not fail this amendment"
  printf '      exit was %s\n' "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if ! printf '%s' "$out" | grep -q "flight state is stale"; then
  echo "ok    and the skipped row is never reported as an absent one"; pass=$((pass + 1))
else
  echo "FAIL  and the skipped row is never reported as an absent one"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if printf '%s' "$out" | grep -q "Skipped for claiming over the ceiling: #7"; then
  echo "ok    the narrow view is said out loud"; pass=$((pass + 1))
else
  echo "FAIL  the narrow view is said out loud"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

n=$(printf '%s\n' "$out" | grep -c "its row is skipped")
if [ "$n" -eq 1 ]; then
  echo "ok    and the skip notice is printed once per pull request"; pass=$((pass + 1))
else
  echo "FAIL  and the skip notice is printed once per pull request"
  printf '      expected 1 notice for two suspended tasks, got %s\n' "$n"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
