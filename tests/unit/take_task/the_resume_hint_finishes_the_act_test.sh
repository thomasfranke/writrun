#!/usr/bin/env bash
# A push that fails leaves a branch with no pull request — the one state
# this act must not leave behind — so the rerun it names has to be one
# that actually finishes it. That means carrying every argument that
# decided the act: `--slug`, which decided the branch's name, and
# `--confirm`, without which a run held by the conduct flags walks back
# into the gate and does nothing. The case runs the printed line.
. "$(dirname "$0")/../../pipeline_lib.sh"

flags() {
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
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": $1,
    "pr_title_style": "conventional"
  }
}
JSON
}

take_setup
flags false
task_file task-001 ready ""
commit_all
publish_main
git remote set-url --push origin "$WORK/nowhere.git"

out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --confirm 2>&1)
code=$?
hint=$(printf '%s\n' "$out" | grep -F -- '--resume' | head -n1)

for want in "--slug mirror-lag" "--confirm"; do
  if [ "$code" -eq 3 ] && printf '%s' "$hint" | grep -qF -- "$want"; then
    printf 'ok    the resume it names carries %s\n' "$want"; pass=$((pass + 1))
  else
    printf 'FAIL  the resume it names carries %s (exit %s)\n' "$want" "$code"
    printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
  fi
done

# The assertion the two above only stand in for: the printed line, run
# as printed, finishes the act it left half done.
git remote set-url --push origin "$WORK/origin.git"
eval "$hint" >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  printf 'ok    and running it as printed finishes the act\n'; pass=$((pass + 1))
else
  printf 'FAIL  and running it as printed finishes the act\n'
  printf '      | hint was: %s\n' "$hint"; fail=$((fail + 1))
fi
if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  printf 'ok    the branch reached the remote\n'; pass=$((pass + 1))
else
  printf 'FAIL  the branch reached the remote\n'; fail=$((fail + 1))
fi
if grep -q 'pr create' "$FORGE_LOG"; then
  printf 'ok    and the draft pull request was opened\n'; pass=$((pass + 1))
else
  printf 'FAIL  and the draft pull request was opened\n'; fail=$((fail + 1))
fi

# The sequence report-0026 recorded: the push succeeds, `gh pr create`
# fails, and the script prints the one state it must never leave behind
# — a branch on the forge with no pull request — with a hint. The hint,
# run as printed, has to open the draft; before spec-0071 it was refused
# by --resume's own remote-ref guard, which the push itself had armed.
take_setup
task_file task-001 ready ""
commit_all
publish_main
forge_refuses "pr create"
out=$(bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag 2>&1)
code=$?
hint=$(printf '%s\n' "$out" | grep -F -- '--resume' | head -n1)
if [ "$code" -eq 3 ] && printf '%s' "$out" | grep -qF "has no pull request"; then
  printf 'ok    a failed pr create names the pushed branch without one\n'; pass=$((pass + 1))
else
  printf 'FAIL  a failed pr create names the pushed branch without one (exit %s)\n' "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail + 1))
fi

forge_allows "pr create"
eval "$hint" >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  printf 'ok    and the printed line, run verbatim, finishes the act\n'; pass=$((pass + 1))
else
  printf 'FAIL  and the printed line, run verbatim, finishes the act\n'
  printf '      | hint was: %s\n' "$hint"; fail=$((fail + 1))
fi
if grep -q 'pr create --draft' "$FORGE_LOG" \
   && [ "$(git rev-list --count origin/main..task/0001-mirror-lag)" = 1 ]; then
  printf 'ok    with the draft open and no second commit\n'; pass=$((pass + 1))
else
  printf 'FAIL  with the draft open and no second commit\n'
  sed 's/^/      | /' "$FORGE_LOG"; fail=$((fail + 1))
fi

finish
