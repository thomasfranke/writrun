#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The generator is what performs the tracked route — it flips the report,
# stamps `triaged` and writes the task — and the route never rides: what
# enters the queue passes a gate, and the gate is the reporting change's
# own pull request (docs/product/concepts/report.md). `check_state.sh`
# holds the finished diff to that; this holds the run that produces it,
# where the branch is still free to change and nothing has been written.

unset HEAD_REF

setup
git branch -m task/0034-other-work
bash "$NEW_SH" report "The mirror lags" --slug mirror-lag >/dev/null 2>&1
check "the route refuses on a branch about something else" 3 "not a report/ branch" \
  -- bash "$NEW_SH" task "Read the merged ref" --slug merged-ref --from-report report-0001

# A refusal that half-routed the finding would be worse than none: the
# undo is three files by hand, across two directories.
r=work/reports/report-0001-mirror-lag.md
if grep -q '^status: open$' "$r" && grep -q '^triaged: null$' "$r" &&
   grep -q '^task_ref: \[\]$' "$r" && [ -z "$(ls work/tasks)" ]; then
  echo "ok    and writes nothing on the way out"; pass=$((pass + 1))
else
  echo "FAIL  and writes nothing on the way out"
  sed 's/^/      | /' "$r"; ls work/tasks | sed 's/^/      | /'; fail=$((fail + 1))
fi

# The flag is not what the rule is about: `origin: report` is the fact the
# route writes, and a task carrying it is what enters the queue however it
# was asked for.
check "and refuses --origin report with no flag to blame" 3 "not a report/ branch" \
  -- bash "$NEW_SH" task "Reported gap" --origin report --slug reported

# The other origin is authoring's, and rides the change that authored the
# rule — this refusal must not reach it.
setup
git branch -m task/0034-other-work
bash "$NEW_SH" task "Derived rule" --origin rule --slug derived >/dev/null 2>&1
if [ -f work/tasks/task-0001-derived.md ]; then
  echo "ok    a task born of a rule is not this refusal's business"; pass=$((pass + 1))
else
  echo "FAIL  a task born of a rule is not this refusal's business"; fail=$((fail + 1))
fi

# On the branch the route travels, the generator does its whole job.
setup
git branch -m report/something-seen
bash "$NEW_SH" report "The mirror lags" --slug mirror-lag >/dev/null 2>&1
bash "$NEW_SH" task "Read the merged ref" --slug merged-ref \
  --from-report report-0001 >/dev/null 2>&1
if [ -f work/tasks/task-0001-merged-ref.md ] &&
   grep -q '^status: tracked$' work/reports/report-0001-mirror-lag.md; then
  echo "ok    on a report/ branch it routes as before"; pass=$((pass + 1))
else
  echo "FAIL  on a report/ branch it routes as before"; fail=$((fail + 1))
fi

# CI knows the head branch and a checkout may not, so the environment
# outranks it here for the same reason it does in check_state.
setup
git branch -m report/something-seen
check "HEAD_REF outranks the branch the checkout is on" 3 "not a report/ branch" \
  -- env HEAD_REF=task/0034-other-work bash "$NEW_SH" task "Gap" --origin report --slug gap

# Below Stage 2 there is no pull request to be the vehicle. The route runs
# wherever a branchless project works, and the refusal stands down.
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
git checkout -q main
bash "$NEW_SH" task "Reported gap" --origin report --slug reported >/dev/null 2>&1
if [ -f work/tasks/task-0001-reported.md ]; then
  echo "ok    at stage 1 the route mints where the project works"; pass=$((pass + 1))
else
  echo "FAIL  at stage 1 the route mints where the project works"; fail=$((fail + 1))
fi

finish
