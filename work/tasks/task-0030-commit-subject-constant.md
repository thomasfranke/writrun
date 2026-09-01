---
id: task-0030
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0042]
doc_ref: technical/README.md#pr_title_style
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-01T13:18:38Z
queued: 2026-09-01T13:33:40Z
completed: 2026-09-01T19:05:00Z
merged: null
provenance:
  - {by: agent, model: claude-opus-5, login: thomasfranke, input: 246, output: 56580, cache_read: 11292308, cache_write: 89555}
---

# The commit subject is conventional whatever the title style

**References:** [technical/README.md#pr_title_style](../../docs/technical/README.md#pr_title_style) · [spec-0042](../specs/spec-0042-commit-subject-constant.md)

`pr_title_style` reaches further than its name: it shapes the commit
subjects the machinery writes as well as the pull request titles agents
compose. That was sound while the two were believed to be one text — a
squash puts the title on `main`, so the setting appeared to govern one
thing under two names. It is not one text. The forge's squash dialog
hands the merging maintainer an editable subject; the title only seeds
it.

Bring the system up to [0063](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md):
the key keeps the pull request title, and the commit subject becomes a
constant — Conventional Commits, in every project, whatever the title
style declares. The `[TASK-NNNN]` tag goes with the title and stops
appearing in the subject.

It matters because `main` and the pull request queue have different
readers. A queue is worked by the people who wrote it; `main` is read by
bisect, by release tooling, and by whoever arrives a year later — an
audience that is the same in every project and is not served by a
per-project grammar. The setting should offer a choice where the readers
differ and stay silent where they do not.
