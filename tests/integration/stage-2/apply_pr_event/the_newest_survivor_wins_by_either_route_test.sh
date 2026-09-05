#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Two open pull requests carry the same closing task — the
# lower-numbered by its head branch, the higher by a title tag alone.
# The newest wins whatever route carries it, so taken_by names the
# tag-route author. Both listing orders are run, so the answer is not an
# artifact of which route the listing happened to put first.
survivor_pair() {   # $1: the listing's rows, in the order the forge returns them
  task_file task-0031 in-progress "" null somebody
  mkdir -p "$WORK/stub-bin"
  printf '#!/usr/bin/env bash\nprintf "%%b\\n" "%s"\nexit 0\n' "$1" \
    > "$WORK/stub-bin/gh"
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
  export PR_HEAD_REF="task/0031-the-work" PR_TITLE="[Fix][Ci] The close"
  export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
  export GH_TOKEN=t GH_REPO=o/r
}
BRANCH_ROW='8\ttask/0031-by-branch\tbrancher\tfalse\t[Feat][Ci] No tags here'
TAG_ROW='12\tdocs/an-aside\ttagger\tfalse\t[TASK-0031][Feat][Ci] Carried by tag alone'

setup
survivor_pair "${BRANCH_ROW}\n${TAG_ROW}"
check "branch row first: the survivor is still found" 0 \
  "still works task-31" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "and the higher-numbered, tag-route one wins" task-0031 taken_by tagger
task_field "keeping the task in flight" task-0031 status in-review
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

setup
survivor_pair "${TAG_ROW}\n${BRANCH_ROW}"
check "tag row first: the survivor is still found" 0 \
  "still works task-31" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "and the same one wins" task-0031 taken_by tagger
task_field "keeping the task in flight either way" task-0031 status in-review
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
