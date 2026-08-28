#!/usr/bin/env bash
# mirror_lib.sh — the fixture behind every case that exercises the mirror
# scripts (.writrun/scripts/mirror_issues.sh, reflect_progress.sh).
#
# The forge is a fake `gh` on PATH: reads are served from canned files —
# the post-jq row shape the real scripts request, so the shell logic under
# test sees exactly what CI would — and every invocation, read or write,
# is appended to a log. Mutations are asserted against that log: a test
# says what the forge must (or must not) have been told to do.
#
# Same constraints as every other fixture: git, bash, POSIX awk/sed, no
# framework (tests/harness.sh has the assertion core).

. "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

MIRROR_ISSUES="$REPO_ROOT/.writrun/scripts/mirror_issues.sh"
REFLECT_PROGRESS="$REPO_ROOT/.writrun/scripts/reflect_progress.sh"

b64() { base64 | tr -d '\n'; }

# A working directory shaped like the base-branch checkout the workflows
# run from (reflect_progress resolves spec branches through work/specs/),
# plus the fake forge. cd's into it. Default PR: #7, open, not draft, by
# an OWNER — cases override the exported PR_* fields they are about.
setup_forge() {
  WORK_PREV="$WORK"
  WORK=$(mktemp -d)
  [ -n "$WORK_PREV" ] && rm -rf "$WORK_PREV"
  cd "$WORK" || exit 1
  mkdir -p work/tasks work/specs

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
[ "$1" = "api" ] || { echo "{}"; exit 0; }
shift
path=""
method=GET
while [ $# -gt 0 ]; do
  case "$1" in
    -X) method="$2"; shift 2 ;;
    --jq) shift 2 ;;
    --paginate) shift ;;
    -f|-F) shift 2 ;;
    *) [ -z "$path" ] && path="$1"; shift ;;
  esac
done
case "$method $path" in
  "GET repos/"*"/pulls/"*"/files") cat "$FAKE_GH_DIR/pr_files" 2>/dev/null ;;
  "GET repos/"*"/issues?"*)        cat "$FAKE_GH_DIR/issues" 2>/dev/null ;;
  "POST repos/"*"/labels")
    if [ -e "$FAKE_GH_DIR/labels_422" ]; then
      echo "gh: Validation Failed (HTTP 422)" >&2
      exit 1
    fi
    echo "{}" ;;
  *) echo "{}" ;;
esac
exit 0
GH
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"

  export PR_STATE=open PR_DRAFT=false PR_MERGED=false
  export PR_AUTHOR_ASSOCIATION=OWNER
  export PR_HTML_URL="https://github.com/o/r/pull/7"
  export PR_HEAD_REF=""
}

# pr_file <status> <filename> — one row of the PR's file list; the file's
# full content arrives on stdin and becomes its patch, shaped like the
# forge shapes an added file's (a hunk header, then all-'+' lines).
pr_file() {
  local content patch
  content=$(cat)
  patch=$(printf '@@ -0,0 +1,1 @@\n%s\n' \
    "$(printf '%s\n' "$content" | sed 's/^/+/')")
  printf '%s\t%s\t%s\n' "$1" "$2" "$(printf '%s' "$patch" | b64)" \
    >> "$FAKE_GH_DIR/pr_files"
}

# pr_patch <status> <filename> — same row, but the raw patch itself on
# stdin: for a modified file, whose patch mixes context and +/- lines.
pr_patch() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$(b64)" >> "$FAKE_GH_DIR/pr_files"
}

# added_task <id> <title> [spec-refs-csv] — a schema-correct task file
# entering the diff.
added_task() {
  pr_file added "work/tasks/$1.md" <<EOF
---
id: $1
status: pending
blocked_reason: null
spec_ref: [${3:-}]
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
completed: null
---

# $2
EOF
}

# added_spec <id> <task-ref> <status> — a spec file entering the diff.
added_spec() {
  pr_file added "work/specs/$1.md" <<EOF
---
id: $1
task_ref: $2
status: $3
created: 2026-08-23T00:00:00Z
---

# $1 — test
EOF
}

# base_spec <id> <task-ref> — a spec as it already exists on the base
# branch, for reflect_progress's branch resolution.
base_spec() {
  cat > "work/specs/$1.md" <<EOF
---
id: $1
task_ref: $2
status: approved
created: 2026-08-23T00:00:00Z
---

# $1 — test
EOF
}

# forge_issue <number> <state> <labels-csv> <title> [introduced-by-pr] —
# one row of the forge's writrun:task issue list, its body carrying the
# ownership line mirror_issues.sh writes and reads back.
forge_issue() {
  local body
  body=$(printf '%s\n' \
    "Mirrors a task file, which is the authority." \
    "| Introduced by | #${5:-7} |")
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$1" "$2" "$3" \
    "$(printf '%s' "$4" | b64)" \
    "$(printf '%s' "$body" | b64)" \
    >> "$FAKE_GH_DIR/issues"
}

# forge_told <name> <substring> — the log holds one entry per gh call;
# the forge was told to do this.
forge_told() {
  if grep -qF -- "$2" "$FAKE_GH_LOG"; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      expected a gh call containing: %s\n' "$1" "$2"
    sed 's/^/      | /' "$FAKE_GH_LOG"
    fail=$((fail + 1))
  fi
}

# forge_not_told <name> <substring> — and this it must never have been.
forge_not_told() {
  if grep -qF -- "$2" "$FAKE_GH_LOG"; then
    printf 'FAIL  %s\n      expected NO gh call containing: %s\n' "$1" "$2"
    sed 's/^/      | /' "$FAKE_GH_LOG"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}

# forge_untouched <name> — not a single call reached the forge.
forge_untouched() {
  if [ -s "$FAKE_GH_LOG" ]; then
    printf 'FAIL  %s\n      expected no gh call at all\n' "$1"
    sed 's/^/      | /' "$FAKE_GH_LOG"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}
