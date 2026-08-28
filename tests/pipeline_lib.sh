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

# check_front_matter runs on files alone, so it is a skill rather than a
# CI script — it is the one check available at every adoption level.
CHECK_FRONT_MATTER="$REPO_ROOT/.writrun/skills/writrun-check-front-matter/check_front_matter.sh"

# stub_gh <n> — put a fake `gh` on PATH that answers every invocation with
# <n>, standing in for the forge's count of authorized approving reviews.
stub_gh() {
  mkdir -p "$WORK/stub-bin"
  printf '#!/usr/bin/env bash\necho %s\n' "$1" > "$WORK/stub-bin/gh"
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
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

task_file() {   # task_file <id> <status> <spec_ref> [completed]
  cat > "work/tasks/$1.md" <<EOF
---
id: $1
status: $2
blocked_reason: null
spec_ref: [$3]
doc_ref: null
priority: medium
depends_on: []
milestone: null
created: 2026-08-22
completed: ${4:-null}
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
created: 2026-08-22
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
