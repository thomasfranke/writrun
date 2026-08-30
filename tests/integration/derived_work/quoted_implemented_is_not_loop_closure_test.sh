#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# An authoring change cannot dress up as loop closure by quoting
# `status: implemented` in a spec body: the implementing-change detection
# reads the front matter at both ends of the range, and this spec's never
# left draft — so the doc edit still owes its derived-work declaration.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf '\na new rule\n' >> docs/product/chapter.md
printf 'status: implemented\n' >> work/specs/spec-001.md
commit_all
check "a quoted implemented line is not loop closure" 1 "neither adds a task" \
  -- env PR_BODY= bash "$CI_SCRIPTS/stage-2-pull-requests/check_derived_work.sh" main...HEAD

finish
