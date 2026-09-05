#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `author.login` comes back empty for a pull request whose author deleted
# their account, and `@tsv` emits that as two adjacent tabs. A tab is an
# IFS *whitespace* character, so `IFS=$TAB read` would fold the pair into
# one separator and every field after the gap would shift up by one: the
# tag-carried row below would lose its title and land task-31, and the
# branch-carried row would hand `false` to the reader as a login and
# write it into `taken_by`. The row is split field by field for exactly
# this reason, so an empty field stays an empty field.
#
# The run is then loud, and that is the outcome being pinned: a survivor
# whose author has no name is a survivor the queue cannot re-record from,
# so `flip_task_status.sh take` refuses it and neither task is landed.
# Landing one is what the shift did silently.
setup
task_file task-0031 in-progress "" null somebody
task_file task-0033 in-progress "" null somebody

mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'pr list'*)
    printf '12\tdocs/an-aside\t\tfalse\t[TASK-0031][Feat][Ci] The aside\n'
    printf '13\ttask/0033-again\t\tfalse\t[Fix][Ci] The retake\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0031-the-work"
export PR_TITLE="[TASK-0031][TASK-0033][Feat][Ci] The pair"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
export GH_TOKEN=t GH_REPO=o/r
check "a nameless survivor is found, and refused loudly rather than landed" 1 \
  "a surviving pull request still works task-31" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the tag-carried task keeps its title's survivor" \
  task-0031 status in-progress
task_field "so it is not landed" task-0031 taken_by somebody
task_field "the branch-carried task is not landed either" \
  task-0033 status in-progress
task_field "and no draftness field is read as its author" \
  task-0033 taken_by somebody
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
