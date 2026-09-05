#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A survivor for one carried task says nothing about another, so the
# close asks the question per task — and the question reaches every
# route: the survivor here carries task-21 by its head branch and
# task-22 by a title tag alone, so both are re-recorded from it, while
# the third carried task nobody names by either route lands.
setup
task_file task-0021 in-progress "" null somebody
task_file task-0022 in-progress "" null somebody
task_file task-0023 in-progress "" null somebody

# A `gh` that answers with one open-pull-request listing, which is what
# the script asks for: the filter is the reader's, so the same answer
# has to serve every carried task. The answer comes back post-jq — the
# shape the script asks the real forge for — one @tsv row per pull
# request, `number headRefName login isDraft title`, tab-separated
# because a title has spaces of its own.
#
# The call count is asserted below, so the stub records every call.
mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$WORK/gh.log"
case "$*" in
  *'pr list'*)
    printf '7\ttask/0021-the-rescue\trescuer\tfalse\t[TASK-0022][Fix][Ci] The rescue\n' ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"
export WORK

export PR_HEAD_REF="task/0021-the-work"
export PR_TITLE="[TASK-0021][TASK-0022][TASK-0023][Feat][Ci] The trio"
export PR_AUTHOR=somebody PR_DRAFT=false PR_MERGED=false PR_NUMBER=6
export GH_TOKEN=t GH_REPO=o/r
check "the carried tasks with a survivor are re-recorded, not landed" 0 \
  "a surviving pull request still works task-21" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/apply_pr_event.sh" closed
task_field "the branch-carried task follows that survivor" task-0021 taken_by rescuer
task_field "and it stays in flight" task-0021 status in-review
task_field "the tag-carried task follows it too" task-0022 taken_by rescuer
task_field "and it stays in flight as well" task-0022 status in-review
task_field "the carried task nobody survives lands" task-0023 status ready
task_field "and its taken_by clears" task-0023 taken_by null

# Three carried tasks, one listing. Asking per task would fetch the same
# answer three times, and no two of those answers could differ.
calls=$(grep -c 'pr list' "$WORK/gh.log")
if [ "$calls" -eq 1 ]; then
  printf 'ok    %s\n' "and the three of them cost one listing"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n      %s calls\n' "and the three of them cost one listing" "$calls"
  fail=$((fail + 1))
fi

# gh's default page is 30 and the filter is the reader's, so a survivor
# below that line comes back invisible — and an invisible survivor lands
# a task whose work is still open.
if grep -q -- '--limit' "$WORK/gh.log"; then
  printf 'ok    %s\n' "asked for past the forge's default page"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n' "asked for past the forge's default page"
  sed 's/^/      | /' "$WORK/gh.log"; fail=$((fail + 1))
fi
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED PR_NUMBER GH_TOKEN GH_REPO

finish
