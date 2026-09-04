#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A survivor for one carried task says nothing about another, so the
# close asks the forge per task: the one still worked is re-recorded
# from its survivor, the one nobody works lands.
setup
task_file task-0021 in-progress "" null somebody
task_file task-0022 in-progress "" null somebody

# A `gh` that answers the survivor query for one task only. The query
# names its task number in the jq filter, and the answer comes back
# post-jq — the shape the script asks the real forge for.
mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'^task/0*21-'*) echo "rescuer false" ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0021-the-work"
export PR_TITLE="[TASK-0021][TASK-0022][Feat][Ci] The pair"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false
export GH_TOKEN=t GH_REPO=o/r
check "the carried task with a survivor is re-recorded, not landed" 0 \
  "a surviving pull request still works task-21" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "its taken_by follows that survivor" task-0021 taken_by rescuer
task_field "and it stays in flight" task-0021 status in-review
task_field "the carried task nobody survives lands" task-0022 status ready
task_field "and its taken_by clears" task-0022 taken_by null
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
