#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The listing can lag the forge's own state and still show the closing
# pull request as open. Its row answers for nothing, by any route: the
# event in hand proves it closed, and it is the highest-numbered row
# here on purpose — counted at all, it would out-rank the real survivor
# and re-record every carried task from a closed pull request's author,
# a state no later event of that pull request heals.
setup
task_file task-0051 in-progress "" null somebody
task_file task-0052 in-progress "" null somebody

mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
case "$*" in
  *'pr list'*)
    printf '9\ttask/0051-again\trescuer\tfalse\t[Fix][Ci] The retake\n'
    printf '20\ttask/0051-the-work\tsomebody\tfalse\t[TASK-0051][TASK-0052][Feat][Ci] The pair\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"

export PR_HEAD_REF="task/0051-the-work"
export PR_TITLE="[TASK-0051][TASK-0052][Feat][Ci] The pair"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=20
export GH_TOKEN=t GH_REPO=o/r
check "the close applies with its own row still listed" 0 \
  "still works task-51" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the other open pull request is the survivor" task-0051 taken_by rescuer
task_field "and its task stays in flight" task-0051 status in-review
task_field "the task only the closed row names lands" task-0052 status ready
task_field "with taken_by cleared, never the closed author's" task-0052 taken_by null
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
