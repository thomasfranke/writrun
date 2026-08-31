---
id: task-0020
status: done
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0022, spec-0023, spec-0024, spec-0025]
doc_ref: technical/README.md#settings
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-30T13:15:57Z
queued: 2026-08-30T22:44:13Z
completed: 2026-08-30T23:05:45Z
merged: 2026-08-31T02:33:23Z
---

# Settings live at WritRun's root, sectioned by stage, and govern the agent's git actions

**References:** [technical/README.md#settings](../../docs/technical/README.md#settings) · [spec-0022](../specs/spec-0022-settings-at-root.md) · [spec-0023](../specs/spec-0023-stage-sections.md) · [spec-0024](../specs/spec-0024-ai-action-flags.md) · [spec-0025](../specs/spec-0025-ai-credit-flag.md)

The settings file is where an adopter's choices live, and three things
about it no longer match what the docs now state. It sits in a corner of
WritRun's home rather than at its root, so the first place a reader
looks is not where it is. Its keys sit in one undivided list, while
everything else that belongs to a stage carries that stage on its name —
a reader at Stage 1 cannot tell which choices are theirs to ignore. And
it offers the adopter no say over the agent's own git actions: whether
the agent commits and opens pull requests on its own, and whether its
commits credit it, are today the agent platform's choices, not the
project's.

Bring the file and its readers up to the rule the technical doc now
states: the file lives at WritRun's root, its choices are sectioned by
stage, and it carries the adopter's word on the agent's conduct —
`auto_commit`, `auto_pr` and `credit_ai` — a word that binds the agent
even when its own platform would not ask.
