#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The mirror this PR introduced is not an ownership question, and the
# adoption path must not turn it into one: no state read, no body
# rewrite, no relabelling — exactly what it did before.
#
# The state read is named by the fields it asks for, not by its endpoint.
# Two reads share `repos/o/r/pulls/7`: `pr_is_open`'s, which is the one
# this case is about, and the link's, which every run makes once before
# any mirror is looked at. Pinning the endpoint alone made the second
# trip the first.
setup_forge
added_task task-001 "Mine all along"
forge_issue 12 open "writrun:task,status:proposed" "task-001 — Mine all along" 7
check "this PR's own mirror is left alone" 0 \
  "task-001 already mirrored; nothing to do." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "no pull request state is read" "repos/o/r/pulls/7 --jq .state"
forge_not_told "the mirror is not rewritten" "repos/o/r/issues/12"

finish
