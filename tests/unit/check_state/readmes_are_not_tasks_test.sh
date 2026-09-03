#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Selection reads the filename's id, not the directory a file sits in
# (spec-0057). A queue README carries no front matter and no id-shaped
# name; a check that read it by directory alone would find an empty
# status and refuse it as a task born in the wrong state — exactly
# report-0013's failure, hit by every adopter's first pull request
# because that is the one diff where all three READMEs are "added".

readme() {
  mkdir -p "$(dirname "$1")"
  printf '# %s\n\nNot a task, a spec, or a report — the folder note.\n' "$1" > "$1"
}

setup
readme work/tasks/README.md
readme work/specs/README.md
readme work/reports/README.md
commit_all
check "all three READMEs, added together as a first adoption does" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

setup
readme work/tasks/README.md
commit_all
check "work/tasks/README.md alone" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

setup
readme work/specs/README.md
commit_all
check "work/specs/README.md alone" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

setup
readme work/reports/README.md
commit_all
check "work/reports/README.md alone" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

# The narrowed glob changes which files reach the rules, not what the
# rules do once a real task reaches them: a task still has to be born
# backlog or blocked, whatever else entered alongside it.
setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved
commit_all
check "a real task born in-progress is still refused" 1 "enters the tree already 'in-progress'" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 backlog spec-001
spec_file spec-001 task-001 draft
commit_all
check "a real task born backlog still passes" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

finish
