#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The merge is the assenting act, and the flip it triggers lands on the
# base branch *after* the merge — outside any pull request's diff. So a
# later pull request carries no recorded approval for this check to
# verify, and it must say so rather than demanding a review that the
# flow no longer produces. The stub answers zero reviews, which is the
# real state of every pull request in a repository whose maintainer
# cannot review his own.
setup
stub_gh 0
task_file task-0001 pending spec-0001
spec_file spec-0001 task-0001 draft
commit_all
git checkout -q main
git merge -q --squash feature
git commit -qm "squash: add spec-0001"
# The workflow's own commit: the flip, recorded on the base branch.
bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" "HEAD~1...HEAD" >/dev/null
git add work/specs
git commit -qm "chore(specs): record approval from the merge"
git checkout -qb later
printf '# Product\n\n## Scope\n\nlater work\n' > docs/product/chapter.md
commit_all
check "a merge-recorded flip leaves nothing for the review check" 0 "No approval recorded" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_recorded_approvals.sh" main...HEAD o/r 1

finish
