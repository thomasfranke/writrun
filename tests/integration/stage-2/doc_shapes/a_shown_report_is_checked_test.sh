#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The third prefix. Until the map knew it, a report schema shown as
# ```yaml faulted on its own id — so the chapter fenced it ```text, which
# is the escape for a shape the checker is meant to refuse, not for one
# it cannot read yet. With the prefix taught, the block is held exactly
# as a task's and a spec's are.
SHAPES="$CI_SCRIPTS/stage-2-pull-requests/check_doc_shapes.sh"
export CHECK_FRONT_MATTER="$CHECK_FRONT_MATTER"
export RETIRED_VOCABULARY=/dev/null

setup
mkdir -p prose

shown_report() {   # shown_report <triaged>
  cat > prose/chapter.md <<INNER
# The report schema

\`\`\`yaml
---
id: report-0001
status: open                       # open | tracked | authored | fixed | declined
task_ref: []                       # the tasks triage produced; a list, always
doc_ref: null                      # the doc violated, or the doc the rule was written into
created: 2026-09-01T20:23:51Z
triaged: ${1}                      # when triage decided; null while open
---
\`\`\`
INNER
}

shown_report null
check "a shown report passes as a whole shape" 0 "1 shown shape" \
  -- bash "$SHAPES" prose

# And it is really the report rules being applied, not a shape waved
# through for having an unknown prefix: `triaged` set while the status is
# `open` is the pairing check_front_matter refuses, and the fault names
# the chapter, the line, and the shown id.
shown_report 2026-09-01T21:00:00Z
check "a shown report that contradicts itself fails, named" 1 \
  "prose/chapter.md:3: the shown report-0001" \
  -- bash "$SHAPES" prose

# The scratch tree is where a shown report is written, never the
# repository's own work/reports/ — a chapter's example must not be judged
# against files it has nothing to do with, and a real queue must not be
# reachable from a doc check.
report_file report-0001 declined "" 2026-08-22T00:00:00Z
shown_report null
check "the real queue is not what a shown shape is checked against" 0 \
  "1 shown shape" -- bash "$SHAPES" prose

finish
