#!/usr/bin/env bash
# mirror_lib.sh — the fixture behind every case that exercises the mirror
# scripts (.writrun/scripts/stage-3-github-issues/mirror_issues.sh, project_pr_tasks.sh).
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

MIRROR_ISSUES="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/mirror_issues.sh"
PROJECT_PR="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/project_pr_tasks.sh"
REDERIVE_LABELS="$REPO_ROOT/.writrun/scripts/stage-3-github-issues/rederive_labels.sh"

b64() { base64 | tr -d '\n'; }

# A working directory shaped like the base-branch checkout the workflows
# run from (the projection resolves tasks through work/tasks/),
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
jq=""
while [ $# -gt 0 ]; do
  case "$1" in
    -X) method="$2"; shift 2 ;;
    --jq) jq="$2"; shift 2 ;;
    --paginate) shift ;;
    -f|-F) shift 2 ;;
    *) [ -z "$path" ] && path="$1"; shift ;;
  esac
done
case "$method $path" in
  "GET repos/"*"/pulls/"*"/files") cat "$FAKE_GH_DIR/pr_files" 2>/dev/null ;;
  "GET repos/"*"/pulls/"*)
    # One pull request's own state. A number nothing declared is one the
    # forge does not know, and it answers the way the real one does.
    n=$(printf '%s' "$path" | sed -n 's|.*/pulls/\([0-9][0-9]*\)$|\1|p')
    if [ -n "$n" ] && [ -e "$FAKE_GH_DIR/pr_${n}_state" ]; then
      cat "$FAKE_GH_DIR/pr_${n}_state"
    else
      echo "gh: Not Found (HTTP 404)" >&2
      exit 1
    fi ;;
  # Two lists, told apart by the label filter exactly as the forge tells
  # them apart. A kind with no canned file answers empty, which is what a
  # repository that has never used it really answers.
  "GET repos/"*"/issues?labels=writrun:report"*)
    cat "$FAKE_GH_DIR/report_issues" 2>/dev/null ;;
  "GET repos/"*"/issues?"*)        cat "$FAKE_GH_DIR/issues" 2>/dev/null ;;
  "POST repos/"*"/issues")
    # `--jq .number` is how the caller asks for the new Issue's number,
    # and a create it cannot read the number back from is a create it
    # cannot close. The counter makes each one distinct.
    n=$(cat "$FAKE_GH_DIR/next_issue" 2>/dev/null || echo 100)
    echo $((n + 1)) > "$FAKE_GH_DIR/next_issue"
    if [ "$jq" = ".number" ]; then echo "$n"; else printf '{"number": %s}\n' "$n"; fi ;;
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

# added_report <id> <title> [status] [task-refs-csv] [triaged] — a
# schema-correct report file entering the diff.
added_report() {
  pr_file added "work/reports/$1.md" <<EOF
---
id: $1
status: ${3:-open}
task_ref: [${4:-}]
doc_ref: null
created: 2026-08-23T00:00:00Z
triaged: ${5:-null}
---

# $2
EOF
}

# modified_report <id> <status> <triaged> — the patch a triage really
# leaves behind: two changed lines, context around them, and no added
# `id:` line in it. That absence is the point — the id has to come from
# the path, because an edit to the status line carries nothing else.
#
# The base-branch file comes with it, because a *modified* file is on the
# base branch by definition and the workflow checks that branch out. It
# is what bounds the front-matter block: a hunk that starts partway down
# the file cannot show where the block ends, and a reader that guesses
# reads a report's own body evidence as its status.
modified_report() {
  base_report "$1" open
  pr_patch modified "work/reports/$1.md" <<EOF
@@ -2,5 +2,5 @@
 id: $1
-status: open
+status: $2
 task_ref: []
 doc_ref: null
-triaged: null
+triaged: $3
EOF
}

# base_report <id> <status> [task-refs-csv] [triaged] — a report as the
# authority branch already holds it, for the readers that ask the queue
# on disk.
base_report() {
  mkdir -p work/reports
  cat > "work/reports/$1.md" <<EOF
---
id: $1
status: $2
task_ref: [${3:-}]
doc_ref: null
created: 2026-08-23T00:00:00Z
triaged: ${4:-null}
---

# Report $1
EOF
}

# added_task <id> <title> [spec-refs-csv] [origin] — a schema-correct
# task file entering the diff.
added_task() {
  pr_file added "work/tasks/$1.md" <<EOF
---
id: $1
status: pending
blocked_reason: null
spec_ref: [${3:-}]
doc_ref: null
origin: ${4:-rule}
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
queued: null
completed: null
merged: null
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

# base_spec <id> <task-ref> [status] — a spec as it already exists on the
# base branch, for the projection's resolution and for the
# readers that derive a label from the queue. Defaults to approved.
base_spec() {
  cat > "work/specs/$1.md" <<EOF
---
id: $1
task_ref: $2
status: ${3:-approved}
created: 2026-08-23T00:00:00Z
---

# $1 — test
EOF
}

# base_task <id> <status> [spec-refs-csv] [origin] — a task as it already
# exists on the base branch, for the readers that ask the queue on disk
# rather than a pull request's diff.
base_task() {
  cat > "work/tasks/$1.md" <<EOF
---
id: $1
status: $2
blocked_reason: null
spec_ref: [${3:-}]
doc_ref: null
origin: ${4:-rule}
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
queued: null
completed: null
merged: null
---

# Task $1
EOF
}

# forge_pr_state <number> <open|closed> — what the forge says about one
# pull request. A number no case declares is a number the forge does not
# know, which is a different fact and answers 404.
forge_pr_state() {
  printf '%s\n' "$2" > "$FAKE_GH_DIR/pr_${1}_state"
}

# forge_report_issue <number> <state> <labels-csv> <title> [introduced-by-pr]
# — one row of the forge's writrun:report issue list, same shape and same
# ownership line as a task mirror's.
forge_report_issue() {
  local body
  if [ "${5:-}" = "none" ]; then
    body="Mirrors a report file, which is the authority."
  else
    body=$(printf '%s\n' \
      "Mirrors a report file, which is the authority." \
      "| Introduced by | #${5:-7} |")
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$1" "$2" "$3" \
    "$(printf '%s' "$4" | b64)" \
    "$(printf '%s' "$body" | b64)" \
    >> "$FAKE_GH_DIR/report_issues"
}

# forge_issue <number> <state> <labels-csv> <title> [introduced-by-pr] —
# one row of the forge's writrun:task issue list, its body carrying the
# ownership line mirror_issues.sh writes and reads back. Pass `none` as
# the fifth argument for a body that carries no ownership line at all —
# an issue nothing in this machinery wrote.
forge_issue() {
  local body
  if [ "${5:-}" = "none" ]; then
    body="Mirrors a task file, which is the authority."
  else
    body=$(printf '%s\n' \
      "Mirrors a task file, which is the authority." \
      "| Introduced by | #${5:-7} |")
  fi
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
