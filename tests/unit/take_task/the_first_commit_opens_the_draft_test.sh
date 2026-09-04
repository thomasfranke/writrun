#!/usr/bin/env bash
# A branch identical to origin/main has no commits between the two, and
# the forge refuses a pull request over nothing — so the take commits
# before it pushes. The commit is empty by design: the take produced no
# content, and a commit with no diff is the honest account of that.
#
# It is made once. What makes a second one wrong is that one is already
# there, so the guard reads the range and not the --resume flag.
. "$(dirname "$0")/../../pipeline_lib.sh"

credit() {
  settings_file <<JSON
{
  "stage": 2,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": $1,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
}

# ahead <name> <count> — the commits the branch carries over the base it
# was cut from, which is the number the forge counts before it agrees to
# open anything.
ahead() {
  local got
  got=$(git rev-list --count origin/main..HEAD)
  if [ "$got" = "$2" ]; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected %s commit(s) ahead, got %s\n' "$1" "$2" "$got"
    fail=$((fail + 1))
  fi
}

# --- the fresh path ---------------------------------------------------

take_setup
task_file task-001 ready ""
commit_all
publish_main

check "the take succeeds" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag

ahead "the branch carries one commit over origin/main" 1

if git diff --quiet HEAD^ HEAD; then
  echo "ok    and it is empty"; pass=$((pass + 1))
else
  echo "FAIL  and it is empty"; git diff --stat HEAD^ HEAD | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if [ "$(git log -1 --format=%s)" = "chore(tasks): take task-0001" ]; then
  echo "ok    under a subject the commit vocabulary accepts"; pass=$((pass + 1))
else
  echo "FAIL  under a subject the commit vocabulary accepts"
  git log -1 --format=%s | sed 's/^/      | /'; fail=$((fail + 1))
fi

# The push is what the commit exists for, so the remote has to have it —
# and the draft has to be asked for, which is the half that failed when
# the branch reached the forge with nothing on it.
if [ "$(git -C "$WORK/origin.git" rev-list --count main..task/0001-mirror-lag)" = 1 ]; then
  echo "ok    and the push carried it to the remote"; pass=$((pass + 1))
else
  echo "FAIL  and the push carried it to the remote"; fail=$((fail + 1))
fi
if grep -q 'pr create --draft' "$FORGE_LOG"; then
  echo "ok    so the act reaches the draft rather than stopping at the push"
  pass=$((pass + 1))
else
  echo "FAIL  so the act reaches the draft rather than stopping at the push"
  sed 's/^/      | /' "$FORGE_LOG"; fail=$((fail + 1))
fi

# --- the credit the pull request declares -----------------------------

take_setup
task_file task-001 ready ""
commit_all
publish_main
check "a take naming its model succeeds" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag \
     --coauthor "Claude Opus 5 <noreply@anthropic.com>"
check "and the first commit carries the trailer" 0 \
  "Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>" \
  -- git log -1 --format=%B HEAD

take_setup
credit false
task_file task-001 ready ""
commit_all
publish_main
check "a project that declares no credit refuses the flag" 1 "agent_coauthor is false" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag \
     --coauthor "Claude Opus 5 <noreply@anthropic.com>"
no_branch_cut "and nothing was cut" "task/0001-mirror-lag"

take_setup
credit false
task_file task-001 ready ""
commit_all
publish_main
check "and without the flag it takes as usual" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
if git log -1 --format=%B | grep -qE '^[[:space:]]*[Cc]o-[Aa]uthored-[Bb]y:'; then
  echo "FAIL  leaving the commit with no trailer at all"
  git log -1 --format=%B | sed 's/^/      | /'; fail=$((fail + 1))
else
  echo "ok    leaving the commit with no trailer at all"; pass=$((pass + 1))
fi

# --- the resumed path -------------------------------------------------
#
# An interrupted take that got as far as committing is finished, not
# given a second marker.

take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git switch -q main
check "--resume finishes a branch that already committed" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
ahead "without a second commit" 1

# The other interruption: cut, and stopped before the commit. There is
# nothing to finish it with unless the resume commits too.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git switch -q main
check "--resume commits where the take never got that far" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
ahead "so the branch it pushes carries one" 1

# The guard reads a range, so a range git cannot answer has to fail
# closed. Defaulting an unreadable count to zero would put the failure on
# the branch that *commits*, producing the second marker this guard is
# the whole of — and the branch here is a resumed one that already has
# its commit, which is exactly the case that must not be doubled.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git switch -q main
git config remote.origin.fetch '+refs/heads/nothing:refs/remotes/origin/nothing'
git update-ref -d refs/remotes/origin/main
check "a range git cannot answer stops the act" 3 "must not guess at" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if [ "$(git rev-list --count task/0001-mirror-lag)" = "$(git rev-list --count main)" ]; then
  echo "FAIL  rather than committing a second time"; fail=$((fail + 1))
else
  if [ "$(git log -1 --format=%s task/0001-mirror-lag)" = "chore(tasks): take task-0001" ] \
     && [ "$(git log -2 --format=%s task/0001-mirror-lag | tail -1)" != "chore(tasks): take task-0001" ]; then
    echo "ok    rather than committing a second time"; pass=$((pass + 1))
  else
    echo "FAIL  rather than committing a second time"
    git log -2 --format=%s task/0001-mirror-lag | sed 's/^/      | /'; fail=$((fail + 1))
  fi
fi

# --- the trailer's own shape ------------------------------------------
#
# The value is written onto the commit verbatim, so it is judged at the
# door that offers the flag rather than at the gate that reads the commit
# hours later. The vocabulary is check_observance.sh's own.

take_setup
task_file task-001 ready ""
commit_all
publish_main
check "a --coauthor with no address is refused" 1 "one line of the form" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag \
     --coauthor "Claude Opus 5"
check "a --coauthor naming a category is refused" 1 "a category rather than a model" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag \
     --coauthor "AI <noreply@anthropic.com>"
check "a --coauthor carrying a second line is refused" 1 "one line of the form" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag \
     --coauthor "$(printf 'Claude Opus 5 <noreply@anthropic.com>\nSigned-off-by: nobody <x@y.z>')"
no_branch_cut "and none of them cut a branch" "task/0001-mirror-lag"

finish
