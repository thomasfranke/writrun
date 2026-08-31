#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The append that adds a spec to a task must never quietly not happen:
# front matter and body disagreeing about which specs a task has is the
# one thing this edit exists to prevent. A template whose body opens at
# a level other than `#`, or opens with no heading at all, is still a
# body the front matter has to agree with.

# Opens at `##` — the link goes under that heading.
setup
mkdir -p .writrun/conventions/templates
printf '## {{title}}\n\n{{references}}\n\nTODO.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Deep" --origin rule --slug deep >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "Only" --slug only >/dev/null 2>&1
f=work/tasks/task-0001-deep.md
if grep -qF '**References:** [spec-0001](../specs/spec-0001-only.md)' "$f" &&
   [ "$(sed -n '/^## Deep$/{n;p;}' "$f")" = "" ]; then
  echo "ok    a body opening at ## gains the line under that heading"; pass=$((pass + 1))
else
  echo "FAIL  a body opening at ## gains the line under that heading"
  sed 's/^/      | /' "$f"
  fail=$((fail + 1))
fi

# No heading anywhere — the link opens the body, straight after the
# front matter, rather than going missing.
setup
mkdir -p .writrun/conventions/templates
printf '{{references}}\n\nTODO, and no heading anywhere.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Flat" --origin report --slug flat >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "Sole" --slug sole >/dev/null 2>&1
g=work/tasks/task-0001-flat.md
if grep -qF '**References:** [spec-0001](../specs/spec-0001-sole.md)' "$g" &&
   grep -q '^TODO, and no heading anywhere\.$' "$g"; then
  echo "ok    a body with no heading still gains the line"; pass=$((pass + 1))
else
  echo "FAIL  a body with no heading still gains the line"
  sed 's/^/      | /' "$g"
  fail=$((fail + 1))
fi

check "and the canonical check still passes over the queue" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
