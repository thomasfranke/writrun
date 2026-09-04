#!/usr/bin/env bash
# intake_lib.sh — the fixture behind the intake cases
# (.writrun/scripts/stage-3-github-issues/intake_report.sh).
#
# Two halves, because the script has two counterparties. The authority
# branch is a real one: a bare `origin` and a clone shaped like the
# workflow's checkout, so the recording's rebase-and-push lands where a
# later reader can assert on it. The forge is the same fake `gh` posture
# as mirror_lib.sh — reads served from canned files, every invocation
# logged, mutations asserted against the log — rebuilt here because the
# intake asks different questions (`gh pr list`, one pull request's file
# list) than the mirror scripts do.
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
# fake gh — canned reads, recorded everything.
printf '%s\n' "$*" >> "$FAKE_GH_LOG"
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

# The same two log assertions mirror_lib.sh has, over the same shape of
# log: a test says what the forge must (or must not) have been told.
forge_told() {
  if grep -qF -- "$2" "$FAKE_GH_LOG"; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected a gh call containing: %s\n' "$1" "$2"
    sed 's/^/      | /' "$FAKE_GH_LOG"
    fail=$((fail + 1))
  fi
}
forge_not_told() {
  if grep -qF -- "$2" "$FAKE_GH_LOG"; then
    printf 'FAIL  %s\n      expected NO gh call containing: %s\n' "$1" "$2"
    sed 's/^/      | /' "$FAKE_GH_LOG"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}
