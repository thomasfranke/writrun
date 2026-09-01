#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Read through the stubbed forge rather than WRITRUN_PR_LIST, because the
# two consumers of `gh pr list` ask for different columns and only the
# fields they request tell them apart. Served the narrower shape, the
# lister reads the title as the author and reports "#7 by @the work".
setup
task_file task-0007 ready spec-0009
spec_file spec-0009 task-0007 approved
stub_forge
forge_open_pr 7 task/0007-thing "the work" dana

check "the lister reads the author the stub served" 1 "#7 by @dana" -- bash "$LIST_TASKS"
refute "and never reads the title as the author" "@the work" -- bash "$LIST_TASKS"

finish
