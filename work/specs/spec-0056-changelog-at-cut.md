---
id: spec-0056
task_ref: task-0040
status: draft
created: 2026-09-03T03:35:00Z
---

# spec-0056 — The release cut writes the changelog it publishes

**References:** [task-0040](../tasks/task-0040-changelog-at-cut.md)

- **Goal:** `make release` leaves `CHANGELOG.md` at the root carrying the
  entries for the tag it just cut, so a copy pinned to a version answers
  "what changed" without leaving the checkout — and carries it in the
  same commit as the stamp, so the two can never disagree.

## Scope

In: `scripts/release.sh` composing and prepending the entries; the file
itself; the tests; the sentence in the release chapter that the rule was
authored into.

**Composed from the range, never from the forge.** The entries are the
commit subjects between the last tag and `HEAD`, read with `git log` and
grouped by conventional type. Asking GitHub to generate them would put
the cut's own content behind a network call that fails differently than
the rest of the script, and behind a tag that does not exist yet at the
moment the file must be staged.

**Where it sits in the cut is not free.** The write happens *after* the
template-sync drift guard — that guard aborts on any dirty path that is
not one of the two version stamps, so a changelog written before it
aborts the release it belongs to — and before `git add`, which gains the
file as a third staged path.

Out: `check_doc_shapes.sh` reading the file. It is generated, holds no
front matter and no fenced shape, and adding it to the roots would put a
generator's output under a checker meant for prose a person wrote.

Out: back-filling `v0.0.01` and `v0.0.02`. The file starts at the first
tag cut after this ships; a history written after the fact from the same
subjects would read as though it had been there, and it was not.

## Steps

1. `scripts/release.sh`: after the drift guard, compose the section for
   `$next` — a `## <tag> — <date>` heading, then one bullet per subject
   grouped under its type, in the order the type list declares — and
   prepend it to `CHANGELOG.md`, creating the file with a title when it
   does not exist.
2. Stage it beside the two stamps in the existing `git add`, so the
   `chore(release): <tag>` commit carries all three.
3. Tests under `tests/integration/release/`.
4. The doc line the rule was authored into stays the statement; this
   spec adds no second one.

## Acceptance criteria (EARS)

- When a release is cut, `CHANGELOG.md` shall gain a section for the new
  tag at the top of the file, and the commit that carries the version
  stamps shall carry it too.
- When `CHANGELOG.md` does not exist, the cut shall create it with a
  title and the first section under it.
- When the range holds a subject that is not conventional, the cut shall
  list it verbatim under an "Other" group rather than dropping it.
- When the range between the two tags is empty, the cut shall write a
  section naming the tag and stating that no commit landed — never an
  empty heading.
- When the drift guard aborts, the cut shall leave `CHANGELOG.md`
  untouched.
- When the suite fails, the cut shall abort with the changelog written
  but nothing committed, exactly as it leaves the stamp today.

## Edge cases

- **The first cut after this ships.** The file does not exist and the
  previous tag does: the section covers that range, and the title is
  written above it.
- **A subject carrying a scope the vocabulary does not have.** It is
  still conventional in shape, so it is grouped by its type; the
  vocabulary is `check_observance.sh`'s to judge, at the pull request,
  not the changelog's to re-judge at the tag.
- **A squash subject with the forge's `(#NN)` suffix.** Kept as written
  — it is the hop back to the pull request, and rewriting it would drop
  the only link an entry has.
- **`epoch` and `major` cuts.** No special case: the range is
  last-tag-to-HEAD whatever the bump word did to the number.
- **A dirty `CHANGELOG.md` before the cut.** Refused by the guard that
  already refuses every dirty path but the two stamps — the file is the
  script's to write, and a hand-edit reaching a tag is the drift this
  design exists to prevent.

## Tests required

A cut that creates the file; a cut that prepends to an existing one and
leaves the older section below; the empty range; a non-conventional
subject landing under "Other"; the `(#NN)` suffix preserved; the drift
guard aborting with the file untouched; a red suite aborting with
nothing committed. The existing release tests keep covering the stamp
and the tag.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] One commit carries the stamps and the changelog section.
- [ ] Suite green; `make release` rehearsed against a scratch remote.

## Proposed product changes

- none — the changelog is machinery of the cut, and no product rule
  changes: the version vocabulary, the stages and the gates are
  untouched.

## Proposed technical changes

- none — the rule is authored into
  `technical/distribution.md#distribution` by the change that creates
  this spec, and the completing change adds nothing to it that the rule
  does not already say.

## Outcome

_(fill after execution)_
