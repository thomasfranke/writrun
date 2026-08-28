#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending "spec-001, spec-002"
spec_file spec-001 task-001 approved product/chapter.md
spec_file spec-002 task-001 approved about.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented product/chapter.md
spec_file spec-002 task-001 implemented about.md
task_file task-001 completed "spec-001, spec-002" 2026-08-22
printf 'edit\n' >> docs/product/chapter.md
printf 'edit\n' >> docs/about.md
commit_all
check "both implemented specs are collected into one union check" 0 "spec-001,spec-002" \
  -- bash "$CI_SCRIPTS/pull-requests/check_promised_deltas.sh" main...HEAD

finish
