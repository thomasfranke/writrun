# Task

**The front matter and body shape of a task file**, and the rules each field carries. One chapter of [`schemas/`](README.md); the technical router is [`../README.md`](../README.md).

## Task schema

```yaml
---
id: task-0005                      # immutable identity, never an ordering
status: backlog                    # backlog | ready | in-progress | in-review | done — machinery-written; blocked | dropped — hand-written
blocked_reason: null               # required non-null when status: blocked; null otherwise
taken_by: null                     # machinery only: login of the open PR's author; null when nobody has it
spec_ref: [spec-0004]              # list — zero, one, or many specs
doc_ref: product/concepts/task.md#two-invariants   # any path under docs/; null only when the task originates in code or machinery, not in a doc
origin: report                     # rule | report — derived from an authored rule, or born from a report of work found
priority: medium                   # high | medium | low
depends_on: [task-0002]            # real technical blocking, not sequencing taste
milestone: v0.1-core
created: 2026-08-21T09:14:00Z      # by hand: when the task was drafted
queued: 2026-08-21T11:02:37Z       # machinery only: the merge that put it in the queue
completed: null                    # by hand: when the work was finished
merged: null                       # machinery only: the merge that took the work
provenance: []                     # append-only ledger, one entry per line; always [] unless the project declares one
---
```

**Both blocks above are read by a check, and they are read differently.**
The schema block is a whole front matter — it opens with `---` — so
`check_doc_shapes.sh` runs `check_front_matter.sh` over it, the same
script that reads the queue's own files; the annotation after each value
is stripped first, because an annotation is not part of the shape being
taught. The block below is a **fragment**: entries with no file around
them, so there is nothing to hold to the whole contract, and its keys are
checked against the schema's fields and the block is *named* as a
fragment in the output. A fragment silently skipped and a fragment
checked look identical from outside, which is why one of them says so.

A task that keeps a ledger carries entries instead of the empty list, one
flow mapping to the line:

```yaml
provenance:
  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 37266324, cache_write: 366590}
  - {by: human, login: octocat}
```

- `id` is identity, never order. A task file is named
  `task-NNNN-<subject>.md` — the id plus an extremely short subject slug
  (`task-0005-multi-file-search.md`), so a directory listing reads as a
  queue summary. The slug is fixed at creation: reprioritising or
  retitling never renames a file, and identity lives in the id alone.
  **Whoever creates the file chooses those words**, because "which task
  is this, among these" is a judgement about the queue rather than a
  string operation on the title; a generator derives them only when
  nobody chose.
- **An id is unique across the queue *and* across every open pull
  request.** Minting the next one from the branch you are on is not
  enough: two branches that start from the same `main` both see the same
  highest id and both claim the next, and neither can tell until one
  merges. So the queue is the union of what the authority branch holds
  and what open pull requests propose — anything else is a claim on a
  number somebody else may already have taken.

  A number claimed by a branch that has not merged is **not yet an id**,
  and renumbering it costs nothing: identity begins at the merge that
  puts the file on the authority branch. "An id is never renumbered"
  binds from there, not from the moment a generator printed one.
- `spec_ref` is a list because the relationship is 0..N: a task can ship
  without a spec (trivial-but-tracked work) or span several (sequential phases,
  or parallel concerns of the same task). An empty list is valid and explicit
  — never omit the field to mean the same thing.
- The task precedes its specs. A spec is created for an existing task, never
  the other way around — an orphan spec is a structural error.
- `doc_ref` and any path inside `spec_ref`/`depends_on` point at a section
  anchor, resolved relative to `docs/`, never just a filename — this is what
  makes reverse traceability a grep, not a manual search.
- `provenance` is the ledger [Provenance](../../product/concepts/provenance.md)
  describes, and it exists only where `provenance_ledger` is `true` —
  everywhere else it stays `[]`, which is a complete statement and not a
  gap. **One entry per line, as a YAML flow mapping**, for the same reason
  the rest of this schema is line-shaped: the readers are line-based, and
  an entry opened as a block mapping — its keys on lines of their own —
  would be invisible to them. `by` is `agent` or `human`
  and nothing else; `model` appears on an agent's entry and is the specific
  model id, never a category; `login` is whoever answers for the entry,
  which on an agent's entry is the person who ran it. The four counts are
  the platform's own, kept **as counts and never as money** — cache reads
  outweigh the other three by around two orders of magnitude in practice, so
  a ledger that dropped the cache columns would misreport spend rather than
  round it, and a stored currency figure would quietly become false the next
  time a price changed. A human's entry carries no model and no counts.
  **The list is append-only**: work resumed after the task returned to the
  queue adds an entry, and an entry already written is never edited — the
  same grain as `origin`.
- `origin` records how the task came to exist, and it is a fact, not a
  judgement: `rule` when the task was derived from an authored rule
  declared finished (flow 1), `report` when it was born from a report
  of work an existing rule already authorizes (reporting). The
  generator writes it at creation and nothing rewrites it later. At
  Stage 2+ it mirrors the creating PR's branch kind (`docs/` vs
  `report/`); at Stage 1 it is the only record of the difference.
- **References are navigable, not just resolvable.** The front matter
  stays plain strings — it is the machine contract, and the line-based
  readers see nothing else — but the generated body carries every
  reference as a clickable relative link: a task's body links its
  `doc_ref` and each spec in `spec_ref`, a spec's body links its
  `task_ref`, and the append that adds a spec to a task's `spec_ref`
  appends the body link in the same edit. A reader follows the queue by
  clicking, never by reconstructing paths.
- Status lives in front-matter, never in folder position — nothing moves
  between directories as work progresses, so `git log` stays readable without
  `--follow`.
- **Four dates, and who writes each is part of the contract** — the table
  is in [`product/stage-1-tasks-and-specs/statuses.md`](../../product/stage-1-tasks-and-specs/statuses.md).
  `created` and `completed` are a person's, written by hand;
  `queued` and `merged` are the machinery's, written after the merge each
  records — at Stage 1, where no forge exists to record, they stay
  `null`. A date recording a merge is never hand-written: it would have
  to be typed before the event it describes.
- **Every date is a UTC timestamp, and always spelled with `Z`** —
  `2026-08-21T09:14:00Z`, never a local time and never an offset like
  `+02:00`. Two reasons, and both are about the line-based readers this
  schema exists for. A bare date cannot order two entries made the same
  day, which is most of them in an active queue. And with `Z` as the only
  spelling, sorting these strings lexicographically *is* sorting them
  chronologically — an offset form would break that silently, giving a
  `sort` that looks right and is wrong for exactly the entries that
  crossed a timezone.

### `blocked` vs. `depends_on`

Two different kinds of "can't start", kept structurally apart:

- **`depends_on`** — blocked *by another task in this queue*. Resolves itself:
  the selection algorithm skips the task until every dependency is
  `done`. Machine-checkable, no human judgement needed.
- **`status: blocked`** — blocked *by something outside the queue*: an
  unanswered decision, an upstream release, a spike whose result could
  invalidate the plan. Requires a non-null `blocked_reason` stating what
  unblocks it. Only a human (or an agent explicitly told the blocker is gone)
  moves it back — to `ready` when its every spec is `approved`, to
  `backlog` otherwise.

A task never uses `blocked` for something `depends_on` can express — if the
blocker is a task, it's a dependency.

