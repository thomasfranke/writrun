---
id: report-0001
status: open
task_ref: []
doc_ref: null
created: 2026-09-01T20:23:51Z
triaged: null
---

# The conventions folder has no scope in the vocabulary

`writrun check` rejected the title of #93, which changed
`.writrun/conventions/commits.md` and a script beside it:

```
REJECTED: the title's scope 'Conventions' is outside the vocabulary
(about product technical tasks specs skills ci tests agents readme setup
queue): '[Docs][Conventions] Scope the constant to what reaches main'
```

The rejection is correct — `Conventions` is not in the list. What the
list has no word for is the folder the change was actually in.
`.writrun/conventions/` is a subsystem with files, a README and a
sentence in `AGENTS.md` naming it, and every other subsystem a change
can be about has a scope: `skills`, `ci`, `tests`, `setup`, `queue`.
Read down the eleven, the nearest are `setup` (the adoption kit) and
`agents` (`AGENTS.md`), and neither is where `commits.md` lives.

The title landed as `[Docs]` with no scope, which is the documented
answer for a change that genuinely spans the repository — and #93 nearly
did, touching the conventions file, a script, the `template/` mirror and
a spec. So nothing was lost this time. What was observed is that a
change about the conventions folder alone has no honest scope to write,
and the vocabulary that decides is inside that same folder.

Noticed while opening #93, during task-0031. Not investigated further —
whether the answer is a twelfth word, a rename of an existing one, or
that the folder is deliberately scopeless, is triage's to decide and
would be an authoring change either way: the two vocabularies in
`commits.md` are what `check_observance.sh` accepts, and the file says
outright that editing one means editing the other.
