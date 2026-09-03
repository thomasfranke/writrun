---
id: report-0016
status: authored
task_ref: []
doc_ref: technical/distribution.md#distribution
created: 2026-09-03T13:13:38Z
triaged: 2026-09-03T20:18:25Z
---

# The changelog's stated reader is the one copy that never gets it

**References:** [technical/distribution.md#distribution](../../docs/technical/distribution.md#distribution)

The rule authored for the release cut names the adopter as the reader:
"an adopter — and the future `writ update` — holds a copy of a tag, and
asking what changed since the tag before it should not require leaving
the checkout for the Releases page"
(`technical/distribution.md#distribution`).

The adopter's checkout never receives the file. `tests/template_mirrors.txt`
carries `.writrun` and the four workflows and nothing else, and the cut
writes `CHANGELOG.md` at this repository's root. So an adopter holds the
mirrored `.writrun/VERSION` stamp, which says *which* tag they came from,
and still has to leave the checkout to learn what it changed — which is
the trip the sentence says the change removes. The reader the rule
actually reaches is somebody with a WritRun clone.

Two ways out, and choosing between them is a rule decision rather than
this observation's: the kit carries the changelog — mirrored, or written
under `.writrun/` where the stamp already lives — or the sentence names
the clone instead of the adopter. The first makes the promise true and
hands an adopter a second history at their own root, which is a cost
worth stating; the second is one sentence.

Observed while reviewing task-0040, which implements the cut faithfully.
Nothing in `spec-0056` is wrong — it promises no doc change, and the
sentence it implements was authored one change earlier.

**Triage:** the second way out is the rule, and it is now authored —
`technical/distribution.md#distribution` names the WritRun clone the file
reaches, and states that the kit does not carry it. The first was
weighed and rejected: shipping `CHANGELOG.md` into an adopter's checkout
hands them a second history at their own root, a real cost, for a
benefit the mirrored `.writrun/VERSION` stamp already partly covers. If
a future `writ update` needs the file, that is the change that earns it.
