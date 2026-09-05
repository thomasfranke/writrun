---
id: report-0033
status: tracked
task_ref: [task-0055]
doc_ref: technical/settings/titles.md#pr_title_style
created: 2026-09-05T13:27:27Z
triaged: 2026-09-05T13:27:36Z
---

# The task tag is composed with a space the declared style does not carry

**References:** [technical/settings/titles.md#pr_title_style](../../docs/technical/settings/titles.md#pr_title_style) · [task-0055](../tasks/task-0055-tag-space-by-style.md)

`take_task.sh` prepends the tag with a trailing space, whatever the
declared style: line 285 reads
`PR_TITLE=$(printf '[TASK-%04d] %s' "$NUM" "$TITLE")`. The space is not
conditional and nothing downstream removes it, so every implementing
pull request this repository has opened carries one — including
[#204](https://github.com/thomasfranke/writrun/pull/204), whose title
reads `[TASK-0050] [Feat][Ci] What one pull request may claim is
bounded`.

The declared style spells it without one. `pr_title_style` is
`bracketed` here, and both places that state the form agree:
`settings/titles.md` gives `[TASK-0007][Feat][CI] Record approval on the
merge`, and `session_card.sh` prints
`[TASK-0012][Fix][Ci] Debounce the mirror updates`. The card is the file
this project's own entry point tells a session to run for a value.

`conventional` is the style the space belongs to —
`[TASK-0007] feat(ci): record approval on the merge` — and it is spelled
that way in the same two places. One format string serves both, and it
is the wrong one for the style declared here.

Nothing failed, which is why it stood. `check_observance.sh` strips one
optional space before judging the summary
(`summary="${summary# }"`, line 111), with the reason stated beside it:
a title with none reads as one word to a human scanning it. That
tolerance is what let the composer and the declaration disagree without
a gate ever objecting.
