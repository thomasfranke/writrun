#!/usr/bin/env bash
# Two questions are asked of a finished pull request, and one of them had
# nowhere to be answered: `## How to verify` is the methodology's — the
# gates' result — and `## How to test` is the reviewer's, what to run and
# what to expect back (docs/product/stage-2-pull-requests/body.md).
#
# The fallback body carries the same sections in the same order, so a
# project whose template is missing is not handed a different contract.
. "$(dirname "$0")/../../pipeline_lib.sh"

held() {
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

sections() {   # the body's headings, in the order it composes them
  bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1 \
    | sed -n 's/^  | \(## .*\)$/\1/p' | paste -sd, -
}

# --- the shipped template ---------------------------------------------

take_setup
held
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
publish_main

got=$(sections)
want="## What,## Why,## Spec,## How to verify,## How to test,## Notes"
if [ "$got" = "$want" ]; then
  echo "ok    the template's body carries both questions, verify first"; pass=$((pass + 1))
else
  echo "FAIL  the template's body carries both questions, verify first"
  echo "      want: $want"; echo "      got:  $got"; fail=$((fail + 1))
fi

# The authoring and reporting sections are the other kinds', and this is
# an implementing take.
for gone in "## Derived work" "## Report"; do
  refute "and drops ${gone}, which is another kind's" "$gone" \
    -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
done

# --- and without it ---------------------------------------------------
#
# A project whose template is missing gets the same contract, not a
# smaller one.

rm -f .writrun/templates/pull_request_template.md
got=$(sections)
if [ "$got" = "$want" ]; then
  echo "ok    the fallback body carries the same sections in the same order"
  pass=$((pass + 1))
else
  echo "FAIL  the fallback body carries the same sections in the same order"
  echo "      want: $want"; echo "      got:  $got"; fail=$((fail + 1))
fi
check "and the spec bullet with them" 2 "| - spec-001 — test" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag

finish
