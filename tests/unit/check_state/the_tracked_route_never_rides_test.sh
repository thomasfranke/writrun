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

# --- what the rule reads the base at ------------------------------------

# A queue file is never renamed. If one is anyway, the rule must still be
# about the transition and not about the path: reading the base at the
# *current* name answers "it was not there", which is what a birth looks
# like, and a report tracked long ago would be refused for moving.
setup
report_file report-0003 tracked task-0001 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git mv work/reports/report-0003.md work/reports/report-0003-better-slug.md
commit_all
check "a rename is not a report reaching tracked" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the stage the rule belongs to --------------------------------------

# The gate this rule holds the route to is a pull request's squash-merge.
# Below Stage 2 there is none to hold it to: the project has no forge and
# no branches, so the route runs on main, legally.
setup
settings_file <<'JSON'
{
  "stage": 1,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
commit_all
git checkout -q main; git merge -q feature
report_file report-0001 open
commit_all
git tag base0
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
task_file task-0001 backlog "" null null report
commit_all
check "at stage 1 the route runs where the project works" 0 "OK" \
  -- bash "$CHECK_STATE" base0..HEAD

# And stands down without a word: a stage the rule does not apply at is
# not a rule that could not be run, so there is nothing to announce.
refute "and says nothing about skipping" "Rule K skipped" \
  -- bash "$CHECK_STATE" base0..HEAD

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
