---
id: task-0032
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: []
doc_ref: technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md
origin: report
priority: medium
depends_on: []
milestone: null
created: 2026-09-02T00:02:22Z
queued: 2026-09-02T00:45:35Z
completed: null
merged: null
provenance: []
---

# The commit subject constant loses its exception

**References:** [technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md)

Remove the exception `8fe3069` (#93) added to
[`conventions/commits.md`](../../.writrun/conventions/commits.md), so
the file says what the rest of the repository already says:
**`stage_2.pr_title_style` governs the pull request title and nothing
else, and a commit subject is Conventional Commits everywhere.**

The five lines to drop are the ones scoping the constant to "what
reaches `main`" and blessing a branch subject "dressed in the declared
style". The paragraph they were appended to stays — that a branch's
subjects are kept by hand, and that no gate reads them, is true and
worth saying. What is not true is that the constant stops at the branch.

Why it matters, and why prose rather than machinery: the settings are
binding on everyone who works here, so a key whose documented reach is
ambiguous propagates the ambiguity into every commit an agent writes.
This is not hypothetical — the branch that recorded
[report-0002](../reports/report-0002-subject-exception.md) had all eight
of its own subjects in the title's style, because `commits.md` is the
file an agent reads before committing and it said that was fine.

Nothing needs to be built. Decision
[0063](../../docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md),
`technical/README.md`'s section for the key, spec-0042 and both scripts
(`check_observance.sh` judges the title alone; `commit_subject.sh` does
not consult the key) are already correct and unchanged by this.

Two smaller things surfaced with it, and belong to whoever takes this:
the bracketed forms in use capitalise a vocabulary the file spells in
lower case, and `[Tests]` is written as a type when `tests` is a scope.
Neither is parsed by anything, which is why both survived.
