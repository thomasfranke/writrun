#!/usr/bin/env bash
# pipeline_lib.sh — the fixture behind every case that exercises the
# pipeline's scripts: the four skills (unit tier) and the workflow step
# logic in .writrun/scripts (integration tier).
#
# A case file sources this and then runs standalone:
#
#   bash tests/unit/check_state/born_implemented_rejected_test.sh
#
# or under tests/run.sh, which discovers and aggregates. Layout
# convention: one tier per directory; inside it one directory per script
# under test, named after the script; one file per behaviour, suffixed
# `_test.sh`.

. "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

CHECK_STATE="$REPO_ROOT/.writrun/skills/writrun-check-task-state/check_state.sh"
CHECK_DELTAS="$REPO_ROOT/.writrun/skills/writrun-check-spec-deltas/check_deltas.sh"
LIST_TASKS="$REPO_ROOT/.writrun/skills/writrun-select-next-task/list_tasks.sh"
NEW_SH="$REPO_ROOT/.writrun/skills/writrun-create-task-and-spec/new.sh"

# The workflow step scripts — what the integration tier exercises, the same
# way the unit tier exercises the skills.
CI_SCRIPTS="$REPO_ROOT/.writrun/scripts"
READ_SETTING="$CI_SCRIPTS/stage-2-pull-requests/read_setting.sh"
CHECK_SETTINGS="$CI_SCRIPTS/stage-2-pull-requests/check_settings.sh"
STAGE_GATE="$CI_SCRIPTS/stage-2-pull-requests/stage_gate.sh"
WORKFLOWS="$REPO_ROOT/.github/workflows"

# settings_file — the whole settings file, from stdin, at the address it
# lives at today. Written verbatim, because half of what the check exists
# for is the shapes a generator would never produce.
settings_file() {
  mkdir -p .writrun
  cat > .writrun/settings.json
}

# legacy_settings_file — the same, at the address the file had before it
# moved to WritRun's root. The reader honours one left there, flat, under
# the contract frozen at the move; the check is what names the move
# (docs/technical/decisions/tasks-and-specs/0053-settings-at-the-root.md).
legacy_settings_file() {
  mkdir -p .writrun/conventions
  cat > .writrun/conventions/settings.json
}

# check_front_matter runs on files alone, so it is a skill rather than a
# CI script — it is the one check available at every adoption stage.
CHECK_FRONT_MATTER="$REPO_ROOT/.writrun/skills/writrun-check-front-matter/check_front_matter.sh"

# stub_gh <n> — put a fake `gh` on PATH that answers every invocation with
# <n>, standing in for the forge's count of authorized approving reviews.
stub_gh() {
  mkdir -p "$WORK/stub-bin"
  printf '#!/usr/bin/env bash\necho %s\n' "$1" > "$WORK/stub-bin/gh"
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
}

# stub_forge — a fake `gh` that answers the two questions the id checks
# ask, and records every call. Reads are served post-jq, the shape the
# real scripts request, so the shell logic under test sees exactly what
# CI would (the same contract mirror_lib.sh's forge holds):
#
#   gh pr list --json number        -> $FORGE_DIR/pr_numbers
#   gh api .../pulls/N/files        -> $FORGE_DIR/pr_N_paths
#   ... --jq '...status == "added"' -> $FORGE_DIR/pr_N_added
#
# The two consumers of the file list want different halves of it: the
# check selects the added files, the generator reads every path. The jq
# expression is what tells them apart, the same way it does at the real
# endpoint.
#
# **The list is paged, because that is the bug this stub has to be able
# to reproduce**: without `--paginate` the caller sees $FORGE_PAGE
# entries and no sign that more exist.
#
# Touch $FORGE_DIR/unavailable and every call fails, which is what no
# network, no auth, and no remote all look like from the caller's side.
# Call after setup — it lives in the repository setup created.
stub_forge() {
  FORGE_DIR="$WORK/forge"
  FORGE_LOG="$WORK/forge/gh.log"
  mkdir -p "$FORGE_DIR"
  : > "$FORGE_LOG"
  # GitHub's own page size for a pull request's file list.
  FORGE_PAGE=100
  export FORGE_DIR FORGE_LOG FORGE_PAGE

  mkdir -p "$WORK/stub-bin"
  cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FORGE_LOG"
[ -e "$FORGE_DIR/unavailable" ] && exit 1
case "${1:-}" in
  pr)
    field=""; prev=""
    for a in "$@"; do
      [ "$prev" = "--json" ] && field="$a"
      prev="$a"
    done
    case "$field" in
      number) cat "$FORGE_DIR/pr_numbers" 2>/dev/null ;;
    esac
    ;;
  api)
    n=$(printf '%s' "${2:-}" | sed -n 's|.*/pulls/\([0-9][0-9]*\)/files$|\1|p')
    [ -n "$n" ] || exit 0
    jq=""; prev=""; paginate=""
    for a in "$@"; do
      [ "$prev" = "--jq" ] && jq="$a"
      [ "$a" = "--paginate" ] && paginate=yes
      prev="$a"
    done
    case "$jq" in
      *added*) src="$FORGE_DIR/pr_${n}_added" ;;
      *)       src="$FORGE_DIR/pr_${n}_paths" ;;
    esac
    [ -e "$src" ] || exit 0
    if [ -n "$paginate" ]; then cat "$src"; else head -n "$FORGE_PAGE" "$src"; fi
    ;;
esac
exit 0
GH
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
}

# forge_pr <number> <added|modified> <path> — one file on one open pull
# request. The number joins the open list once; the path is visible to the
# generator either way, and only an added one is a claim the check reads.
# Files land in the order they are declared, which is the order the pages
# come in.
forge_pr() {
  grep -qxF "$1" "$FORGE_DIR/pr_numbers" 2>/dev/null \
    || printf '%s\n' "$1" >> "$FORGE_DIR/pr_numbers"
  printf '%s\n' "$3" >> "$FORGE_DIR/pr_${1}_paths"
  [ "$2" = added ] && printf '%s\n' "$3" >> "$FORGE_DIR/pr_${1}_added"
  return 0
}

# forge_pr_filler <number> <count> — <count> modified files on one open
# pull request, to push what follows them onto a later page.
forge_pr_filler() {
  local i=1
  while [ "$i" -le "$2" ]; do
    forge_pr "$1" modified "docs/filler-${i}.md"
    i=$((i + 1))
  done
}

# forge_unavailable — no `gh` answer at all, from here on.
forge_unavailable() { : > "$FORGE_DIR/unavailable"; }

# forge_untouched <name> — not a single call reached the forge.
forge_untouched() {
  if [ -s "$FORGE_LOG" ]; then
    printf 'FAIL  %s\n      expected no gh call at all\n' "$1"
    sed 's/^/      | /' "$FORGE_LOG"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}

# A repository with docs/ and one commit on main. cd's into it.
setup() {
  WORK_PREV="$WORK"
  WORK=$(mktemp -d)
  [ -n "$WORK_PREV" ] && rm -rf "$WORK_PREV"
  cd "$WORK" || exit 1
  git init -q .
  git symbolic-ref HEAD refs/heads/main
  git config user.email t@example.com
  git config user.name Test
  mkdir -p work/tasks work/specs docs/product docs/technical
  printf '# Product\n\n## Scope\n\nbaseline\n' > docs/product/chapter.md
  printf '# Technical\n\n## Decisions\n\nbaseline\n' > docs/technical/README.md
  printf '# About\n\nbaseline\n' > docs/about.md
  git add -A >/dev/null
  git commit -qm baseline
  git checkout -qb feature
}

task_file() {   # task_file <id> <status> <spec_ref> [completed] [taken_by]
  cat > "work/tasks/$1.md" <<EOF
---
id: $1
status: $2
blocked_reason: null
taken_by: ${5:-null}
spec_ref: [$3]
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-22T00:00:00Z
queued: null
completed: ${4:-null}
merged: null
---

# Test task $1
EOF
}

spec_file() {   # spec_file <id> <task> <status> [promised-path]
  cat > "work/specs/$1.md" <<EOF
---
id: $1
task_ref: $2
status: $3
created: 2026-08-22T00:00:00Z
---

# $1 — test

## Proposed product changes

$( [ -n "${4:-}" ] && echo "- \`$4\` — test promise." || echo "- none — no behaviour change" )

## Proposed technical changes

- none — no machinery change

## Outcome

_(fill after execution)_
EOF
}

commit_all() { git add -A >/dev/null; git commit -qm "change"; }
