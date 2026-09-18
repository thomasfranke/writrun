---
id: spec-0098
task_ref: task-0070
status: implemented
created: 2026-09-17T19:41:37Z
---

# spec-0098 — One word and one silent read, fixed where the author meets them

**References:** [task-0070](../tasks/task-0070-technical-section-doc.md)


- **Goal:** An author meets the technical section's meaning in the three
  texts that teach it, and a promise the gates cannot read is refused
  where the spec enters instead of read as none.

## Scope

Two halves, one contract.

**The word.** Three texts say what the section is, and each currently
says or implies *machinery*:

- `.writrun/templates/spec.md` — the technical section's fallback line.
- `docs/technical/schemas/spec.md#spec-schema` — the example block's
  fallback line beside `technical/engine/adapter.md`.
- `docs/product/concepts/spec.md#the-doc-delta-contract` — the same
  fallback line in the contract's own code block.
- `.writrun/skills/writrun-create-task-and-spec/SKILL.md`, *Creating a
  spec* — the paragraph asking for "real entries".

**The silent read.** `promised_written` in `check_promise_paths.sh` and
`extract_paths` in `check_deltas.sh` carry the same awk line, reading a
bullet only when a backtick follows the dash. One reader, in
`queue_lib.sh` ([0072](../../docs/technical/decisions/pull-requests/0072-a-shared-helper-has-one-copy.md)),
and the promise gate refuses what that reader cannot take.

`.writrun/` is carried whole by `tests/kit_mirrors.txt`; the kit copies
come from `make kit-sync`.

**Out of scope.** The completion gate keeps reading what it reads
today: a spec that reached the base branch carrying an unreadable
bullet is out of the promise gate's reach, the same boundary the
companions check draws, and `check_deltas.sh` is not made to guess at
it. The product section's fallback line is touched only where the
technical one is, for symmetry of wording, never of meaning.

## Steps

1. Reword the technical fallback to name the documents, not the code —
   *"none — no technical chapter changes"* — in the template, the schema
   example and the contract's code block, so the three agree.
2. In the skill's *Creating a spec* paragraph, state in one sentence
   that every entry is a path read relative to `docs/`, and that the
   technical section names chapters under `docs/technical/` — the
   machinery is what the completing diff changes, never what it
   promises.
3. Move the bullet reader into `queue_lib.sh` as one function both
   gates call, returning the backticked path of each bullet and, for
   the promise gate's use, every non-empty top-level bullet under either
   heading that carries no backticked path at its start.
4. In `check_promise_paths.sh`, a fourth condition: an unreadable
   bullet. The refusal names the spec, the section and the bullet's
   text, and its closing advice states the form the gates read —
   *a bullet opens with the path in backticks*. The "nothing to judge"
   line prints only when no section carried any bullet at all.
5. `make kit-sync`.
6. Record the decision: a promise the gate cannot read is refused, never
   read as none.

## Acceptance criteria (EARS)

- When an author reads the spec template, the technical section's
  fallback line shall name the technical chapters, never the machinery.
- When the skill says what a Proposed-changes entry is, it shall say the
  path is read relative to `docs/` and that the technical section names
  chapters under `docs/technical/`.
- When either Proposed-changes section carries a non-empty bullet that
  does not open with a backticked path, `check_promise_paths.sh` shall
  refuse the spec naming that bullet, and shall not print "nothing to
  judge".
- When a section carries only its "none" line, both gates shall read it
  as no promise, as today.
- When a bullet opens with a backticked path, its reading shall be
  unchanged in both gates.
- When the kit is synced, the three texts shall carry the same fallback
  wording.

## Edge cases

- **The "none" line is a bullet too.** `- none — …` is the one
  non-backticked bullet both gates already accept, and the new reader
  recognises it by its leading word, not by its full text: an adopter
  who wrote *"none — nothing here"* keeps passing.
- **A wrapped bullet.** Continuation lines are indented and never start
  with `- `, so a long entry is one bullet; only top-level bullets are
  judged.
- **A backtick that is not first** — `- **spec** \`path\`` — is
  refused, because that is exactly the form the old reader dropped in
  silence and the new one must name.
- **A spec already on the base branch** with an unreadable bullet is not
  re-judged by the promise gate; the change's own diff is its range.
- **Both sections absent** is not this check's question; the doc-shapes
  check owns headings.

## Tests required

- Unit for the shared reader: the backticked form, the "none" form, a
  link-form bullet, a wrapped bullet, a bold-then-backtick bullet.
- Integration for `check_promise_paths.sh`: a link-form bullet exits 1
  naming spec, section and bullet; "none" alone passes; a backticked
  promise passes exactly as before; the "nothing to judge" line prints
  only for a change adding no bulleted promise.
- `check_deltas.sh` keeps its existing cases green through the shared
  reader.
- The kit mirror unit test passes with no new exception.

## Definition of Done

- [ ] Template, schema example, contract block and skill agree on what
      the technical section names.
- [ ] One bullet reader, in `queue_lib.sh`, used by both gates.
- [ ] A link-form bullet is refused at spec entry, by name.
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- `product/concepts/spec.md#the-doc-delta-contract` — the fallback line
  in the contract's code block names the technical chapters; one
  sentence: a bullet the gate cannot read as a path is refused where the
  spec enters, never read as no promise.

## Proposed technical changes

- `technical/schemas/spec.md#spec-schema` — the example block's
  technical fallback line, and one clause saying the paths are read
  relative to `docs/`.
- `technical/decisions/pull-requests/0078-a-promise-the-gate-cannot-read-is-refused.md`
  — the record: why an unreadable bullet is a refusal and not an empty
  set, and why the reader has one copy.
- `technical/decisions/README.md` — the index gains the record's line.

## Outcome

Built as planned, with one copy more than the plan counted and one
sentence of the plan not kept.

**Three readers, not two.** The pin the private-copy test gained found
the awk fragment in `check_promise_companions.sh` as well — a copy its
own comment defended as deliberate, on the argument that the completion
gate is a Stage 1 skill and must not couple to workflow machinery. The
lib is what every skill already sources, so the argument had lapsed;
that gate now calls `ql_promised_paths` too, and the pin covers
`.writrun/` whole rather than `scripts/` alone.

**"Nothing to judge" still prints for a skeleton of `none`.** Step 4
said the line prints only when no section carried any bullet at all,
which would have made the `none` bullet a read spec. The acceptance
criterion says a section carrying only its `none` line is read as no
promise, as today, and the existing case asserts the line for exactly
that spec; the criterion won. What changed is narrower: a spec whose
only bullets are unreadable is counted as read and refused, where it
used to print that line and pass.

The unreadable reader recognises `none` by its leading word, so an
adopter's own wording after the dash keeps passing — the edge case as
written. The refusal names the spec, the section and quotes the bullet,
and its closing advice states the form both gates read.

`concepts/spec.md#the-doc-delta-contract` also drops *"one `.md`
file"* for *"one document"* — the sentence task-0066 outgrew, named in
the reporting pull request as a leftover and sitting in the section
this spec already promised.

