#!/usr/bin/env bash
# Resuming is not taking. A branch that already exists — locally or on
# the forge — is named and the run stops; the one carve-out is a local
# branch with no pull request, which is the leftover of an interrupted
# take and what --resume finishes, wherever the branch got to. It used
# to be narrower — "no upstream and no pull request" — until report-0026
# showed the push arming the very guard the printed recovery then hit.
#
# "No pull request" is asked of this repository and answered on evidence.
# Branch names are deterministic, so an ended flight's pull request keeps
# naming a branch every later take cuts again, and a fork's pull request
# can name it too: what refuses a resume is the commit the flight ended
# on, not the name it used.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main
git branch task/0001-mirror-lag main
check "an existing local branch is refused" 1 "already exists locally" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
forge_untouched "and the forge was never called"

take_setup
task_file task-001 ready ""
commit_all
publish_main
git branch task/0001-mirror-lag main
git push -q origin task/0001-mirror-lag
git branch -D task/0001-mirror-lag >/dev/null
git fetch -q origin
check "one that exists only on the forge is refused" 1 "already exists on the forge" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag

take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main && git switch -q main
check "--resume finishes an interrupted take" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null \
   && grep -q 'pr create --draft' "$FORGE_LOG"; then
  echo "ok    with the push and the pull request, and no second branch"; pass=$((pass + 1))
else
  echo "FAIL  with the push and the pull request, and no second branch"; fail=$((fail + 1))
fi

check "--resume with nothing to finish is refused" 1 "does not exist locally" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug nothing-here --resume

# The half the act can actually leave behind: pushed, and no pull
# request anywhere. The resume finishes it — same branch, same commit,
# the push a no-op and the draft opened.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
check "--resume finishes a branch already on the forge" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create --draft' "$FORGE_LOG" \
   && [ "$(git rev-list --count origin/main..task/0001-mirror-lag)" = 1 ] \
   && [ "$(git -C "$WORK/origin.git" rev-list --count main..task/0001-mirror-lag)" = 1 ]; then
  echo "ok    with the draft open, no second branch and no second commit"; pass=$((pass + 1))
else
  echo "FAIL  with the draft open, no second branch and no second commit"; fail=$((fail + 1))
fi

# A pull request that already carries the task is the act completed:
# what refuses the rerun is the forge read, not the branch's location.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_open_pr 7 task/0001-mirror-lag "[TASK-0001] feat(ci): take it" alice
check "a resume over a task in flight is refused, naming the pull request" 1 \
  "already in flight on pull request #7 (by @alice)" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume

# A closed pull request means the flight ended and the task went back to
# ready: finishing the branch now would open a second draft over a base
# as old as the interruption. An ended flight is never resumed.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_closed_pr 9 task/0001-mirror-lag
check "a resume over an ended flight is refused, naming the closed pull request" 1 \
  "pull request #9 carried task/0001-mirror-lag and is closed" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create' "$FORGE_LOG"; then
  echo "FAIL  and nothing was opened"; fail=$((fail + 1))
else
  echo "ok    and nothing was opened"; pass=$((pass + 1))
fi
if [ "$(git -C "$WORK/origin.git" rev-list --count main..task/0001-mirror-lag)" = 1 ] \
   && [ "$(git rev-parse task/0001-mirror-lag)" = "$(git -C "$WORK/origin.git" rev-parse task/0001-mirror-lag)" ]; then
  echo "ok    and nothing was pushed"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was pushed"; fail=$((fail + 1))
fi
# The refusal is a dead end unless it names a way out: the resume is
# refused here, and the fresh take it recommends is refused on the
# branch that still exists. So it prints the deletions the fresh take
# needs, and the take itself, and the case runs all three.
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume 2>&1)
for want in "git branch -D task/0001-mirror-lag" "git push origin --delete task/0001-mirror-lag"; do
  if printf '%s' "$out" | grep -qF -- "$want"; then
    printf 'ok    and the way out it prints names: %s\n' "$want"; pass=$((pass + 1))
  else
    printf 'FAIL  and the way out it prints names: %s\n' "$want"
    printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
  fi
done
fresh=$(printf '%s\n' "$out" | grep -F -- '--title' | grep -v -- '--resume' | head -n1)
git branch -D task/0001-mirror-lag >/dev/null 2>&1
git push -q origin --delete task/0001-mirror-lag 2>/dev/null
eval "$fresh" >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  printf 'ok    and the whole way out, run as printed, takes the task\n'; pass=$((pass + 1))
else
  printf 'FAIL  and the whole way out, run as printed, takes the task\n'
  printf '      | fresh take was: %s\n' "$fresh"; fail=$((fail + 1))
fi

# The name is deterministic, so an ended flight's pull request keeps
# naming a branch every later take cuts again. What the refusal turns on
# is the commit that flight ended on: a branch that does not carry it is
# not that flight, and refusing it would burn the name for good. This is
# report-0026's sequence over a name a closed pull request once used.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
# Dated back, because the flight that ended is an earlier take: an empty
# commit made in the same second as the fresh one, over the same tree and
# under the same message, is the same object and nothing could tell them
# apart.
GIT_AUTHOR_DATE="2020-01-01T00:00:00Z" GIT_COMMITTER_DATE="2020-01-01T00:00:00Z" \
  git commit -q --allow-empty -m "chore(tasks): take task-0001"
ended_at=$(git rev-parse HEAD)
git switch -q main
git branch -D task/0001-mirror-lag >/dev/null
forge_closed_pr 9 task/0001-mirror-lag CLOSED "$ended_at" "2020-06-01T00:00:00Z"
forge_refuses "pr create"
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1)
hint=$(printf '%s\n' "$out" | grep -F -- '--resume' | head -n1)
forge_allows "pr create"
eval "$hint" >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  printf 'ok    a fresh branch is not refused by an ended flight of the same name\n'; pass=$((pass + 1))
else
  printf 'FAIL  a fresh branch is not refused by an ended flight of the same name\n'
  printf '      | hint was: %s\n' "$hint"; fail=$((fail + 1))
fi
# Twice: the attempt the forge refused, and the one the resume made. The
# log keeps refused calls too, so a bare grep would pass on the first.
if [ "$(grep -c 'pr create --draft' "$FORGE_LOG")" = 2 ]; then
  printf 'ok    and the draft it could not open the first time is open\n'; pass=$((pass + 1))
else
  printf 'FAIL  and the draft it could not open the first time is open\n'
  sed 's/^/      | /' "$FORGE_LOG"; fail=$((fail + 1))
fi

# The same, where the ended flight's commit is no longer in this clone.
# The close's timestamp is what is left: a branch whose tip was made
# after the flight closed was never part of it.
take_setup
task_file task-001 ready ""
commit_all
publish_main
forge_closed_pr 9 task/0001-mirror-lag CLOSED \
  0000000000000000000000000000000000000000 "2000-01-01T00:00:00Z"
forge_refuses "pr create"
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1)
hint=$(printf '%s\n' "$out" | grep -F -- '--resume' | head -n1)
forge_allows "pr create"
eval "$hint" >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  printf 'ok    a tip made after the close is not that flight either\n'; pass=$((pass + 1))
else
  printf 'FAIL  a tip made after the close is not that flight either\n'
  printf '      | hint was: %s\n' "$hint"; fail=$((fail + 1))
fi

# With neither piece of evidence the run cannot tell the two apart, and
# the conservative answer is the refusal — a second draft over a base as
# old as the ended flight is the thing this read exists to prevent.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_closed_pr 9 task/0001-mirror-lag CLOSED null null
check "an ended flight with no evidence either way still refuses" 1 \
  "cannot be told apart from that flight" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume

# The open list is capped repo-wide, and past that cap this take's own
# pull request falls off it. The branch-scoped read still holds it, so
# the refusal is made there rather than deferred to a list that no
# longer answers.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_head_pr 12 task/0001-mirror-lag OPEN "" "" alice
check "an open pull request off the capped list still refuses the resume" 1 \
  "already in flight on pull request #12 (by @alice)" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create' "$FORGE_LOG"; then
  echo "FAIL  and no second pull request was opened over it"; fail=$((fail + 1))
else
  echo "ok    and no second pull request was opened over it"; pass=$((pass + 1))
fi

# `--head` matches a branch *name*, and forks share that namespace with
# the base repository. A fork's ended pull request on this name is not
# this take's flight, and refusing on it would poison a deterministic
# name for every later contributor. The row carries this branch's own
# tip, so nothing but the fork filter can be what lets the resume past.
take_setup
task_file task-001 ready ""
commit_all
publish_main
git switch -q -c task/0001-mirror-lag origin/main
git commit -q --allow-empty -m "chore(tasks): take task-0001"
git push -q -u origin task/0001-mirror-lag
git switch -q main
forge_head_pr 13 task/0001-mirror-lag CLOSED "" "" mallory true
check "a fork's ended pull request does not poison the name" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --resume
if grep -q 'pr create --draft' "$FORGE_LOG"; then
  echo "ok    and the draft opened over this repository's branch"; pass=$((pass + 1))
else
  echo "FAIL  and the draft opened over this repository's branch"; fail=$((fail + 1))
fi

finish
