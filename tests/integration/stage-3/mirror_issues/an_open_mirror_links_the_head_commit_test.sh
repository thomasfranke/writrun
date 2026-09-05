#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A mirror's opening sentence names the file it mirrors, and that is how
# it says where the authority lives — the Issue is a projection and the
# file is the record. The link used to land on the pull request's
# changed-files view, so the reader did the lookup the sentence exists to
# save, and the more the change carried the worse it read.
#
# The file is not on the base branch while the pull request is open,
# which is why the diff was chosen. But it exists on the head commit from
# the moment the mirror is born, so that is what the link reaches — a
# permalink that resolves at once and keeps resolving after the branch is
# deleted.
setup_forge
forge_head 1a2b3c4d5e6f7890abcdef1234567890abcdef12
added_task task-0004 "Something to do"

check "an open pull request's task mirror is created" 0 \
  "Created issue for task-0004" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "and links the file at the head commit" \
  "blob/1a2b3c4d5e6f7890abcdef1234567890abcdef12/work/tasks/task-0004.md"
forge_not_told "never at the changed-files view" \
  "/pull/7/files"

# The report writer composes the same sentence through the same helper,
# because two writers spelling one sentence twice is one sentence until
# somebody edits half of it.
setup_forge
forge_head 1a2b3c4d5e6f7890abcdef1234567890abcdef12
added_report report-0003 "Something observed"

check "and so is a report's" 0 "Created issue for report-0003" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "linking its file at the same commit" \
  "blob/1a2b3c4d5e6f7890abcdef1234567890abcdef12/work/reports/report-0003.md"
forge_not_told "and not at the diff either" \
  "/pull/7/files"

finish
