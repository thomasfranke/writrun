---
id: task-0055
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: []
doc_ref: technical/settings/titles.md#pr_title_style
origin: report
priority: low
depends_on: []
milestone: null
created: 2026-09-05T13:27:36Z
queued: 2026-09-05T13:41:35Z
completed: null
merged: null
provenance: []
---

# Compose the task tag as the declared title style spells it

**References:** [technical/settings/titles.md#pr_title_style](../../docs/technical/settings/titles.md#pr_title_style)

Compose the `[TASK-NNNN]` tag the way the declared style spells it: no
space before the summary under `bracketed`, the space kept under
`conventional`. Today one format string serves both and carries the
space always, so every implementing pull request opened here is titled
against the project's own settings card.

It matters because the card is what a session is told to run for a
value, and a title that disagrees with it teaches the disagreement to
every agent that reads an existing pull request to learn the form. The
checker's tolerance for the space stays as it is — this is the composer
matching the declaration, not the declaration narrowing.
