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
check "no readable name skips the branch half out loud" 0 "the branch half skipped" \
  -- bash "$CHECK_STATE" main...HEAD

# --- (b): what the change carries ---------------------------------------
#
# The half the rename cannot clear. An implementing change carries code
# whatever its branch is called, so the diff answers what the name only
# claims — report-0003's failure was reached *through* the name check.

setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
printf 'implementation\n' >> docs/product/chapter.md
commit_all
check "a report/ branch carrying a permanent doc is still refused" 1 "carrying more than reporting" \
  -- bash "$CHECK_STATE" main...HEAD
check "and the refusal names what it carries" 1 "docs/product/chapter.md" \
  -- bash "$CHECK_STATE" main...HEAD

# The same flip with the implementation taken out. This is the pair that
# shows the rule reads the diff and not the branch's history.
setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "the same diff carrying only work/ passes" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# The route recording further reports on its own branch: all under work/,
# and it must stay legal — the change that routed report-0006 also
# recorded report-0009 and report-0010.
setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
git branch -m report/something-seen
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
report_file report-0002 open
task_file task-0001 backlog "" null null report
commit_all
check "the report, the task and further reports travel together" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the exemption is unchanged by (b) ----------------------------------
#
# The rule fires on the tracked route and on nothing else, so a change
# editing a permanent doc still carries the three ends that create no
# work. A rule shaped "a report/ branch touches only work/" would refuse
# report-0001's own `fixed`, whose whole outcome was a one-word change to
# a script.

for end in authored fixed declined; do
  setup
  report_file report-0001 open
  commit_all
  git checkout -q main; git merge -q feature; git checkout -q feature
  git branch -m report/something-seen
  report_file report-0001 "$end" "" 2026-08-23T00:00:00Z
  printf 'the fix itself\n' >> docs/product/chapter.md
  commit_all
  check "${end} rides a change that edits a permanent doc" 0 "no forbidden lifecycle" \
    -- bash "$CHECK_STATE" main...HEAD
done

# --- (b) on the skip path -----------------------------------------------
#
# The branch half needs a name and can be left without one; the diff half
# needs only the diff. So a detached HEAD is not a pass — it is half a
# stand-down, announced, with the other half still judging.

setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
printf 'implementation\n' >> docs/product/chapter.md
commit_all
git checkout -q --detach
check "a detached HEAD carrying code is still refused" 1 "carrying more than reporting" \
  -- bash "$CHECK_STATE" main...HEAD
check "and says which half stood down" 1 "the branch half skipped" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the task half reads the diff too -----------------------------------
#
# Judged on the task rather than only on the report because the two are
# separable: a report tracked in one change and its task added in the
# next would pass a rule watching the status line alone. Every case below
# adds the task without any report flip in the range, which is exactly
# that shape.

setup
git branch -m report/something-seen
task_file task-0001 backlog "" null null report
printf 'implementation\n' >> docs/product/chapter.md
commit_all
check "a task born of a report beside code is refused on a report/ branch" 1 "carrying more than reporting" \
  -- bash "$CHECK_STATE" main...HEAD
check "and the refusal names what it carries" 1 "docs/product/chapter.md" \
  -- bash "$CHECK_STATE" main...HEAD

setup
git branch -m report/something-seen
task_file task-0001 backlog "" null null report
commit_all
check "the same task carrying only work/ passes" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-0001 backlog "" null null report
printf 'implementation\n' >> docs/product/chapter.md
commit_all
git checkout -q --detach
check "a detached HEAD minting a task beside code is refused" 1 "carrying more than reporting" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-0001 backlog "" null null report
commit_all
git checkout -q --detach
check "and a work/-only one passes with the branch half skipped" 0 "the branch half skipped" \
  -- bash "$CHECK_STATE" main...HEAD

finish
