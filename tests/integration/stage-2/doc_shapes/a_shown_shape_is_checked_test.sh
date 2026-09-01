#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# An example is documentation that lies with a straight face: a reader
# copies it and the first check refuses what it taught. These are the
# shapes the guard reads, and the ones it deliberately does not.
SHAPES="$CI_SCRIPTS/stage-2-pull-requests/check_doc_shapes.sh"
export CHECK_FRONT_MATTER="$CHECK_FRONT_MATTER"
# This case is about the shown shapes alone; the vocabulary half has its own.
export RETIRED_VOCABULARY=/dev/null

setup
mkdir -p prose
: > vocab.txt

current_task() {   # current_task <file> [created]
  cat > "$1" <<EOF
# A chapter

\`\`\`yaml
---
id: task-0005
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0011]
doc_ref: product/editor/search-and-replace.md#scope
origin: rule
priority: high
depends_on: [task-0003]
milestone: v0.1-core
created: ${2:-2026-08-21T09:14:00Z}
queued: null
completed: null
merged: null
provenance: []
---
\`\`\`
EOF
}

current_task prose/chapter.md
check "a current example passes" 0 "1 shown shape" \
  -- bash "$SHAPES" prose

# The same example, one field back to a bare date — the exact drift this
# repository's own concept chapters carried.
current_task prose/chapter.md 2026-08-21
check "a stale date fails, naming the file and the block's line" 1 \
  "prose/chapter.md:3: the shown task-0005 field 'created'" \
  -- bash "$SHAPES" prose

# **The reference stays fictional.** The example above points at
# product/editor/search-and-replace.md, which exists in no repository;
# the check materialises it in a scratch tree and passes it as the
# checker's third argument. The two cases together are what prove the
# path is materialised rather than the field disabled: the doc_ref is
# unchanged in both, and only the date decides the verdict.

# Back to the current example: each case below is about its own file.
current_task prose/chapter.md

cat > prose/annotated.md <<'EOF'
# The schema

```yaml
---
id: spec-0004                      # immutable identity
task_ref: task-0005                # a spec belongs to exactly one task
status: draft                      # draft | approved | implemented
created: 2026-08-20T16:02:00Z
---
```
EOF
check "an annotated schema passes — the annotation is not the shape" 0 \
  "2 shown shape" -- bash "$SHAPES" prose
rm -f prose/annotated.md

cat > prose/fragment.md <<'EOF'
# A fragment

```yaml
provenance:
  - {by: agent, model: claude-opus-5, login: octocat}
  - {by: human, login: octocat}
```
EOF
check "a fragment is checked and named as one" 0 \
  "read as a front-matter fragment" -- bash "$SHAPES" prose

cat > prose/fragment.md <<'EOF'
# A fragment with a key no schema has

```yaml
provenance:
  - {by: agent}
invented_field: 3
```
EOF
check "a fragment carrying an undocumented key fails" 1 \
  "carries 'invented_field', which neither schema documents" \
  -- bash "$SHAPES" prose
rm -f prose/fragment.md

cat > prose/settings.md <<'EOF'
# Not front matter at all

```yaml
stage: 3
mirror: true
```
EOF
check "a yaml block that is not front matter is skipped, and counted" 0 \
  "1 not front matter" -- bash "$SHAPES" prose
rm -f prose/settings.md

# Two examples in one document: the scratch name carries the line, so the
# second never overwrites the first, and both are read.
cat > prose/two.md <<'EOF'
# Two

```yaml
---
id: spec-0004
task_ref: task-0005
status: draft
created: 2026-08-20T16:02:00Z
---
```

```yaml
---
id: spec-0005
task_ref: task-0005
status: draft
created: 2026-08-20
---
```
EOF
rm -f prose/chapter.md
check "both examples in one document are read" 1 \
  "prose/two.md:12: the shown spec-0005" -- bash "$SHAPES" prose

finish
