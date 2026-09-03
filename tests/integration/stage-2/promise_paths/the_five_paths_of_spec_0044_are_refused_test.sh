#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# report-0005's five real paths, verbatim. Each names a repository-root
# entry, so each resolves to a docs/… path no diff can ever touch — the
# defect that reached an approved spec and was caught by a person
# reading the queue rather than by any check.
setup
mkdir -p .writrun/skills .github/workflows tests/unit template
: > .writrun/skills/keep.md
: > .github/workflows/keep.yml
: > tests/unit/keep.sh
: > template/keep.md
task_file task-0033 ready spec-0044
spec_file spec-0044 task-0033 draft \
  ".writrun/skills/writrun-check-task-state/check_state.sh" \
  ".writrun/skills/writrun-check-task-state/SKILL.md" \
  ".github/workflows/writrun-check.yml" \
  "tests/unit/check_state/" \
  "template/"
commit_all

check "the promise is refused" 1 "REJECTED" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# Each named, and each shown the reading that made it unkeepable.
check "the skill script names its docs/ reading" 1 "docs/.writrun/skills/writrun-check-task-state/check_state.sh" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "the SKILL.md names its docs/ reading" 1 "docs/.writrun/skills/writrun-check-task-state/SKILL.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "the workflow names its docs/ reading" 1 "docs/.github/workflows/writrun-check.yml" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "the test folder names its docs/ reading" 1 "docs/tests/unit/check_state/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD
check "the template folder names its docs/ reading" 1 "docs/template/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# The spec is named, not just the paths: a range may carry several.
check "the spec is named" 1 "spec-0044 promises" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
