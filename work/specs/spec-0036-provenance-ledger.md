---
id: spec-0036
task_ref: task-0026
status: draft
created: 2026-08-31T14:24:46Z
---

# spec-0036 — The provenance ledger and the key that gates it

**References:** [task-0026](../tasks/task-0026-provenance-ledger.md)

- **Goal:** a task carries an append-only ledger of who did its work and
  what it cost — `provenance` in the front matter, one entry to the line —
  gated by `provenance_ledger` in `stage_1`, filled from the agent
  platform's own usage data by a helper that reads but never stores, and
  summed by a rollup that answers cost per task and per milestone.

## Scope

In: the `provenance` field end to end (schema position, generator,
front-matter check, the write itself); the `provenance_ledger` key with its
default, value check and present-always membership; the transcript-reading
helper; the rollup; the template mirror.

Out: `agent_coauthor` and the commit trailer (spec-0035). Out: any use of
the ledger as an input — no gate, no priority, no review reads it. Out: a
fraction-of-lines metric, which the chapter refuses outright.

## Steps

1. Schema + generator + `check_front_matter.sh`, with the existing queue
   files migrated in this change (a `provenance: []` line added — front
   matter is contract, not assented prose, the same migration spec-0019
   made for `taken_by`).
2. The key: `.writrun/settings.json`, `check_settings.sh`,
   `read_setting.sh` with documented default `false`.
3. The writer: settle question 1 below, then implement it.
4. The helper that reads the platform's usage data and proposes an entry.
5. The rollup.
6. `make template-sync`.

### The three questions this spec must settle before step 3

1. **The writer class does not exist.** Every machinery-written field comes
   from a forge event, and no forge event carries a token count — only the
   session knows it. `check_state.sh` currently *rejects* branch-side edits
   of `status` and `taken_by` on the one-writer rule, and a ledger entry
   written on the branch would be the first agent-written machine field in
   the schema. The check must learn this one exception without widening
   into "the branch may edit front matter", which is the rule it exists to
   hold. Append-only helps: an added line is a different act from an edited
   one, and the check can be taught to tell them apart.
2. **The rate card is fetched, never recalled.** Entries store counts, so
   conversion happens at report time. Cache reads outrun the other columns
   by roughly two orders of magnitude in this repository's own history, so
   the cache tiers are priced separately or the answer is wrong rather than
   rounded. Take the multipliers from the published pricing page at
   implementation time; do not hardcode a remembered number.
3. **The helper reads, it does not own.** Aggregation joins the session's
   git branch to `task/NNNN`, which the branch convention already supplies.
   It must degrade to silence where no transcripts exist, must never be
   the only place a number lives, and must not be wired into any check.

## Acceptance criteria (EARS)

- When the generator creates a task, it shall write `provenance: []`.
- When `provenance_ledger` is `false` or absent, a task whose `provenance`
  is `[]` shall satisfy every check.
- When an entry is added, it shall be one YAML flow mapping on one line,
  and `check_front_matter.sh` shall reject an entry spread over several
  lines as a block mapping — the dash-opened list of one-line entries is
  the canonical shape, not the fault.
- When an entry's `by` is `agent`, it shall carry a specific model id;
  when it is `human`, it shall carry neither model nor counts, and no check
  shall fault that absence.
- When a task already carrying entries gains another, the existing entries
  shall be unchanged in the same diff.
- When a branch's diff edits an existing `provenance` entry rather than
  appending one, `writrun-check-task-state` shall exit non-zero.
- When the rollup is run over a milestone, it shall report that
  milestone's summed counts and the count of tasks with and without agent
  participation.
- When the helper finds no transcripts, it shall exit zero having proposed
  nothing.

## Edge cases

- **A task worked entirely by hand** carries one human entry, or none if
  the project declares no ledger. Neither is a fault; this is the case
  that proves the ledger did not quietly make agent use mandatory.
- **A task resumed months later**, after `taken_by` was cleared: a new
  entry, never an edit to the old one — which is precisely what `taken_by`
  cannot do and why this field exists.
- **Several models in one task**: normal, not exceptional — this
  repository's own task-0021 ran on two.
- **A task that never completes** (`dropped`): entries stay. Work was done
  and it cost something; the ledger is a record of spend, not of success.
- **Stage 1**: the field and the key work unchanged — no forge is needed
  for either.
- **A partial merge** that returns the task to `ready`: the entries stay,
  because the work happened. This is the exact clear that makes `taken_by`
  unable to answer the question.

## Tests required

Generator emits `[]`; front-matter check accepts canonical entries and
rejects a multi-line block-mapping entry and a misplaced field; `check_settings.sh`
and `read_setting.sh` for the key; `check_state.sh` rejects an edit and
allows an append; the rollup over a fixture queue, including a
human-only task and a two-model task; the helper against a fixture
transcript and against an empty directory.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] Every queue file migrated; `check_front_matter.sh` green.
- [ ] The three questions above are answered in this spec's Outcome, not
      left to the reader of the diff.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the rule was authored first
  (`product/concepts/provenance.md`); this change builds what the chapter
  already states.

## Proposed technical changes

- none — the field, its shape and the key were authored first
  (`technical/README.md#task-schema`, `#settings`).

## Outcome

_(fill after execution)_
