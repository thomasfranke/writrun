#!/usr/bin/env bash
# A router stub is a heading whose whole body is the one link to where
# the section now lives. Briefing the stub verbatim would hand over a
# complete-looking brief holding nothing but a link, so the reader
# follows it once and the divider shows both hops.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
cat > docs/technical/README.md <<'MD'
# Technical overview

## Task schema

Moved — see [`schemas.md#task-schema`](schemas.md#task-schema).

## Decisions

baseline
MD
cat > docs/technical/schemas.md <<'MD'
# File schemas

## Task schema

the chapter's own body

## Spec schema

not this one
MD
sed -i.bak 's|^doc_ref: null$|doc_ref: technical/README.md#task-schema|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "the chapter's section is what prints" 0 "the chapter's own body" -- bash "$BRIEF" task-001
check "and the divider shows both hops" 0 "technical/README.md#task-schema -> docs/technical/schemas.md#task-schema" -- bash "$BRIEF" task-001
refute "the hop does not run past the section" "not this one" -- bash "$BRIEF" task-001

# A stub whose link resolves to nothing is worse than a stub: the reader
# is told, gets the stub itself, and the brief is partial.
sed -i.bak 's|schemas.md#task-schema|schemas.md#gone|g' docs/technical/README.md
rm -f docs/technical/*.bak
check "a stub pointing at nothing is partial" 2 "resolves to nothing" -- bash "$BRIEF" task-001

finish
