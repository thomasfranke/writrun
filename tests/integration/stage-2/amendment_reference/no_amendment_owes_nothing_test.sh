#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A spec edited without leaving `approved` is not an amendment, and the
# status is read from the front matter at both ends — never grepped out of
# the diff, where a body line quoting `status: draft` is prose.
setup
task_file task-0007 in-progress spec-0009 "" dana
spec_file spec-0009 task-0007 approved
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf '\nstatus: draft\n' >> work/specs/spec-0009.md
commit_all
stub_forge
export PR_BODY=$'## What\nA note in the body.'
check "a spec still approved is no amendment" 0 "returns no approved spec to draft" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_amendment_reference.sh" main...HEAD o/r 9
forge_untouched "and the forge is never asked"

finish
