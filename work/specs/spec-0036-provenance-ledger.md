---
id: spec-0036
task_ref: task-0026
status: implemented
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

Built as scoped: the field end to end, the key, the writer, the helper and
the rollup, with every queue file migrated and the kit synced.

**The three questions, answered.**

1. **The writer class exists, and it is shaped rather than fenced.** A
   branch may *append* a `provenance` entry and may never edit one it
   found — rule I in `check_state.sh`, ungated by stage, because the field
   exists wherever tasks do. The permission cannot widen into "a branch
   may edit front matter" because it is not a permission over the field at
   all: the check reads the base's entries and requires them to still be
   there, in order, byte for byte, with the branch's own entries after
   them. An edit in place, a removal and a reorder each fail it, and a
   reorder is the one that says why order rather than membership is what
   is compared — every entry still present, and the chronology gone.
2. **Nothing converts, anywhere.** The stronger answer than "fetch the
   rate card at report time" turned out to be that the rollup has no
   business holding one: it prints the four counts unfolded, per task and
   summed, and says in its own output that conversion happens against the
   published card on the day the question is asked. That preserves exactly
   what the question was protecting — cache reads outrun the other columns
   by around two orders of magnitude in this repository's own history, and
   a total that folded them together would misreport spend rather than
   round it — without putting a number in the repository that goes stale.
   Recorded as a divergence below, because the spec asked for pricing and
   got a refusal to price.
3. **The helper reads and owns nothing.** `read_usage.sh` joins the
   session's git branch to `task/NNNN` the branch convention already
   supplies, degrades to silence on a missing directory, an empty one and
   an empty file, is wired into no check, and prints proposals in exactly
   `record_provenance.sh`'s argument form so composing them is a pipe. It
   writes nothing and stores nothing; `$WRITRUN_TRANSCRIPTS` is the only
   way it is pointed anywhere, which is also how the tests reach a
   fixture.

**Divergences.**

- **The rollup does not price.** Question 2 above. The spec's own reason
  for pricing the cache tiers separately is the reason the columns stay
  separate; the multiplication is left to the asker.
- **A category is refused as a model.** Not in the spec's criteria, but
  the schema chapter states it ("the specific model id, never a
  category"), and a rule the machinery states and nothing holds is the
  defect task-0024 exists about. Same tripwire posture as
  `check_observance.sh`'s trailer check: a name written to evade it evades
  it.
- **This repository declares `true`, the adoption kit ships `false`.** The
  documented default is `false` and the kit keeps it, the same way it
  ships every conduct flag cautious. This repository keeps a ledger
  because it is the project whose own history the field was derived from.
- **The block-list allowance is named by the caller, not global.**
  `check_shape` takes the ledger field as an argument, so a task gets the
  exception and a spec does not — a spec reaching for a block list is
  refused exactly as it was before.
- **One awk detail is load-bearing enough to be a test.** The platform's
  usage object repeats every count inside an `iterations` array, so the
  helper reads the *first* occurrence of each key; the fixture transcript
  carries that array for the sole purpose of failing if that ever
  regresses. (The first draft also passed the count patterns as awk
  `/regex/` literals, which in an argument position evaluate to `$0 ~
  /re/` — every column came back equal to the number of matching lines.
  The fixture's real-shaped numbers are what caught it.)

**What was not built, deliberately.** No gate, no priority input, no
review signal, no fraction-of-lines metric, and no check that reads the
ledger's contents — the chapter refuses all of them, and the field is a
record or it is the tracker this methodology is not.
