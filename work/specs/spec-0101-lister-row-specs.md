---
id: spec-0101
task_ref: task-0073
status: implemented
created: 2026-09-17T19:53:21Z
---

# spec-0101 — One token per row, from what the lister already resolved

**References:** [task-0073](../tasks/task-0073-lister-row-specs.md)


- **Goal:** Every task row the lister prints carries the spec token the
  rule defines, from the resolution the lister already made, and no
  section's meaning or exit code moves.

## Scope

- `.writrun/skills/writrun-select-next-task/list_tasks.sh` — the four
  task rows: the resume row, the available row, the in-flight row and
  the held-back row each gain the token before their free text. The
  `Submitted` and `Open reports` rows are not task rows and are
  untouched.
- `.writrun/skills/writrun-select-next-task/SKILL.md` — where it
  describes what a row says, it names the token.
- The lister's tests, wherever a row's shape is asserted.

`.writrun/` is carried whole by `tests/kit_mirrors.txt`; the kit copies
come from `make kit-sync`.

**Out of scope.** No machine-readable mode and no `--format`: the rule
chose one output with one grammar over two outputs free to disagree.
Nothing about ordering, eligibility or the exit code changes; the token
is a column, not a filter.

## Steps

1. Where the lister resolves each task's `spec_ref` and each spec's
   status to decide its section, keep the pairs it read as
   `spec-NNNN:status`, comma-joined in `spec_ref` order; `no-spec` when
   the list is empty.
2. Print that token in each of the four task rows, immediately before
   the title or the held-back reason, with the section's existing
   fields before it unchanged. Widen nothing else.
3. Update the skill's description of the rows, and the lister's header
   comment, to name the token — documentation of the change, not an
   addition to it.
4. `make kit-sync`.
5. Record the decision: the row carries what the lister read, as one
   token, and there is no second output.

## Acceptance criteria (EARS)

- When the lister prints an available task, the row shall read id,
  priority, the spec token, then the title.
- When the lister prints a task in flight, the row shall read id, the
  owner, the spec token, then the title.
- When the lister prints a held-back task, the row shall read id, the
  spec token, then the reason.
- When the lister prints a resumable task, the row shall read id, the
  spec token, then the title.
- When a task references several specs, the token shall join them with
  commas in `spec_ref` order, each as `spec-NNNN:status`.
- When a task's `spec_ref` is empty, the token shall be `no-spec`.
- When the token is added, the sections' membership, their order and
  the exit code shall be unchanged.

## Edge cases

- **A spec the task references and the queue lacks** — the lister
  already has to handle it to place the task; the token names it with
  the status the lister judged it by, so the row does not lie about
  what was read.
- **A held-back reason that already names the spec** stays as it is;
  the token is a column, and a reason that repeats it is not a defect.
- **Column widths.** The token's length varies with the number of
  specs; it is padded to a minimum so single-spec rows still align, and
  a long token pushes the title right rather than truncating.
- **Paused rows** (the amendment note under an in-flight or resumable
  task) carry no token: they are continuation lines, not task rows.

## Tests required

- Lister cases for each of the four rows, with one spec, several, and
  none; the exit code unchanged in each.
- The skill's row description mentions the token — a case reading the
  file, since there is no runtime signal for a stale skill.
- The kit mirror unit test passes with no new exception.

## Definition of Done

- [ ] All four task rows carry the token as the rule states.
- [ ] No section's membership, order or exit code changed.
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — no product chapter changes; the rule is technical and already
  written in `technical/selection/visibility.md#a-row-carries-what-the-lister-read-to-place-it`
  by the change this task derives from.

## Proposed technical changes

- `technical/decisions/tasks-and-specs/0081-the-row-carries-what-the-lister-read.md`
  — the record: why one token in the human row rather than a second
  output, and why `no-spec` is a word.
- `technical/decisions/README.md` — the index gains the record's line.

## Outcome

Built as planned, on all four rows, and the new case found a packer the
plan had not counted.

**A held-back record is built in two places.** A status that is neither
`ready` nor `backlog` — `blocked`, and every other non-terminal one —
takes an early path of its own, and only the later packer had gained the
field. So a `blocked` task printed `blocked: null` where the token
belongs, its reason slid one field left into the column a reader reads
as a spec. That is the exact failure an existing case guards for the
in-flight record; it was found because the new case asserts the token's
*position* on every row rather than its presence somewhere in the
output. Both packers carry it now, and the early one carries a comment
saying it is the second.

**The width is 21 characters**, which is the longest single-spec token
(`spec-NNNN:implemented`). A shorter minimum would leave single-spec
rows ragged against multi-spec ones, and truncating was never on the
table — a token cut in half names a spec that does not exist.

**`spec_token` reads `spec_ref` and `spec_status`, the two the placement
already calls**, so the row and the section cannot disagree: a spec the
queue lacks comes back `missing` here because that is what the placement
judged it by.

The existing row-shape case was updated to the five-field record rather
than weakened — it asserts the author, the token and the title in that
order, and it is what makes a sixth field findable the next time one is
added.
