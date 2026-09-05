#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A title is prose: tags ahead of a [Feat][Ci] suffix and a summary full
# of spaces. The rows come back @tsv for exactly this reason — read as
# whitespace-split columns, the summary's words would land in whichever
# fields read next; read as tab-separated fields, the survivor is found
# and its author is its login, never a fragment of its title.
setup
task_file task-0061 in-progress "" null somebody

mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'pr list'*)
    printf '11\tdocs/an-aside\tspacer\tfalse\t[TASK-0061][Feat][Ci] The pull request body names its references\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0061-the-work" PR_TITLE="[Fix][Ci] The close"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
export GH_TOKEN=t GH_REPO=o/r
check "the tag-carried survivor is found behind its prose" 0 \
  "still works task-61" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "taken_by is the row's login field, not its title's text" \
  task-0061 taken_by spacer
task_field "and the task stays in flight" task-0061 status in-review
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
