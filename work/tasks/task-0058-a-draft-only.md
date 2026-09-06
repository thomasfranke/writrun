---
id: task-0058
status: ready
blocked_reason: null
taken_by: null
spec_ref: [spec-0082]
doc_ref: product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-05T23:55:44Z
queued: 2026-09-06T00:06:51Z
completed: null
merged: null
provenance: []
---

# A draft-only change owes no derived work

**References:** [product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet](../../docs/product/stage-1-tasks-and-specs/authoring.md#a-chapter-that-is-not-a-rule-yet) · [spec-0082](../specs/spec-0082-a-draft-only.md)

A chapter that declares itself a draft is not a rule, so a change that
only touches drafts commits the project to nothing and has nothing to
declare. `check_derived_work.sh` does not know that yet: it reads every
path under `docs/` as permanent, so the first draft chapter pushed to the
authority branch is refused until somebody writes "Derived work: none" —
a declaration about a rule that does not exist.

Teach that one check what a draft chapter is.

It matters because the check is the gate the whole marker has to pass to
be usable at all. Without it the rule is written and unreachable: every
draft a stakeholder is meant to read costs a false declaration on the way
in, and a declaration that means nothing is the thing the "empty and
forgotten look identical" reasoning exists to prevent — said of derived
work, and true of this too.
