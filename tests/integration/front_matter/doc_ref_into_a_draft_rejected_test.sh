#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Resolving is not the whole question. A chapter that declares itself a
# draft is not a rule, and a task pointing into one is derivation from a
# rule the project has not made — so the refusal says that, and never
# "names no file": the file is right there, and a resolution message
# would send the reader hunting a typo that is not there.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/drafted.md

task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/drafted.md#anchor|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a doc_ref into a draft chapter is refused" 1 "names a draft chapter" \
  -- bash "$CHECK_FRONT_MATTER"
check "and the refusal names the rule, not a resolution fault" 1 \
  "nothing derives from a chapter that is not a rule yet" \
  -- bash "$CHECK_FRONT_MATTER"
refute "and never claims the file is missing" "names no file" \
  -- bash "$CHECK_FRONT_MATTER"

# The same chapter once the marker is gone: the reference was always
# fine, the chapter was not a rule.
printf '# A real rule\n' > docs/product/drafted.md
check "and passes once the chapter is a rule" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# The marker counts on the first line only — a chapter that documents it
# names it in prose, and must not be read as declaring itself one.
printf '# About the marker\n\nWrite `/// writrun:draft` first.\n' > docs/product/drafted.md
check "a marker named in prose is prose" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# A report carries the same field under the same contract, and one
# implementation answers both.
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Not a rule yet\n' > docs/product/drafted.md
report_file report-0001 open "" null "product/drafted.md"
check "a report's doc_ref is held to it too" 1 "names a draft chapter" \
  -- bash "$CHECK_FRONT_MATTER"

finish
