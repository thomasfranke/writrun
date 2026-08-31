#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A task template with no {{references}} placeholder opted its bodies out
# of links — taste, not contract. The opt-out has to survive the task's
# first spec, or it is not an opt-out: the `spec_ref` append writes the
# front matter, which is the machine contract, and leaves the body alone.
setup
mkdir -p .writrun/conventions/templates
printf '# {{title}}\n\nTODO: what to do, and why.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Linkless" --origin rule --slug linkless \
  --doc-ref product/chapter.md#scope >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "First" --slug first >/dev/null 2>&1
f=work/tasks/task-0001-linkless.md
if grep -q '^spec_ref: \[spec-0001\]$' "$f" && ! grep -q 'References' "$f"; then
  echo "ok    the spec append honours a template that asked for no links"; pass=$((pass + 1))
else
  echo "FAIL  the spec append honours a template that asked for no links"
  sed 's/^/      | /' "$f"
  fail=$((fail + 1))
fi

check "and the canonical check still passes over the queue" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
