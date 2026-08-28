#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
mkdir -p .writrun/conventions/templates
cat > .writrun/conventions/templates/spec.md <<'T'
# {{id}} — {{title}} (for {{task_ref}})

Our sections.

## Proposed product changes
- none

## Proposed technical changes
- none

## Outcome
_(later)_
T
bash "$NEW_SH" task "A thing" >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "Shaped" >/dev/null 2>&1
if grep -q '^# spec-0001 — Shaped (for task-0001)$' work/specs/spec-0001-shaped.md &&
   grep -q '^Our sections.$' work/specs/spec-0001-shaped.md &&
   grep -q '^status: draft$' work/specs/spec-0001-shaped.md; then
  echo "ok    a project spec template wins and keeps the contract headings"; pass=$((pass + 1))
else
  echo "FAIL  a project spec template wins and keeps the contract headings"
  cat work/specs/spec-0001-shaped.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
