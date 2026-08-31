#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The squash puts the title into the authority branch's history, so a
# title in the other style is a permanent entry in a log the project
# decided would read one way. The style is declared; this is what makes
# the declaration bind.
setup

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
commit_all

PR_TITLE="[TASK-0007] feat(ci): record approval on the merge" \
check "a conventional title with a task tag passes" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="docs(product): the merge is the assenting act" \
check "and so does a tagless authoring title" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007] chore: no scope when the change spans everything" \
check "the scope is optional" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007][TASK-0009] fix(specs): two tags, one grammar" \
check "and several tags strip the same way" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

PR_TITLE="[TASK-0007][Fix][CI] Debounce mirror updates" \
check "the other style is rejected, and named" 1 \
  "does not read as the declared 'conventional' style" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007] Debounce mirror updates" \
check "and so is a bare sentence" 1 "declared 'conventional' style" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007] tweak(ci): a type nobody declared" \
check "a type outside the vocabulary is named" 1 \
  "type 'tweak' is outside the vocabulary" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007] fix(frontend): a scope nobody declared" \
check "and so is a scope outside it" 1 \
  "scope 'frontend' is outside the vocabulary" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0007]" \
check "a title that is nothing but tags is rejected" 1 \
  "nothing but task tags" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The same file, the other declaration: the grammar follows the setting,
# which is the whole point of checking it rather than fixing one style.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "bracketed"
  }
}
JSON
commit_all

PR_TITLE="[TASK-0012][Fix][CI] Debounce mirror updates" \
check "a bracketed title with a task tag passes" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[DOCS] The merge is the assenting act" \
check "an authoring title's shouted type is not a style error" 0 \
  "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0012][Feat] The scope is optional here too" \
check "the scope is optional" 0 "the title observes" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

PR_TITLE="[TASK-0012] fix(ci): debounce mirror updates" \
check "the conventional style is now the rejected one" 1 \
  "does not read as the declared 'bracketed' style" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0012][Tweak][CI] A type nobody declared" \
check "a type outside the vocabulary is named" 1 \
  "type 'Tweak' is outside the vocabulary" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_TITLE="[TASK-0012][Fix][Frontend] A scope nobody declared" \
check "and so is a scope outside it" 1 \
  "scope 'Frontend' is outside the vocabulary" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

finish
