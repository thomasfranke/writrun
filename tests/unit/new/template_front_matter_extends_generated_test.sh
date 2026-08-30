#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A project template may open with a front-matter block of its own: those
# are extension fields, appended to the generated contract block — the
# generator writes them, the agent fills them, and the canonical check
# accepts them as unknown keys in canonical shape.
setup
mkdir -p .writrun/conventions/templates
cat > .writrun/conventions/templates/task.md <<'EOF'
---
owner: TODO — the team that answers for this
estimate: TODO
---

# {{title}}

Our shape.
EOF
bash "$NEW_SH" task "Extended" >/dev/null 2>&1
fm=$(sed -n '2,/^---$/p' work/tasks/task-0001-extended.md)
if printf '%s\n' "$fm" | grep -q '^owner: TODO — the team that answers for this$' &&
   printf '%s\n' "$fm" | grep -q '^estimate: TODO$' &&
   printf '%s\n' "$fm" | grep -q '^status: backlog$' &&
   grep -q '^# Extended$' work/tasks/task-0001-extended.md &&
   ! grep -q '^owner:.*# Extended' work/tasks/task-0001-extended.md; then
  echo "ok    template extensions land inside the generated front matter"; pass=$((pass + 1))
else
  echo "FAIL  template extensions land inside the generated front matter"
  cat work/tasks/task-0001-extended.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi
check "and the canonical check accepts the result" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
