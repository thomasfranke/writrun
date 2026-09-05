#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The open listing arrives as tab-delimited rows, and a tab is an IFS
# *whitespace* character: `IFS="$TAB" read` folds a run of tabs into one
# separator, so one empty field shifts every field after it left. Here
# that would put the title where the head branch goes and leave the title
# empty — `ql_carried_of` then finds no task on the row, the row is
# dropped, and the check announces that nothing works a task a pull
# request is working.
#
# **That failure is silent and it is a pass.** The gate does not go red;
# it stops asking, prints "its flight state is stale", and lets an
# amendment merge without naming the pull request it suspends. So the
# assertion is the refusal: the reference is deliberately absent from the
# body, and the check must miss it.
#
# The empty field here is the head branch, because a three-column
# projection is what this consumer asks the forge for. The class is the
# same one `author.login` produces in apply_pr_event's five-column row —
# one reader answers both, which is the whole reason it is one reader.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-0009 task-0007 draft
commit_all
stub_forge
forge_open_pr 7 "" "[TASK-0007][Feat] the work"
export PR_BODY=$'## What\nThe promise was wrong, so the spec goes back to draft.'

out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" \
  main...HEAD o/r 9 2>&1); code=$?

if [ "$code" -eq 1 ] && printf '%s' "$out" | grep -q "task-0007 rides #7"; then
  echo "ok    an empty head branch leaves the title in the title's place"
  pass=$((pass + 1))
else
  printf 'FAIL  an empty head branch leaves the title in the title'"'"'s place (exit %s)\n' "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if ! printf '%s' "$out" | grep -q "flight state is stale"; then
  echo "ok    and the row is never read as a pull request working nothing"
  pass=$((pass + 1))
else
  echo "FAIL  and the row is never read as a pull request working nothing"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
