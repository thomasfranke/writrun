#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# An open pull request that carries no task — a report branch with an
# untagged title — answers for no task, whatever its number or its text
# spells: its carried set is empty, and the membership test is
# field-wise, never a substring of the row. The row's number even spells
# a carried task's id here, and still claims nothing.
setup
task_file task-0041 in-progress "" null somebody
task_file task-0042 in-progress "" null somebody

mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'pr list'*)
    printf '42\treport/session-notes\twriter\tfalse\tRecord what the session observed\n'
    printf '9\ttask/0041-again\trescuer\tfalse\t[Fix][Ci] The retake\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0041-the-work"
export PR_TITLE="[TASK-0041][TASK-0042][Feat][Ci] The pair"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
export GH_TOKEN=t GH_REPO=o/r
check "the close applies with a no-task row in the listing" 0 \
  "still works task-41" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the task a real survivor carries follows it" task-0041 taken_by rescuer
task_field "and stays in flight" task-0041 status in-review
task_field "the task only the no-task row could have claimed lands" task-0042 status ready
task_field "and its taken_by clears" task-0042 taken_by null
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
