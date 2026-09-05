#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule L — a task whose spec is still owed is held out of selection by
# the gate, not by an agent remembering the rule. What passed before it:
# a reporting change adds an `origin: report` task with `spec_ref: []`,
# leaves it `backlog`, adds no spec, and every check is green. The merge
# moves it `backlog → ready`, because a task referencing no spec passes
# the approval filter by construction — and it is then selectable against
# a brief nothing bounded. The cost lands later and on someone else: the
# spec drafted mid-flight merges `approved`, and its **Proposed changes**
# become a completion contract the work never targeted.
#
# `spec_ref: []` alone cannot tell "the spec is owed" from "no spec is
# warranted", and under `spec_required: when-warranted` both are
# legitimate. So the rule is scoped to what the change *declares*, in two
# halves like rule K: the file half needs only the range, the declaration
# half needs the pull request body and stands down out loud without one.
#
# Every case here is a reporting change — `origin: report` on a report/
# branch carrying only work/ — because rule K refuses that task anywhere
# else, and a case fighting two rules at once proves neither.
export HEAD_REF=report/a-finding

# blocked_because <task-id> <reason> — the one front-matter field the
# shared fixture pins to null. A task held for a spec has to be able to
# say what it is held for; that is the whole of the file half.
blocked_because() {
  sed "s/^blocked_reason: null\$/blocked_reason: $2/" "work/tasks/$1.md" \
    > "work/tasks/$1.md.tmp"
  mv "work/tasks/$1.md.tmp" "work/tasks/$1.md"
}

# --- the pair travelling together, which is the default route ----------

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
spec_file spec-0001 task-0001 draft
commit_all
unset PR_BODY
check "a task landing with its spec passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

# The pairing is `task_ref` resolving, never "a spec file appeared in the
# diff": one task's spec must not answer for a second task's silence.
setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
task_file task-0002 backlog "" null null report
spec_file spec-0001 task-0001 draft
commit_all
export PR_BODY="## What
Two findings, one spec."
check "a sibling's spec does not answer for the task without one" 1 \
  "task-0002" -- bash "$CHECK_STATE" main...HEAD

# --- the file half, at every stage --------------------------------------

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 blocked "" null null report
blocked_because task-0001 "waiting on the spec, drafted in a change of its own"
commit_all
unset PR_BODY
check "blocked with a reason naming the spec passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 blocked "" null null report
commit_all
unset PR_BODY
check "blocked with a null reason is refused" 1 "born blocked with no blocked_reason" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the declaration half, Stage 2+ -------------------------------------

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
commit_all
export PR_BODY="## What
A finding worth acting on, with a spec to follow."
check "backlog with no spec and no word about it is refused" 1 \
  "lands backlog with no spec" -- bash "$CHECK_STATE" main...HEAD
check "and the refusal names both ways out" 1 "No spec for task-1" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
commit_all
export PR_BODY="## What
No spec for task-0001 — the rule it violates bounds the fix exactly."
check "a declaration that none is warranted passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

# The line names one task, because the judgement is one task's. A change
# landing two tasks and declaring one still owes an answer for the other.
setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
task_file task-0002 backlog "" null null report
commit_all
export PR_BODY="## What
No spec for task-0001 — the rule it violates bounds the fix exactly."
check "a declaration for one task does not cover another" 1 "task-0002" \
  -- bash "$CHECK_STATE" main...HEAD

# --- the stand-down -----------------------------------------------------

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
commit_all
unset PR_BODY
check "an unreadable declaration stands the half down, out loud" 0 \
  "the declaration half stood down" -- bash "$CHECK_STATE" main...HEAD

# An empty body is not an unreadable one. It was read, and it carries no
# declaration — collapsing the two would pass every empty body there is.
setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
commit_all
export PR_BODY=""
check "an empty body is a body that declares nothing" 1 \
  "lands backlog with no spec" -- bash "$CHECK_STATE" main...HEAD

# --- the stage line -----------------------------------------------------
#
# Below Stage 2 there is no pull request to carry a declaration, so the
# declaration half stands down the way E, F and K do — silently, because
# a stage a rule does not apply at is not a rule that could not be run.
# The file half has no such premise and runs anyway.

stage_one_settings() {
  settings_file <<'JSON'
{
  "stage": 1,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  }
}
JSON
}

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 backlog "" null null report
stage_one_settings
commit_all
unset PR_BODY
check "at stage 1 a backlog task with no spec is not the gate's business" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 tracked task-0001 2026-08-22T00:00:00Z
task_file task-0001 blocked "" null null report
stage_one_settings
commit_all
check "but a null blocked_reason is refused at stage 1 too" 1 \
  "born blocked with no blocked_reason" -- bash "$CHECK_STATE" main...HEAD

# --- what rule L does not judge -----------------------------------------

setup
task_file task-0001 backlog "" null null rule
commit_all
export PR_BODY="## What
A rule-derived task, whose spec was the authoring change's to create."
check "a rule-derived task is not rule L's to judge" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

# A task the base branch already holds is not this change's to answer
# for. Judging it would refuse every unrelated pull request that happens
# to touch the queue.
setup
report_file report-0001 open
task_file task-0001 backlog "" null null report
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf '\nA later note.\n' >> work/tasks/task-0001.md
commit_all
export PR_BODY="## What
Editing a task the base branch already held."
check "a task the base branch holds is left alone" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

unset PR_BODY HEAD_REF
finish
