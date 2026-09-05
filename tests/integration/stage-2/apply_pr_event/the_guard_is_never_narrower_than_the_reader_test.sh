#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The cheap test that spares `ql_carried_of` a fork must never drop a row
# the helper would have answered for. The helper strips leading
# whitespace before it looks for a tag, so a title that opens with a
# space carries its tags exactly as one that does not — and a guard
# reading only the first character would drop this row and land a task
# whose work is still open.
setup
task_file task-0035 in-progress "" null somebody

mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'pr list'*)
    printf '21\tdocs/an-aside\tspacer\tfalse\t [TASK-0035][Feat][Ci] The aside\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0035-the-work" PR_TITLE="[Fix][Ci] The close"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
export GH_TOKEN=t GH_REPO=o/r
check "a title's leading space does not hide its tag from the guard" 0 \
  "still works task-35" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the survivor is recorded" task-0035 taken_by spacer
task_field "and the task stays in flight" task-0035 status in-review
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
