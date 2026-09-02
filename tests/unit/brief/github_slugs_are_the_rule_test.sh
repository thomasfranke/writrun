#!/usr/bin/env bash
# Every doc_ref in a queue targets GitHub's slug, so that is the rule the
# reader implements: backticks dropped, punctuation stripped, hyphens and
# underscores kept, duplicate heading text taking -1 in document order.
# A strip-everything rule would resolve none of these.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
cat > docs/product/chapter.md <<'MD'
# Chapter

### `pr_title_style`

the underscore section

### `blocked` vs. `depends_on`

the mixed-punctuation section

## Outcome

the first outcome

## Outcome

the second outcome
MD

sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#pr_title_style|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "an underscore survives the slug" 0 "the underscore section" -- bash "$BRIEF" task-001

sed -i.bak 's|^doc_ref: .*$|doc_ref: product/chapter.md#blocked-vs-depends_on|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "the dot goes and the rest stays" 0 "the mixed-punctuation section" -- bash "$BRIEF" task-001

sed -i.bak 's|^doc_ref: .*$|doc_ref: product/chapter.md#outcome|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "a duplicate heading's first is bare" 0 "the first outcome" -- bash "$BRIEF" task-001
refute "and does not carry the second" "the second outcome" -- bash "$BRIEF" task-001

sed -i.bak 's|^doc_ref: .*$|doc_ref: product/chapter.md#outcome-1|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "and the second takes the -1 suffix" 0 "the second outcome" -- bash "$BRIEF" task-001

finish
