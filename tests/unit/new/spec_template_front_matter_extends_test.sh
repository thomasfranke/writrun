#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The same extension mechanics on the spec side — with the template's
# placeholders substituted in extension values too.
setup
mkdir -p .writrun/conventions/templates
cat > .writrun/conventions/templates/spec.md <<'EOF'
---
origin: {{task_ref}}
---

# {{id}} — {{title}}

## Proposed product changes

- none — no behaviour change

## Proposed technical changes

- none — no machinery change

## Outcome

_(fill after execution)_
EOF
bash "$NEW_SH" task "The task" >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "The spec" >/dev/null 2>&1
fm=$(sed -n '2,/^---$/p' work/specs/spec-0001-the-spec.md)
if printf '%s\n' "$fm" | grep -q '^origin: task-0001$' &&
   printf '%s\n' "$fm" | grep -q '^status: draft$' &&
   grep -q '^# spec-0001 — The spec$' work/specs/spec-0001-the-spec.md; then
  echo "ok    spec template extensions land, placeholders substituted"; pass=$((pass + 1))
else
  echo "FAIL  spec template extensions land, placeholders substituted"
  cat work/specs/spec-0001-the-spec.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
