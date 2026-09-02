#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule K — recording rides any change, and so do the ends that leave the
# queue untouched; the `tracked` route does not. It is the one route that
# puts work in the queue, and what enters the queue passes a gate: a
# reporting change of its own, whose squash-merge is the assent that the
# finding deserves the work (docs/product/concepts/report.md).
#
# The rule is judged on the branch name, which arrives from the
# environment in CI and from the checkout locally — so both halves of the
# rule and both halves of its input are asserted here.

unset HEAD_REF

# --- the report's status line -------------------------------------------

setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "a tracked flip on a branch about something else is refused" 1 "reaches 'tracked'" \
  -- bash "$CHECK_STATE" main...HEAD

# Born tracked is the same act in one commit rather than two, and the
# rule reads the reached state, not the number of steps taken to it.
setup
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "and so is one that enters the tree already tracked" 1 "reaches 'tracked'" \
  -- bash "$CHECK_STATE" main...HEAD

setup
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "the same diff on a report/ branch is the route's own vehicle" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# A report already tracked on the base and untouched in the range has
# reached nothing here — the flip is history, and history is not a diff.
setup
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'more\n' >> docs/product/chapter.md
commit_all
check "a report tracked before the range began is not re-judged" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the task the route mints -------------------------------------------

setup
git branch -m task/0001-some-work
task_file task-0001 backlog "" null null report
commit_all
check "a task born of a report on a task/ branch is refused" 1 "is born of a report" \
  -- bash "$CHECK_STATE" main...HEAD

setup
git branch -m report/something-seen
task_file task-0001 backlog "" null null report
commit_all
check "and passes on the report/ branch that carries the judgement" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# The other origin is untouched: a task derived from a rule is authoring's
# to mint, and rides the change that authored the rule.
setup
task_file task-0001 backlog "" null null rule
commit_all
check "a task born of a rule is not this rule's business" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the three routes that create no work keep the exemption ------------

for end in authored fixed declined; do
  setup
  report_file report-0001 open
  commit_all
  git checkout -q main; git merge -q feature; git checkout -q feature
  report_file report-0001 "$end" "" 2026-08-23T00:00:00Z
  commit_all
  check "${end} still rides a change about something else" 0 "no forbidden lifecycle" \
    -- bash "$CHECK_STATE" main...HEAD
done

# --- where the branch name comes from -----------------------------------

# CI knows the head branch and the checkout does not, so the environment
# outranks it — in both directions, or it would be a hint rather than the
# input.
setup
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "HEAD_REF outranks the branch the checkout is on" 1 "reaches 'tracked'" \
  -- env HEAD_REF=task/0001-some-work bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "and clears the rule the same way" 0 "no forbidden lifecycle" \
  -- env HEAD_REF=report/something-seen bash "$CHECK_STATE" main...HEAD

# A push event hands the workflow an empty string, which is no name at
# all — the checkout answers instead.
setup
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "an empty HEAD_REF is an unset one, and the checkout answers" 0 "no forbidden lifecycle" \
  -- env HEAD_REF= bash "$CHECK_STATE" main...HEAD

# Neither source has a name: the rule cannot run, and a rule silently
# dropped is worse than one that never existed.
setup
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
git checkout -q --detach
check "no readable name skips the rule out loud" 0 "Rule K skipped" \
  -- bash "$CHECK_STATE" main...HEAD

finish
