#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
mkdir -p .writrun/conventions/templates
printf '# {{id}}\n\nNo contract headings here.\n' > .writrun/conventions/templates/spec.md
bash "$NEW_SH" task "A thing" >/dev/null 2>&1
check "a spec template without the contract headings is refused" 3 "missing the contract heading" \
  -- bash "$NEW_SH" spec task-001 "Broken"

finish
