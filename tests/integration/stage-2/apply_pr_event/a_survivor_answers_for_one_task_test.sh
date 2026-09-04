#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A survivor for one carried task says nothing about another, so the
# close asks the forge per task: the one still worked is re-recorded
# from its survivor, the one nobody works lands.
setup
task_file task-0021 in-progress "" null somebody
task_file task-0022 in-progress "" null somebody

# A `gh` that answers with one open-pull-request listing, which is what
# the script asks for: the filter is the reader's, so the same answer
# has to serve every carried task. The answer comes back post-jq — the
# shape the script asks the real forge for — one line per pull request,
# `number headRefName login isDraft`. Only task-21 has one here.
#
# The call count is asserted below, so the stub records every call.
mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$WORK/gh.log"
case "$*" in
  *'pr list'*) echo "7 task/0021-the-rescue rescuer false" ;;
esac
exit 0
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"
export WORK

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

# Two carried tasks, one listing. Asking per task would fetch the same
# answer twice, and no two of those answers could differ.
calls=$(grep -c 'pr list' "$WORK/gh.log")
if [ "$calls" -eq 1 ]; then
  printf 'ok    %s\n' "and the two of them cost one listing"; pass=$((pass + 1))
else
  printf 'FAIL  %s\n      %s calls\n' "and the two of them cost one listing" "$calls"
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
unset PR_HEAD_REF PR_TITLE PR_AUTHOR PR_DRAFT PR_MERGED GH_TOKEN GH_REPO

finish
