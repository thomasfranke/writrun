---
id: spec-0052
task_ref: task-0036
status: implemented
created: 2026-09-02T19:31:44Z
---

# spec-0052 — The entry point is read once and paid for always

**References:** [task-0036](../tasks/task-0036-entry-point-cost.md)

- **Goal:** `AGENTS.md` states what a session needs *before it knows
  what it is doing* and links the rest, so per-phase detail is billed to
  the phase that needs it — the move `session_card.sh` already made for
  settings, applied to the entry point.

## Scope

Today's distribution, measured:

| Section | Bytes | Needed by |
|---|---|---|
| header + reading order | 1656 | every session |
| Which kind of change you have | 3663 | every session — the table; the exemption prose only when recording |
| Human gates | 2647 | a session standing at one gate |
| Picking work | 2194 | a session picking, not one handed a task |
| Completing a task | 1284 | a session completing |
| Creating tasks and specs | 579 | a session creating |
| Never | 382 | every session |

Three sections are 69% of the file and none is unconditional.

In: `AGENTS.md`; the three chapters that absorb what leaves it. Target
≤ 5 KB, on spec-0046's precedent of naming a number rather than
"shorter".

Out: the five `SKILL.md` files — spec-0046 already holds them, and this
change must not reopen that audit. Out: `template/AGENTS.md`, which is
the adopter's starting point and states no gate table of its own. Out:
any behaviour change; nothing here touches a script.

## What stays, and why

The entry point keeps only what a session cannot look up because it does
not yet know what it is doing:

- The reading order, steps 0–4, and the `session_card.sh` command.
- **The kind table** — three columns, no prose. A session must know
  which kind it has before it can choose anything else.
- **The gate table, rows intact.** It is this repository's own answer,
  not the methodology's, so it never moves into `docs/product/`. What
  leaves is the justification inside each cell.
- The `Never` list. Short, absolute, and cheap.
- The pointer to each skill.

## What moves, and where

1. The report-exemption paragraphs → nowhere: `product/concepts/report.md`
   already carries them, and the entry point links there twice while
   restating them. Delete and keep the link.
2. The "active owner means this session" rule, and the `backlog`-is-not-
   authorized-work paragraph → `technical/selection.md`.
3. The by-hand taking sequence and the `auto_push`/`auto_pr` narration →
   `technical/distribution.md`, beside `take_task.sh`'s contract.
4. The per-gate reasoning inside the gate table → the gate's own chapter
   in `product/stage-1-tasks-and-specs/gates.md`, leaving each cell
   naming the who and linking the why.
5. The completion steps → `writrun-create-task-and-spec`'s completion
   checklist, which already states them; the entry point keeps the
   ordered list's shape and the `preflight.sh` command.

## Steps

1. Audit each sentence against the two questions: does a session need it
   before knowing its task, and does a permanent doc already own it.
2. Move what item 2–4 above names, in the same diff — a sentence deleted
   here and not landed there is a rule lost, not a rule relocated.
3. Rewrite what stays against `conventions/prose.md`.
4. Re-measure; state the number in the Outcome.

## Acceptance criteria (EARS)

- When a session reads `AGENTS.md`, it shall find the reading order, the
  kind table, the gate table, the `Never` list and a pointer per skill.
- When `AGENTS.md` states a rule a permanent doc owns, it shall link to
  that doc instead of restating it.
- When a sentence leaves `AGENTS.md` and is not already stated
  elsewhere, the same diff shall land it in the chapter that owns it.
- When the change is complete, `AGENTS.md` shall be at most 5 KB.

## Edge cases

- **A rule that exists only in `AGENTS.md`.** It has no owner to link
  to, so it stays until a chapter earns it. Moving it into a chapter it
  does not belong in trades one cost for a worse one.
- **The gate table's rows.** Project data, not methodology — they stay
  whatever the size argument says.
- **A link that replaces prose is not free.** A session following three
  links to answer one question has paid more than the paragraph cost.
  Where that is the case, the paragraph stays and the Outcome says so.

## Tests required

No script changes, so no unit tests. The check suite must stay green:
`doc_ref` resolution over the moved anchors is the one that can break,
since queue files point into the sections this change edits.

## Definition of Done

- [ ] Every acceptance criterion holds.
- [ ] Every moved sentence landed in the same diff.
- [ ] No non-completed task's `doc_ref` resolves to a deleted anchor.
- [ ] `AGENTS.md` ≤ 5 KB, the measured number in the Outcome.
- [ ] Suite green.

## Proposed product changes

- `product/stage-1-tasks-and-specs/gates.md` — absorb the per-gate
  reasoning the entry point's table carries today, so each cell names
  the who and links the why.

## Proposed technical changes

- `technical/selection.md` — absorb the repository's own resume rule
  ("active owner" is this session) and why a `backlog` task is not
  authorized work.
- `technical/distribution.md` — absorb the by-hand form of the taking
  act and what the two conduct flags change about it.

## Outcome

**`AGENTS.md` is 5000 bytes, from 12419** — 60% off, against a target of
5 KB. Every session pays that before every task, and none of what left is
gone: each moved sentence landed in the same diff.

What stays is what the "What stays, and why" section named: the reading
order with the card command, the kind table, the gate table with its rows
intact, the `Never` list, and a pointer per skill — the pointers now a
table of When → Skill, since a session that does not know which moment it
is at cannot follow a prose list of five.

Where each moved rule landed:

- The report-exemption paragraphs → deleted, the link kept.
  `concepts/report.md` already carried them.
- "Active owner" is this session, and `backlog` is not authorized work →
  `technical/selection.md`, in a section of its own, generalised past
  this repository: a project with several contributors reads the same
  question with a different population.
- The by-hand taking sequence and the two conduct flags →
  `technical/distribution.md`, under `take_task.sh`'s contract.
- The per-gate reasoning → `product/stage-1-tasks-and-specs/gates.md`,
  as the three answers that recur — the maintainer-authored repository
  with no review to give, settings that live outside any diff, and
  derivation reviewed before it reaches the forge.
- The completion steps → kept in the ordered list's shape, with the
  `preflight.sh` command; the reasoning per step was already in
  `writrun-create-task-and-spec`.

**Two divergences, both smaller than the spec's Out list forbids.**

The `doc_ref`-overlap paragraph and the derivation-review paragraph were
not in "What moves, and where" and had to go somewhere. The first is
already owned by `stage-1-tasks-and-specs/conflicts.md`, so it became a
`Never` bullet linking there. The second is a gate this repository
operates, so it became a gate-table row — a relocation inside the file,
not a new rule.

The two settings paragraphs (`settings.json` holds the values, the `.md`
files explain them) collapsed into step 0, which is the same rule stated
where the card is run. `technical/settings.md` already owns the long
form.

**The edge case about links costing more than prose did not fire.** Every
paragraph removed had a chapter that already stated it, so no session
follows a link to recover a rule it used to read in place — it follows a
link to recover the *reasoning*, which is what the arithmetic was about.

Suite green; `check_front_matter.sh` reads 99 queue files canonical, so
no non-completed task's `doc_ref` resolves to a deleted anchor.
