#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The regression, whole. A merge brings in a task and the spec it
# references; the same merge is what approves that spec, so the pull
# request's own patch still reads it `draft`. Every mirror born this way
# was labelled `status:backlog` and stayed there with its specs approved
# — #66, #67, #70 and #71 on this repository, corrected by hand.
#
# This runs the merged close's steps in the order writrun-approve.yml runs
# them, which is the fix: flip, record, mint, project. The assertion is on
# the last write to reach the forge, because "which write is last" is
# exactly what used to be a race between three workflows.
setup_forge
export PR_STATE=closed PR_MERGED=true

git init -q -b main .
git config user.email t@example.com
git config user.name Test
printf 'seed\n' > seed.txt
git add -A && git commit -qm seed

# The merge: the task and its spec enter the queue together, the spec
# still draft — on disk, and in the patch the forge serves.
base_task task-0005 backlog spec-0003
base_spec spec-0003 task-0005 draft
git add -A && git commit -qm merge
RANGE="HEAD~1...HEAD"
added_task task-0005 "Born with a spec" spec-0003
added_spec spec-0003 task-0005 draft

# The mirror the open event minted, wearing the one label no file can
# hold — exactly the state #66 was in when its merge landed.
forge_issue 66 open "writrun:task,status:proposed,origin:rule" \
  "[TASK-0005] Born with a spec"

# 1. flip — the assent the merge carried, written into the spec.
specs=$(bash "$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/flip_approved_specs.sh" \
  "$RANGE" | sed -n 's/^approved //p' | tr '\n' ' ')
check "the merge approves the spec it carried" 0 "approved" \
  -- grep -x "status: approved" work/specs/spec-0003.md

# 2. record — the queue moves, and reports what it had in scope.
OUT=$(mktemp "${TMPDIR:-/tmp}/writrun-out.XXXXXX")
GITHUB_OUTPUT="$OUT" bash \
  "$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/record_task_status.sh" \
  "$RANGE" >/dev/null
scope=$(sed -n 's/^scope=//p' "$OUT")
check "and settles the task to ready" 0 "ready" \
  -- grep -x "status: ready" work/tasks/task-0005.md

# 3. reconcile — existence is all this pass answers now.
check "the merge leaves the label alone" 0 \
  "task-0005 is in the queue; its label is the projection's" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and writes no label set of its own" \
  "PUT repos/o/r/issues/66/labels"

# 4. project — the label, from the queue the recording just wrote.
# shellcheck disable=SC2086
check "and the projection labels it from the file" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r $specs $scope

last_label_write=$(grep -F "issues/" "$FAKE_GH_LOG" | grep -F "labels" | tail -n1)
case "$last_label_write" in
  *"status:ready"*)
    echo "ok    the label that stands is the one the merge caused"; pass=$((pass+1)) ;;
  *)
    echo "FAIL  the label that stands is the one the merge caused"
    printf '      | %s\n' "$last_label_write"; fail=$((fail+1)) ;;
esac

rm -f "$OUT"
finish
