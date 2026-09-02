#!/usr/bin/env bash
# A `#` at column 0 inside a fenced block is a shell comment or a schema
# example, never a heading. Reading it as one ends the section early and
# *silently* — what prints still looks like a whole answer — and GitHub,
# which gives those lines no anchor, would send a reader somewhere else
# entirely. The reference's own chapters are full of them.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
cat > docs/product/chapter.md <<'MD'
# Chapter

## Settings

before the example

```bash
# a comment that is not a heading
bash read_setting.sh stage
```

```markdown
## Outcome
not a heading either
```

after both examples

## Next

the sibling that really does end it
MD
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#settings|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "the fenced comment does not end the section" 0 "after both examples" \
  -- bash "$BRIEF" task-001
check "and the block itself still prints"           0 "a comment that is not a heading" \
  -- bash "$BRIEF" task-001
refute "the real sibling still ends it" "the sibling that really does end it" \
  -- bash "$BRIEF" task-001

# The other half: a fenced heading is not an anchor, so a doc_ref naming
# one resolves to nothing and the brief says so rather than printing the
# tail of some other section.
setup
task_file task-001 ready ""
cat > docs/product/chapter.md <<'MD'
# Chapter

## Real

real body

```markdown
## Fenced
```
MD
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#fenced|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "a fenced heading is no anchor" 2 "no heading with that anchor" -- bash "$BRIEF" task-001

# And it takes no number from the duplicate counter: the second *real*
# heading of a name is -1, whatever the fences in between spelled.
setup
task_file task-001 ready ""
cat > docs/product/chapter.md <<'MD'
# Chapter

## Outcome

the first one

```markdown
## Outcome
```

## Outcome

the second one
MD
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#outcome-1|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "the fence takes no suffix from the count" 0 "the second one" -- bash "$BRIEF" task-001

finish
