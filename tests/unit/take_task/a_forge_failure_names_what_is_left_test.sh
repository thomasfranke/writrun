#!/usr/bin/env bash
# Before the cut, a forge that cannot be reached leaves the repository
# untouched. After it, the branch that exists is named and --resume is
# the stated way to finish — a bare rerun hits the branch-exists refusal
# by design.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main
forge_unavailable
check "an unusable forge exits 3" 3 "gh cannot reach the forge" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
no_branch_cut "and the repository is untouched" "task/0001-mirror-lag"

# The push half fails — a remote that fetches and refuses to be written
# to. The branch is cut and stays local, which is the one state the
# message has to name.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git remote set-url --push origin "$WORK/nowhere.git"
# One run, read twice: a second bare run would hit the branch-exists
# refusal, which is the design and not this assertion's subject.
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1)
code=$?
for want in "kept local" "Finish the act with" "--resume"; do
  if [ "$code" -eq 3 ] && printf '%s' "$out" | grep -qF -- "$want"; then
    printf 'ok    a failed push exits 3 and says: %s\n' "$want"; pass=$((pass + 1))
  else
    printf 'FAIL  a failed push exits 3 and says: %s (exit %s)\n' "$want" "$code"
    printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
  fi
done
check "and --resume retries the push, not the branch" 3 "kept local" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if git rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  echo "ok    and the branch it cut is still there"; pass=$((pass + 1))
else
  echo "FAIL  and the branch it cut is still there"; fail=$((fail + 1))
fi

# After the push, "kept local" is a claim about a branch the forge holds
# — the false sentence report-0026 recorded. What the run has actually
# established is that the branch is on the forge with no pull request on
# it, and that is what it has to say.
take_setup
task_file task-001 ready ""
commit_all
publish_main
forge_refuses "pr create"
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1)
code=$?
for want in "is pushed but has no pull request" "Finish it with" "--resume"; do
  if [ "$code" -eq 3 ] && printf '%s' "$out" | grep -qF -- "$want"; then
    printf 'ok    a failure after the push exits 3 and says: %s\n' "$want"; pass=$((pass + 1))
  else
    printf 'FAIL  a failure after the push exits 3 and says: %s (exit %s)\n' "$want" "$code"
    printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
  fi
done
if printf '%s' "$out" | grep -qF "kept local"; then
  printf 'FAIL  and never calls a pushed branch kept local\n'
  printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
else
  printf 'ok    and never calls a pushed branch kept local\n'; pass=$((pass + 1))
fi
if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  printf 'ok    because the branch really did reach the forge\n'; pass=$((pass + 1))
else
  printf 'FAIL  because the branch really did reach the forge\n'; fail=$((fail + 1))
fi

# A resume's one guard is the forge's answer. Where the open list fails
# — auth fine, that one read refused — the run cannot tell the state it
# recovers from the state it refuses, so it stops before the cut rather
# than opening a second pull request over a branch that may have one.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_refuses "pr list"
check "an unanswered read stops the resume" 3 "went unanswered" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create' "$FORGE_LOG"; then
  echo "FAIL  with nothing pushed and nothing opened"; fail=$((fail + 1))
elif [ "$(git rev-parse task/0001-mirror-lag)" = "$(git -C "$WORK/origin.git" rev-parse task/0001-mirror-lag)" ]; then
  echo "ok    with nothing pushed and nothing opened"; pass=$((pass + 1))
else
  echo "FAIL  with nothing pushed and nothing opened"; fail=$((fail + 1))
fi

# A base that cannot be refreshed is not a base: the eligibility read
# against it would be read against whatever this checkout last saw.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git remote set-url origin "$WORK/nowhere.git"
check "an unfetchable origin exits 3" 3 "git fetch origin main failed" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
no_branch_cut "leaving the repository untouched" "task/0001-mirror-lag"

finish
