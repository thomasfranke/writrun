---
id: spec-0041
task_ref: task-0024
status: approved
created: 2026-08-31T21:04:45Z
---

# spec-0041 — The shapes prose shows are checked, and retired words cannot ship

**References:** [task-0024](../tasks/task-0024-stale-examples.md)

- **Goal:** an example that would not survive the checker fails a run
  instead of teaching a newcomer the wrong shape, no fenced block is
  silently unread, and a word or an id shape the vocabulary retired
  cannot stay standing in an instruction — least of all one shipped to
  an adopter.

## Scope

A schema is enforced where the machinery reads it, and nowhere else. Every
shape the prose *shows* is unheld, and eight files have drifted from the
shape they exist to teach.

**The two concept chapters print files no checker would accept.**
`product/concepts/task.md` shows a task with no `origin`, no `queued`, no
`merged`, and `created: 2026-08-21` — a bare date, where
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

**Drafting this found three more of the same class.** Both copies of
`writrun-check-spec-deltas/SKILL.md` teach `spec-004` — four occurrences
each, in the example commands an adopter is most likely to copy.
`writrun-create-task-and-spec/SKILL.md` prints the front matter the
generator writes and is two fields behind what `new.sh` actually writes:
no `queued`, no `merged`, and `created: <today, ISO date>` where the
generator writes an RFC 3339 timestamp — the chapter that teaches the
canonical shape teaches the bare date the checker refuses. And the
comment at the head of `check_front_matter.sh` illustrates a list as
`[spec-001, spec-002]`, states four lines later that "dates are
YYYY-MM-DD" where its own `check_date` demands a timestamp, and prints a
third three-digit id in `check_list`'s error message. The task names four
documents — five files, since the kit's queue chapters are two of them;
the defect is in eight. That is the argument for the guard rather than
for another round of corrections.

In: those eight files — three of which the mirror doubles into
`template/` — and one check with three rules: the shape a block shows,
the word an instruction uses, the width an id is written to. Its home,
`check_front_matter.sh` naming the field list the shape rule reads, the
wiring into `writrun check` and the suite, and the tests.

Out: **holding `template/`'s prose to the root's by a mirror.** The kit's
documents differ from this repository's on purpose — its `AGENTS.md` is a
skeleton with TODOs, its `work/` chapters address an adopter — so a byte
mirror would be false and a diff would be noise. What they share is the
*vocabulary*, and that is what gets held.

Out: **a checker for prose in general.** Nothing here reads English. All
three rules key off shapes a script can see without judgement: a fenced
block, a backticked word, a backticked id.

Out: **the shapes inside scripts.** The check reads `.md` and nothing
else, because a script's comments legitimately carry the very strings the
rules refuse while explaining the history that retired them: `new.sh`
says what it does when the argument names `task-1` or a historical
`task-001`, `mirror_issues.sh` keeps `task-004`'s own width rather than
padding it, `read_setting.sh` names the `level` precedent. A rule that
failed those three would be wrong about all three. So
`check_front_matter.sh`'s head comment is corrected by hand here and is
not guarded afterwards — stated in the Definition of Done rather than
implied by a count.

## Steps

1. **`check_doc_shapes.sh`**, in `.writrun/scripts/stage-2-pull-requests/`,
   over every `.md` under the directories it is given (default: `docs`,
   `template`, `.writrun`, and the root's `AGENTS.md`, `README.md` and
   `CONTRIBUTING.md`), skipping `docs/technical/decisions/` entirely.
   One scan set, three rules, no per-rule exceptions to keep straight.
   `work/` is not in the set and needs no exemption: the queue is a
   record, `check_front_matter.sh` already reads its files, and its prose
   is free to name what it retired.

2. **The shape rule: the fence declares what a block is, and there is no
   fourth answer.**
   - ` ```yaml ` opening with `---` — a canonical front matter, checked
     in full.
   - ` ```yaml fragment ` — part of one, checked for key membership.
   - ` ```yaml ` that is neither — **fails**, naming the document and the
     fence's line and stating the two ways to declare the block. A block
     nobody classified is the blindness this task exists to end, so it is
     loud rather than skipped.
   - ` ```text ` — not read at all. The documented escape for a block
     that is deliberately not canonical.

3. **A canonical block goes through the real checker.** It is written to
   a scratch tree **of its own** as `work/tasks/<id>-example.md` or
   `work/specs/<id>-example.md` — chosen by the `id` field, which the
   checker holds against the filename anyway. One tree per block, so two
   examples in one document and two documents printing the same id can
   neither collide nor overwrite; `technical/README.md#task-schema` and
   `concepts/task.md#example` both print `task-0005` today. Same script,
   same rules, same messages — with the scratch path substituted back to
   `<document>:<line of the fence>` before anything is printed. The
   checker names the file it read; the reader needs the file they wrote.

4. **The annotation is stripped, because the annotation is not the
   file.** A trailing comment and the whitespace before it are removed
   before validation, where a comment is a `#` **preceded by whitespace**
   — YAML's own rule, and the one that keeps
   `doc_ref: product/concepts/task.md#two-invariants` whole. This is what
   makes `technical/README.md`'s two schema blocks checkable as what they
   are: every field of a real file with its meaning beside it. The
   checker's "no comments" clause binds a stored file, not the prose that
   annotates one, and stripping is the operation that recovers the first
   from the second.

5. **The example's `doc_ref` is materialised, not exempted.** The checker
   resolves `doc_ref` against a docs directory it takes as its third
   argument — which is what that argument is for. The scratch tree gets
   an empty file at whatever path the example names, so a fictional
   `product/editor/search-and-replace.md` stays legal in a teaching
   example while every other field is held exactly as a real file's is.
   An example that pointed at nothing would otherwise have to be
   rewritten to reference this repository, which teaches WritRun's own
   docs instead of the shape.

6. **A declared fragment is checked for key membership.** Every `key:` at
   the block's outermost indentation must be a field the schema
   documents, and the block is *named in the output* as a fragment
   checked that way. The `provenance:` block in
   `technical/README.md#task-schema` is the one that exists today, and it
   gains its ` fragment ` declaration in this change.

7. **The field list has one home, and it is the script that enforces
   it.** `check_front_matter.sh` moves its two inline `for field in ...`
   lists into declared lists at the top and grows a `--fields task|spec`
   mode that prints them; `check_doc_shapes.sh` reads their union.
   Nothing here creates a fourth copy of the schema beside the README,
   the checker and `new.sh` — it removes the checker's copy from the
   middle of a loop and gives it a name.

   The declared form carries a distinction the inline one could not:
   `provenance` is a **documented but not required** task field.
   `technical/README.md` states it is always present and stays `[]`,
   while `new.sh` does not write it and no queue file carries it yet. The
   fragment rule accepts it; `require_once` still does not demand it, so
   no queue file changes here. Closing that gap is the machinery's
   catch-up rather than this spec's, and the declared list is where the
   change that closes it will land.

8. **The word rule reads `retired_vocabulary.txt`, which lives beside the
   script that reads it** — `.writrun/scripts/stage-2-pull-requests/retired_vocabulary.txt`,
   one line per retired word: `word replacement why`. Inside `.writrun/`,
   which the mirror carries whole, because a script shipped to an adopter
   without its data file is a check that passes by knowing nothing.
   Seeded with `pending ready` and `level stage`, both retired by
   [spec-0018](spec-0018-stage-naming.md) in one change. The file is the
   single source; retiring a word without adding its line is what the
   next round of this defect looks like, and `commits.md`'s two-lists
   rule is the precedent for saying so.

   Not seeded: `completed`, which spec-0018 retired as a *status value*
   and which is still a field name in every task file. A vocabulary of
   bare words cannot tell the two apart, so this file holds only words
   retired in every position they can appear.

9. **The word is refused in an instruction, never in a record.** Any
   **backticked** occurrence fails — `` `pending` ``, not the English
   word "pending". The scan set is already the whole answer to where:
   `docs/technical/decisions/` is outside it because history has to be
   able to name what it retired, `work/` is outside it because the queue
   records the migration that retired it, and `template/work/README.md`'s
   plain English "what is pending" is untouched because it carries no
   backticks.

10. **The id rule: four digits, or it is not an id.** The same scan fails
    a **backticked** `task-` or `spec-` id carrying fewer than four
    digits — `` `task-001.md` ``, `` `spec-004` ``, and one inside a
    backticked list, `` `[spec-001, spec-002]` ``. It needs no vocabulary
    file, because the shape *is* the rule: the schema states four digits
    and a subject slug, the generator has written that since it said so,
    and every id in the queue is four wide. A three-digit one in an
    instruction is an example that predates the rule it claims to teach.
    This is the exact residue of the defect the task reports — the two
    kit queue chapters, and the delta skill's `spec-004` where it is
    backticked in prose — which the other two rules cannot see.

11. **Fix the eight files.** `concepts/task.md` and `concepts/spec.md`
    gain the fields and the timestamps their schemas state.
    `template/AGENTS.md` loses `pending` for `ready` and stops inviting
    the agent to write `implemented`/`completed` onto a status line the
    machinery owns from Stage 2. `template/work/tasks/README.md` and
    `template/work/specs/README.md` name four digits and a subject slug.
    `writrun-check-spec-deltas/SKILL.md` says `spec-0004` in all four
    places. `writrun-create-task-and-spec/SKILL.md` shows the front
    matter `new.sh` actually writes — `queued: null`, `merged: null`, and
    a real UTC timestamp on `created` in place of `<today, ISO date>`.
    `check_front_matter.sh`'s head comment is corrected in all three
    places: the list reads `[spec-0001, spec-0002]`, the date line says
    `YYYY-MM-DDTHH:MM:SSZ` as `check_date` has always demanded, and
    `check_list`'s error message stops printing a three-digit id.
    `technical/README.md`'s `provenance:` block gains its ` fragment `
    fence. `make template-sync` carries the three corrected `.writrun`
    files and the vocabulary file into `template/`.

12. **Wired where the others are.** A job in `writrun-check.yml` beside
    the existing checks, at the same stage gate, and a case directory in
    the suite.

## Acceptance criteria (EARS)

- When a fenced `yaml` block in a checked document opens with `---`, the
  system shall validate it with `check_front_matter.sh` and report any
  fault with the document's path and the fence's line.
- When such a block carries trailing comments, the system shall validate
  it with them removed, and shall not read a `#` that no whitespace
  precedes as the start of one.
- When such a block names a `doc_ref` that exists nowhere, the system
  shall accept it, because the scratch tree materialises the path the
  example names.
- When two checked blocks carry the same `id`, the system shall check
  both, because each is written to a scratch tree of its own.
- When a fenced `yaml` block is declared a fragment, the system shall
  check every outermost key against the list `check_front_matter.sh
  --fields` prints and say in its output that the block was read as a
  fragment.
- When a fragment carries a key that list does not hold, the system shall
  fail, naming the key and the document.
- When a fenced `yaml` block neither opens with `---` nor is declared a
  fragment, the system shall fail, naming the document and the two ways
  to declare the block.
- When a word in `retired_vocabulary.txt` appears backticked in a checked
  document, the system shall fail, naming the replacement.
- When a backticked `task-` or `spec-` id in a checked document carries
  fewer than four digits, the system shall fail, naming the document.
- When either appears under `docs/technical/decisions/`, or in a file
  that is not `.md`, the system shall pass.
- When a retired word appears unbackticked in ordinary prose, the system
  shall pass.
- When `writrun check` runs from Stage 2, it shall run this check.

## Edge cases

- **A `yaml` block that is neither** — a settings snippet, say, opening
  with `{`. It fails until someone declares it: ` ```yaml fragment ` if
  its keys are schema fields, ` ```text ` if it is not front matter at
  all. There is deliberately no heuristic, because the only one available
  — read the block when its first key happens to be a schema field —
  skips exactly the fragment whose first key is the undocumented one,
  which is the case worth catching, and forces a settings snippet opening
  `status:` or `milestone:` through a rule that was never about it.
- **The fence's second word.** A markdown info string is the language
  followed by whatever the author wants, and renderers highlight on the
  first word, so ` ```yaml fragment ` colours as YAML wherever ` ```yaml `
  does. A renderer that read the whole string would lose the colour,
  never the meaning.
- **Two examples in one document, or two documents printing one id.**
  Each block gets its own scratch tree, so neither can overwrite the
  other, and the message names the source document rather than the
  scratch path it was validated under.
- **An example that is deliberately wrong** — a chapter showing what the
  checker refuses. None survives Step 11: when this lands, every `yaml`
  block in the scan is canonical or a declared fragment. That is a claim
  the corrections *make* true, not one the drafting found true: not one
  of the seven `yaml` blocks in the repository passes as it stands — two
  are stale files, two are annotated schemas, two are generator
  placeholders, and one is a fragment. If a deliberately wrong one is
  written later it is fenced
  ` ```text `, and that is the documented escape: the fence is the
  declaration of intent.
- **A retired word inside a fenced block.** Held like any other text — a
  code example teaching `status: pending` is exactly the failure this
  catches, and it is caught by the shape rule anyway.
- **A word retired and later revived.** Its line is deleted from the
  vocabulary file. Nothing else moves; the file is the single source.
- **A short id or a retired word in a script's prose.** `new.sh` explains
  what it does when the argument names `task-1` or a historical
  `task-001`; `mirror_issues.sh` keeps `task-004`'s own width rather than
  padding it; `read_setting.sh` names the `level` precedent. All three
  are right, and all three are why the scan reads `.md` and nothing else.
- **`work/` and `docs/technical/decisions/` are outside the scan, and not
  outside the schema.** `check_front_matter.sh` already reads the live
  queue; this check never looks there.

## Tests required

A document whose example is stale fails, naming the file and the fence's
line. A current example passes. An annotated example — every field with a
trailing comment — passes, and the same example with a `#` anchor inside
`doc_ref` passes with it, the two together proving the comment rule reads
YAML's boundary rather than the first `#`. An example whose `doc_ref`
names nothing passes, and the same example with a malformed `created`
fails — the two together are what proves the scratch tree materialises
the path rather than disabling the check. Two documents printing the same
`id` are both checked, and so are two examples in one document. A
declared fragment with only schema keys passes and is reported as a
fragment; one with an undocumented key fails; an undeclared block that is
not front matter fails, and the same block fenced ` ```text ` passes. A
backticked retired word fails under `template/` and passes under
`docs/technical/decisions/`; the same word unbackticked passes. A
backticked three-digit id fails, and the same id in a `.sh` file under
the scanned directories passes. A case reading the vocabulary file for
its seeded lines, so a deletion is deliberate, and a case reading
`check_front_matter.sh --fields` for the field the fragment rule depends
on.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] Seven of the eight files fail the new check as they stand today
      and pass after Step 11 — the two concept chapters and
      `writrun-create-task-and-spec/SKILL.md` on the shape rule,
      `template/AGENTS.md` on the word rule, the two kit queue chapters
      and `writrun-check-spec-deltas/SKILL.md` on the id rule.
- [ ] The eighth, `check_front_matter.sh`'s head comment, is corrected by
      hand in all three places and is **not** claimed to be guarded: it
      is a script, and the scan reads `.md`.
- [ ] `check_doc_shapes.sh` and `retired_vocabulary.txt` both arrive in
      `template/`, and the mirror test holds them.
- [ ] `writrun check` runs it from Stage 2; template synced; suite green.

## Proposed product changes

- `product/concepts/task.md#example` — the example is corrected to the
  schema it already claims: `origin`, `queued` and `merged` present, and
  `created` an RFC 3339 timestamp.
- `product/concepts/spec.md#example` — the same correction to `created`.

Neither changes a rule; both are a shape catching up with its own
statement. They are promised anyway because `check_deltas.sh` reads
paths and not intent — a permanent doc touched and unlisted fails the
completing pull request with UNDECLARED, whether or not the edit moved a
rule. One task in flight overlaps the second file: `task-0028` carries
`doc_ref: product/concepts/spec.md#the-doc-delta-contract`, a different
section of the same chapter, and nothing this spec proposes touches it.

## Proposed technical changes

- `technical/README.md#task-schema` — the example a reader copies is the
  one a check reads, and the `provenance:` block is declared a fragment
  at its fence.
- `technical/README.md#front-matter-is-canonical` — the canonical form is
  held wherever it is *shown*, not only where it is stored, and the fence
  says which of the three kinds a block is.
- `technical/README.md#distribution` — the kit's prose is held to the
  current vocabulary and the current id width; the mirror holds bytes,
  this holds words, and a script's data file ships beside the script.
- `technical/decisions/tasks-and-specs/0062-a-shown-shape-is-a-checked-shape.md`
  — the dated why: an example is documentation that lies with a straight
  face, and the checker that reads files can read blocks.

## Outcome

_(fill after execution)_
