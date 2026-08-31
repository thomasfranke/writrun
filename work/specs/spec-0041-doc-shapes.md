---
id: spec-0041
task_ref: task-0024
status: draft
created: 2026-08-31T21:04:45Z
---

# spec-0041 — The shapes prose shows are checked, and retired words cannot ship

**References:** [task-0024](../tasks/task-0024-stale-examples.md)

- **Goal:** an example that would not survive the checker fails a run
  instead of teaching a newcomer the wrong shape, a fragment is never
  silently unchecked, and a word the vocabulary retires cannot stay
  standing in an instruction — least of all one shipped to an adopter.

## Scope

A schema is enforced where the machinery reads it, and nowhere else. Every
shape the prose *shows* is unheld, and four documents have drifted from
the shape they exist to teach.

**The two concept chapters print files no checker would accept.**
`product/concepts/task.md` shows a task with no `origin`, no `queued`, no
`merged`, no `provenance`, and `created: 2026-08-21` — a bare date, where
`check_front_matter.sh` takes `YYYY-MM-DDTHH:MM:SSZ` and nothing else.
`concepts/spec.md` carries the same bare date. The schemas in
`technical/README.md` are current, so the two halves of one contract
disagree and the half a newcomer reads first is the wrong one.

**The kit drifts for a structural reason.** The mirror test holds
`.writrun/` and the four workflows byte for byte; everything else under
`template/` is held by nothing. So `template/AGENTS.md` still gates
availability on `pending`, a status [spec-0018](spec-0018-stage-naming.md)
retired, and still tells the agent to "set spec `implemented` and task
`completed`" — the one write the status machinery has forbidden since
Stage 2. The kit's queue chapters still name files `task-001.md` and
`spec-001.md`; the corrected copies in this repository were fixed and the
shipped ones were not, and nothing noticed.

**Drafting this found more of the same class.** Both copies of
`writrun-check-spec-deltas/SKILL.md` teach `spec-004` — four occurrences
each, in the example commands an adopter is most likely to copy — and the
comment at the head of `check_front_matter.sh` illustrates a list as
`[spec-001, spec-002]`. The task named two files; the defect is in five.
That is the argument for the guard rather than for another round of
corrections.

In: the four documents the task names, the five this drafting found, and
two checks with one home each — one that runs the real checker over the
front matter prose shows, one that refuses a retired word in an
instruction. Their wiring into `writrun check` and the suite; their tests.

Out: **holding `template/`'s prose to the root's by a mirror.** The kit's
documents differ from this repository's on purpose — its `AGENTS.md` is a
skeleton with TODOs, its `work/` chapters address an adopter — so a byte
mirror would be false and a diff would be noise. What they share is the
*vocabulary*, and that is what gets held.

Out: **a checker for prose in general.** Nothing here reads English. Both
checks key off shapes a script can see without judgement: a fenced `yaml`
block, and a backticked word.

## Steps

1. **`check_doc_shapes.sh`**, in `.writrun/scripts/stage-2-pull-requests/`,
   over every `.md` under the directories it is given (default: `docs`,
   `template`, `.writrun`, and the root's own three). It reads fenced
   ` ```yaml ` blocks and nothing else.
2. **A block that opens with `---` is a whole front matter, and goes
   through the real checker.** The block is written to a scratch tree as
   `<id>-example.md` under `work/tasks` or `work/specs` — chosen by the
   `id` field, which the checker will hold against the filename anyway —
   and `check_front_matter.sh` is run over that tree. Same script, same
   rules, same messages, with the doc's line number prefixed to whatever
   it says.
3. **The example's `doc_ref` is materialised, not exempted.** The checker
   resolves `doc_ref` against a docs directory it takes as its third
   argument — which is what that argument is for. The scratch tree gets an
   empty file at whatever path the example names, so a fictional
   `product/editor/search-and-replace.md` stays legal in a teaching
   example while every other field is held exactly as a real file's is. An
   example that pointed at nothing would otherwise have to be rewritten to
   reference this repository, which teaches WritRun's own docs instead of
   the shape.
4. **A block that does not open with `---` is a fragment**, and is checked
   for key membership alone: every `key:` at its outermost indentation
   must be a field the schema documents. It is *named in the output* as a
   fragment checked that way — the `provenance:` block in
   `technical/README.md#task-schema` is one, and a fragment silently
   skipped is the same blindness this task exists to end.
5. **`tests/retired_vocabulary.txt`** — one line per retired word:
   `word replacement why`. Seeded with `pending ready` and `level stage`,
   both retired by [spec-0018](spec-0018-stage-naming.md) in one change.
   The file is the single source; retiring a word without adding its line
   is what the next round of this defect looks like, and `commits.md`'s
   two-lists rule is the precedent for saying so.

   Not seeded: `completed`, which spec-0018 retired as a *status value*
   and which is still a field name in every task file. A vocabulary of
   bare words cannot tell the two apart, so this file holds only words
   retired in every position they can appear.
6. **The retired word is refused in an instruction, never in a record.**
   The same script fails any **backticked** occurrence — `` `pending` ``,
   not the English word "pending" — under `docs/product/`,
   `docs/technical/` outside `decisions/`, `.writrun/`, `template/`, and
   the root's `AGENTS.md`, `README.md` and `CONTRIBUTING.md`. Exempt:
   `docs/technical/decisions/` and `work/`. History has to be able to name
   what it retired, and the queue records the migration that retired it;
   an instruction has no such need, and `template/work/README.md`'s plain
   English "what is pending" is untouched because it carries no backticks.
7. **Fix the nine documents.** `concepts/task.md` and `concepts/spec.md`
   gain the fields and the timestamps their schemas state — task.md's
   example carrying `provenance: []`, which the schema now has.
   `template/AGENTS.md` loses `pending` for `ready` and stops inviting the
   agent to write `implemented`/`completed` onto a status line the
   machinery owns from Stage 2. `template/work/tasks/README.md` and
   `template/work/specs/README.md` name four digits and a subject slug.
   Both copies of `writrun-check-spec-deltas/SKILL.md` say `spec-0004`,
   and `check_front_matter.sh`'s head comment says
   `[spec-0001, spec-0002]`.
8. **Wired where the others are.** A job in `writrun-check.yml` beside
   the existing checks, at the same stage gate, and a case directory in
   the suite. `make template-sync`; suite.

## Acceptance criteria (EARS)

- When a fenced `yaml` block in a checked document opens with `---`, the
  system shall validate it with `check_front_matter.sh` and report any
  fault with the document's path and the block's starting line.
- When such a block names a `doc_ref` that exists nowhere, the system
  shall accept it, because the scratch tree materialises the path the
  example names.
- When a fenced `yaml` block does not open with `---`, the system shall
  check every outermost key against the schema's fields and say in its
  output that the block was read as a fragment.
- When a fragment carries a key the schema does not document, the system
  shall fail, naming the key and the document.
- When a word in `tests/retired_vocabulary.txt` appears backticked in a
  checked instruction, the system shall fail, naming the replacement.
- When the same word appears under `docs/technical/decisions/` or under
  `work/`, the system shall pass.
- When the same word appears unbackticked in ordinary prose, the system
  shall pass.
- When `writrun check` runs from Stage 2, it shall run this check.

## Edge cases

- **A `yaml` block that is neither** — a settings file example, say. It
  opens with `{`, not `---`, so it is read as a fragment, and its keys are
  not schema fields. The fragment rule is therefore *keys are schema
  fields **or** the block is not front matter at all*: the check reads
  only blocks whose first key is one the schema documents, and says how
  many blocks it skipped for that reason.
- **Two examples in one document.** Each is its own scratch file; the
  second must not overwrite the first, so the scratch name carries the
  block's line number.
- **An example that is deliberately wrong** — a chapter showing what the
  checker refuses. None exists today. If one is written, it is fenced as
  ` ```text ` rather than ` ```yaml `, and that is the documented escape:
  the language tag is the declaration of intent.
- **A retired word inside a fenced block.** Held like any other text — a
  code example teaching `status: pending` is exactly the failure this
  catches, and it is caught by the front-matter half anyway.
- **A word retired and later revived.** Its line is deleted from the
  vocabulary file. Nothing else moves; the file is the single source.
- **`work/` is exempt from the retired-word rule, and is not exempt from
  its own front matter being canonical.** `check_front_matter.sh` already
  reads the live queue; this check never looks there.

## Tests required

A document whose example is stale fails, naming the file and the line. A
current example passes. An example whose `doc_ref` names nothing passes,
and the same example with a malformed `created` fails — the two together
are what proves the scratch tree materialises the path rather than
disabling the check. A fragment with only schema keys passes and is
reported as a fragment; a fragment with an undocumented key fails. A block
that is not front matter at all is skipped and counted. Two examples in
one file are both checked. A backticked retired word fails under
`template/` and passes under `docs/technical/decisions/`; the same word
unbackticked passes. A case reading `tests/retired_vocabulary.txt` for its
seeded lines, so a deletion is deliberate.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] The nine documents pass the new check, and it fails each of them as
      they stand today.
- [ ] `writrun check` runs it from Stage 2; template synced; suite green.

## Proposed product changes

- none — no product rule changes. The concept chapters are corrected to
  the schema they already claim, which is a shape catching up with its
  own statement, not a new rule.

## Proposed technical changes

- `technical/README.md#task-schema` — the example a reader copies is the
  one a check reads, and the `provenance:` fragment is named as a
  fragment.
- `technical/README.md#front-matter-is-canonical` — the canonical form is
  held wherever it is *shown*, not only where it is stored.
- `technical/README.md#distribution` — the kit's prose is held to the
  current vocabulary; the mirror holds bytes, this holds words.
- `technical/decisions/tasks-and-specs/0062-a-shown-shape-is-a-checked-shape.md`
  — the dated why: an example is documentation that lies with a straight
  face, and the checker that reads files can read blocks.

## Outcome

_(fill after execution)_
