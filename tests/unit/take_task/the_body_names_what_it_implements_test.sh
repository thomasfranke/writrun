#!/usr/bin/env bash
# A body that names `spec-0059, spec-0060` has told the reviewer two
# numbers. So the composed `## Spec` carries a bullet per spec: the id,
# the spec's own title, and a link that opens the file on main — the
# authority branch, because a squash merge deletes the head one
# (docs/product/stage-2-pull-requests/body.md).
#
# Composition never fails a take. Every part degrades to the one above
# it, because the act is the branch reaching the forge with a draft on
# it, and a take that refused over a heading it could not parse would
# trade the act for a bullet.
. "$(dirname "$0")/../../pipeline_lib.sh"

held() {   # the composition, printed and nothing acted on
  settings_file <<JSON
{
  "stage": 2,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": false,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
}

compose() {   # compose <task-id> — the body the act would open with
  bash "$TAKE_TASK" "$1" --title "feat(ci): take it" --slug mirror-lag 2>&1
}

# --- the linked shape -------------------------------------------------

take_setup
held
task_file task-001 ready "spec-001,spec-002"
spec_file spec-001 task-001 approved
spec_file spec-002 task-001 approved
commit_all
publish_main

export WRITRUN_ORIGIN_URL="git@github.com:owner/repo.git"
check "a spec is a bullet with its id, its title and a link" 2 \
  "| - \[spec-001\](https://github.com/owner/repo/blob/main/work/specs/spec-001.md) — test" \
  -- compose task-001
check "and the second one too" 2 \
  "| - \[spec-002\](https://github.com/owner/repo/blob/main/work/specs/spec-002.md) — test" \
  -- compose task-001
refute "the placeholder the template ships is gone" "spec-NNNN" -- compose task-001

# spec_ref order is the body's order: the list is the author's statement
# of which spec leads, and re-sorting it would be this script's opinion.
order=$(compose task-001 | sed -n 's/^  | - \[\(spec-00[0-9]\)\].*/\1/p' | paste -sd, -)
if [ "$order" = "spec-001,spec-002" ]; then
  echo "ok    in spec_ref order"; pass=$((pass + 1))
else
  echo "FAIL  in spec_ref order"; echo "      got: $order"; fail=$((fail + 1))
fi

# The two remote forms are one repository, so they are one URL.
export WRITRUN_ORIGIN_URL="https://github.com/owner/repo"
check "the https remote form yields the same URL" 2 \
  "https://github.com/owner/repo/blob/main/work/specs/spec-001.md" \
  -- compose task-001
export WRITRUN_ORIGIN_URL="https://github.com/owner/repo.git/"
check "and so does one with a .git suffix and a trailing slash" 2 \
  "https://github.com/owner/repo/blob/main/work/specs/spec-001.md" \
  -- compose task-001

# --- the unlinked fallback --------------------------------------------
#
# This blob path shape is GitHub's. Composing one for a remote somewhere
# else would write a dead link that reads as live until it is clicked,
# and an unlinked bullet still carries the id and the title.

export WRITRUN_ORIGIN_URL="https://gitlab.com/owner/repo.git"
check "a remote that is not GitHub yields no link" 2 "| - spec-001 — test" \
  -- compose task-001
refute "and invents no host" "github.com" -- compose task-001
unset WRITRUN_ORIGIN_URL
check "and neither does the suite's own local remote" 2 "| - spec-001 — test" \
  -- compose task-001

# The act still happens. Under-linking is the safe direction, not a
# reason to refuse.
take_setup
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
publish_main
export WRITRUN_ORIGIN_URL="https://gitlab.com/owner/repo.git"
check "a take with no composable URL still opens the draft" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
unset WRITRUN_ORIGIN_URL

# --- a task with no spec ----------------------------------------------

take_setup
held
task_file task-001 ready ""
commit_all
publish_main
check "no spec_ref leaves the sentence that says so" 2 \
  "No spec — the task body and its doc_ref are the brief" \
  -- compose task-001

finish
