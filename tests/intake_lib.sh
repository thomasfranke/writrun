#!/usr/bin/env bash
# intake_lib.sh — the fixture behind the intake cases
# (.writrun/scripts/stage-3-github-issues/intake_report.sh) and the
# push_recording cases
# (.writrun/scripts/stage-2-pull-requests/push_recording.sh), which need
# only its authority half.
#
# Two halves, because the intake has two counterparties. The authority
# branch is a real one: a bare `origin`, a clone shaped like the
# workflow's checkout, and a racer clone that lands commits on `origin`
# behind the checkout's back, so a recording's rebase-and-push lands
# where a later reader can assert on it. The forge is the same fake `gh`
# posture as mirror_lib.sh — reads served from canned files, every
# invocation logged, mutations asserted against the log — rebuilt here
# because the intake asks different questions (`gh pr list`, one pull
# request's file list) than the mirror scripts do.
#
# Same constraints as every other fixture: git, bash, POSIX awk/sed, no
# framework (tests/harness.sh has the assertion core).

. "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

INTAKE="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/intake_report.sh"

# A working directory holding the pair of repositories and the fake
# forge; cd's into the clone. The default event is the canonical one —
# the gate's label, a fresh title — and cases override the exported
# ISSUE_* / LABEL_NAME fields they are about.
setup_intake() {
  WORK_PREV="$WORK"
  WORK=$(mktemp -d)
  [ -n "$WORK_PREV" ] && rm -rf "$WORK_PREV"
  cd "$WORK" || exit 1

  git init -q --bare origin.git
  git clone -q origin.git checkout 2>/dev/null
  cd checkout || exit 1
  git config user.email t@example.com
  git config user.name Test
  git symbolic-ref HEAD refs/heads/main
  mkdir -p work/reports work/tasks work/specs
  printf '# reports\n' > work/reports/README.md
  git add -A >/dev/null
  git commit -qm baseline
  git push -q -u origin main 2>/dev/null

  FAKE_GH_DIR="$WORK/forge"
  FAKE_GH_LOG="$WORK/forge/gh.log"
  mkdir -p "$FAKE_GH_DIR"
  : > "$FAKE_GH_LOG"
  export FAKE_GH_DIR FAKE_GH_LOG

  mkdir -p "$WORK/stub-bin"
  cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
# fake gh — canned reads, recorded everything. One line per call, always:
# an Issue body arrives through `-f body=…` with newlines in it, and a
# log that let them through would make one call look like several to
# anything that counts lines (forge_told_times).
_call="$*"
printf '%s\n' "${_call//$'\n'/ }" >> "$FAKE_GH_LOG"
if [ "$1" = "pr" ] && [ "$2" = "list" ]; then
  cat "$FAKE_GH_DIR/pr_numbers" 2>/dev/null
  exit 0
fi
[ "$1" = "api" ] || { echo "{}"; exit 0; }
shift
path=""
while [ $# -gt 0 ]; do
  case "$1" in
    -X|--jq|-f|-F) shift 2 ;;
    --paginate) shift ;;
    *) [ -z "$path" ] && path="$1"; shift ;;
  esac
done
case "$path" in
  repos/*/pulls/*/files)
    n=$(printf '%s' "$path" | sed -n 's|.*/pulls/\([0-9][0-9]*\)/files$|\1|p')
    cat "$FAKE_GH_DIR/pr_${n}_files" 2>/dev/null ;;
  *) echo "{}" ;;
esac
exit 0
GH
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"

  export BASE_REF=main
  export LABEL_NAME="writrun:report"
  export ISSUE_TITLE="Something was observed"
  export ISSUE_BODY=""
  export ISSUE_AUTHOR="someone"
  export ISSUE_CREATED_AT="2026-09-01T12:00:00Z"
}

# authority <path...> — the named git command against a fresh read of
# what origin's main really holds, which is where the recording must
# have landed: the clone's own tree passing proves only half the act.
authority() {
  git -C "$WORK/origin.git" "$@"
}

# recording_commit <path> <line> — the composed write a case lands: one
# line at <path>, committed in the clone. The caller's half of
# push_recording.sh's contract, done before the script is asked to land
# it.
recording_commit() {
  mkdir -p "$(dirname "$1")"
  printf '%s\n' "$2" > "$1"
  git add -A >/dev/null
  git commit -qm "chore(queue): record what the event decided"
}

# setup_racer — a clone that lands commits on origin behind the
# checkout's back, exactly as a sibling recording or a report/ branch
# squash-merge would put them there. `-b main` because the bare origin's
# HEAD still names the machine's default branch — a clone left to guess
# lands somewhere else and the racer's push dies silently, and with it
# the race under test.
setup_racer() {
  git clone -q -b main "$WORK/origin.git" "$WORK/racer" 2>/dev/null
  git -C "$WORK/racer" config user.email r@example.com
  git -C "$WORK/racer" config user.name Racer
}

# racer_lands <path> <subject> — the racer commits stdin to <path> and
# lands it on origin's main. Pulls first: the racer may itself be behind
# by whatever landed since its clone.
racer_lands() {
  (
    cd "$WORK/racer" || exit 1
    git pull -q --rebase origin main 2>/dev/null
    mkdir -p "$(dirname "$1")"
    cat > "$1"
    git add -A >/dev/null
    git commit -qm "$2"
    git push -q origin main 2>/dev/null
  )
}

# arm_racer_hook [count] — the window made deterministic, never by
# timing: a pre-push hook in the clone lands one racer commit on origin
# and lets the push proceed, so the push meets a branch that moved
# *after* the rebase — the refusal report-0023 recorded, without a sleep
# and without a flake. Fires before each of the first <count> pushes;
# no count means every push. The hook calls git by absolute path so the
# spy below never counts the racer's own traffic.
arm_racer_hook() {
  local real_git
  real_git=$(command -v git)
  cat > .git/hooks/pre-push <<HOOK
#!/usr/bin/env bash
n=\$(cat "$WORK/racer_fires" 2>/dev/null || echo 0)
if [ -n "${1:-}" ] && [ "\$n" -ge "${1:-0}" ]; then exit 0; fi
echo \$((n + 1)) > "$WORK/racer_fires"
cd "$WORK/racer" || exit 1
"$real_git" pull -q --rebase origin main
echo "race \$n" > "race-\$n.txt"
"$real_git" add -A >/dev/null
"$real_git" commit -qm "racer: race \$n"
"$real_git" push -q origin main
exit 0
HOOK
  chmod +x .git/hooks/pre-push
}

# spy_git / spied — what a run costs the remote. The spy is a PATH shim
# that logs every git subcommand line before handing over to the real
# binary, and `spied` runs one command under it; the counts come out of
# git_told_times. Client-side on purpose: a refused push and a landed
# one cost the same call, and no server hook sees a fetch at all.
spy_git() {
  GIT_SPY_LOG="$WORK/git-spy.log"
  : > "$GIT_SPY_LOG"
  mkdir -p "$WORK/spy-bin"
  cat > "$WORK/spy-bin/git" <<SPY
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$GIT_SPY_LOG"
exec "$(command -v git)" "\$@"
SPY
  chmod +x "$WORK/spy-bin/git"
}

spied() {
  PATH="$WORK/spy-bin:$PATH" "$@"
}

# git_told_times <name> <count> <subcommand> — the spy's log holds one
# line per git call; the run spent exactly this many. Anchored to the
# line's start so `push` never counts a `pull`'s arguments.
git_told_times() {
  local n
  n=$(grep -c -- "^$3" "$GIT_SPY_LOG")
  if [ "$n" -eq "$2" ]; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected %s git calls starting: %s (got %s)\n' \
      "$1" "$2" "$3" "$n"
    sed 's/^/      | /' "$GIT_SPY_LOG"
    fail=$((fail + 1))
  fi
}

# The log assertions (forge_told, forge_not_told) are harness.sh's —
# shared with mirror_lib.sh over the same shape of log.
