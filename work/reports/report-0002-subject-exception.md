---
id: report-0002
status: tracked
task_ref: [task-0032]
doc_ref: technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md
created: 2026-09-02T00:01:55Z
triaged: 2026-09-02T00:02:22Z
---

# The commit subject constant gained an exception nothing implements

**References:** [technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md) · [task-0032](../tasks/task-0032-subject-constant.md)

`.writrun/conventions/commits.md` opens by stating that the commit
subject is a constant — Conventional Commits, `type(scope): imperative
summary` — "in every project, whatever `settings.json`'s
`pr_title_style` declares", and that the key "reaches the pull request
title and stops there".

Forty lines later the same file now carries a paragraph that takes it
back. `8fe3069` ([Docs][Conventions] Scope the constant to what reaches
main, #93) added five lines to the end of "A branch's own subjects are a
convention kept by hand":

```
**So the constant above binds what reaches `main`** — the
squash subject and the machinery's own two — and not what a branch
carries on the way there: a branch subject that leads with `[TASK-NNNN]`
and dresses itself in the declared style is reading its own audience
right, and breaks nothing this file asks for.
```

**Nothing implements that exception, and two things contradict it.**
`check_observance.sh` reads `stage_2.pr_title_style` and judges the
title alone (lines 88–166). `commit_subject.sh` opens with "The subject
is a constant, and `pr_title_style` is not consulted", and the subjects
it writes are on `main` in that form — `chore(queue): record what the
merge decided`. No reader anywhere inspects a branch commit's subject,
so the paragraph does not describe a rule the machinery relaxed; it
describes one the machinery never had.

The observed effect is drift. Every subject on `task/0031-report-kind`
is in the title's style rather than the constant's, because the
paragraph says that is fine and the branch's own history modelled it:

```
[TASK-0031][Feat] The generator mints reports, and the gates read them
[TASK-0031][Tests] The merge mints a report mirror nobody made yet
[TASK-0031][Fix] The report mirror reads the branch, and defers every write
```

Two further details came out of reading those. `[Tests]` is not in the
file's type vocabulary at all — `docs, feat, fix, refactor, chore` — it
is a *scope*, spelled as a type. And the bracketed forms are
capitalised where the vocabulary is lower-case. Neither is caught,
because nothing parses these.

**Two permanent docs already say it, in those words.** Decision
[0063](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md):
"`stage_2.pr_title_style` governs the pull request title and nothing
else — the key's name was always exact; its reach was not. **The commit
subject is a constant**." And `technical/README.md`'s own section for
the key: "Governs every pull request title, including authoring ones,
which carry no task tag — and nothing else".

That is also what this repository settled four commits before the
exception appeared. `a94729a` ([TASK-0030][Refactor] The commit subject
stops reading the title style, #92) implemented spec-0042, whose goal
line reads:

```
- **Goal:** `pr_title_style` governs the pull request title and nothing
  else; the commit subject is Conventional Commits in every project,
  whatever the key declares.
```

So the exception is not a rule with two readings. It is one line of
prose in a convention file, contradicting two permanent documents, the
decision they rest on, the spec that implemented them, and both scripts
— and it is the only one of the six that a reader of `commits.md` alone
would find.

**Why this is worth a task rather than a note.** The settings are
binding: AGENTS.md ends its section on them with "where prose and
settings ever disagree, the settings file is what the machinery obeys,
so it is what you obey". A binding key whose documented reach is
ambiguous is the one kind of ambiguity that propagates — an agent
reading `commits.md` before committing will dress its subjects in the
declared style, which is exactly what happened on
`task/0031-report-kind`. `pr_title_style` refers to the pull request
title, and to nothing else.
