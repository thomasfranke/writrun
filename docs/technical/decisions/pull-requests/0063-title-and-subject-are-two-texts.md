# the pull request title and the commit subject are two texts.

**2026-09-01**

[0046](0046-the-task-tag-leads.md) reasoned from "squash-only means the
title *is* the commit subject on `main`", and
[0052](../tasks-and-specs/0052-settings-carry-the-choice.md) carried the
same premise further, handing `pr_title_style` "every title a project
writes". The premise is a **forge default, not a mechanism**: the squash
dialog hands the merging maintainer an editable subject, and the
repository's *default commit message for squash merging* setting only
chooses which pull request field seeds it. Two texts have been passing
for one because nobody ever edited the second.

Separated here. `stage_2.pr_title_style` governs the pull request title
and nothing else — the key's name was always exact; its reach was not.
**The commit subject is a constant**: Conventional Commits,
`type(scope): summary`, over the vocabularies
[`conventions/commits.md`](../../../../.writrun/conventions/commits.md)
carries. No project sets it. A style is worth offering where the readers
differ, and the readers of a title differ — a queue of open pull requests
is read by the people working it. `main` is read by tooling, by bisect,
by release automation and by whoever arrives in a year, and that audience
is the same everywhere.

The `[TASK-NNNN]` tag follows the title, not the subject. That gives up
the property 0046 says the tag exists for: `git log --grep '[TASK-0012]'`
on `main` stops finding a task's commits. What replaces it is the `(#NN)`
the forge appends to a squash subject — one hop to the pull request,
which still carries the tags and is still what the machinery parses. A
grep became a link. The left-edge argument that put the tag first
survives where it still applies: the title, which is read in a list of
pull requests exactly the way a subject is read in a log.

The machinery's own commits stop consulting the key.
`commit_subject.sh` composed four literals from it because a subject in
the undeclared style would sit on `main` for good; with one style
declared for subjects everywhere, it composes two and reads no setting
at all.

**Nothing enforces the subject, and that is the accepted cost.**
`writrun check` reads titles at the door; these subjects pass no door —
the maintainer types them in the merge box, and a forgotten edit lands a
bracketed subject on `main` silently. Rejected: merging through the API
with an explicit `--subject`, which trades the forge's own button for a
command and still has to derive a type and scope from a sentence;
rejected too, a check reading `main` after the fact, which reports what
it cannot prevent. No forge setting derives a conventional subject from a
bracketed title, so there was no passive option to take. This
repository's merges are one person's, and the cost of a miss is one
imperfect subject, never a broken guarantee.
