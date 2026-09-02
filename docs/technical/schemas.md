# File schemas

**The front matter and body shape of every file the machinery reads** —
task, spec, report — and the canonical form all three are held to. One
chapter of [`README.md`](README.md), the technical router; read it before
touching anything under `work/`.

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
- `provenance` is the ledger [Provenance](../product/concepts/provenance.md)
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
  is in [`product/stage-1-tasks-and-specs/statuses.md`](../product/stage-1-tasks-and-specs/statuses.md).
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

## Spec schema

```yaml
---
id: spec-0004
task_ref: task-0005                # a spec belongs to exactly one task
status: draft                      # draft | approved | implemented
created: 2026-08-20T16:02:00Z
---
```

A spec file is named `spec-NNNN-<subject>.md`, the same shape as a
task's — four-digit id plus an extremely short subject slug, fixed at
creation.

The `draft → approved` transition is a gate, and **who operates it is an
adopter decision, declared in `AGENTS.md`** — this methodology's own
`AGENTS.md` requires a human. An agent never self-approves a spec unless the
adopting project has explicitly written that policy down. `approved →
implemented` is mechanical: it happens when the task completes and the
Outcome section is filled.

A spec's body carries what a task's front-matter must not: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done, and two
sections that close the loop between ephemeral and permanent docs:

```markdown
## Proposed product changes
- `product/coverage/ignore-patterns.md#pattern-with-no-match` — new rule: a
  pattern matching nothing warns and exits 0.
(or: "none — no behaviour change")

## Proposed technical changes
- `technical/engine/adapter.md` — document the new extension point.
- `technical/engine/decisions.md` — new dated entry: why warning over error.
(or: "none — no machinery change")

## Outcome
(filled when the task completes: what was actually built, anything that
diverged from the plan above, and why)
```

The **Proposed changes** sections are what a completed task is checked
against before merge — every listed path+anchor should appear touched in the
diff, and the diff shouldn't quietly touch a permanent doc that wasn't listed.
This turns "update the docs in the same PR" from a prose reminder into
something a script or a reviewing agent can verify mechanically.

## Report schema

```yaml
---
id: report-0001
status: open                       # open | tracked | authored | fixed | declined
task_ref: []                       # the tasks triage produced; a list, always
doc_ref: null                      # the doc violated, or the doc the rule was written into
created: 2026-09-01T20:23:51Z
triaged: null                      # when triage decided; null while open
---
```

The shape above is
[`report-0001`](../../work/reports/report-0001-conventions-scope.md), the
first one recorded here — the block is read against the same checker the
real files pass through, so a schema this chapter shows and a schema the
machinery accepts cannot part company.

A report file is named `report-NNNN-<subject>.md`, the same shape as a
task's and a spec's. Its id is minted by the same generator over the
same three views — the directory, the git history, and every open pull
request — and is never reused.

`status` is the **route triage took**, not a lifecycle. `open` is the
only non-terminal value; the four others are the ways a report ends, and
they are the triage table's outcomes
([report](../product/concepts/report.md#statuses--the-route-not-a-lifecycle)).
There is no `resolved`: whether the underlying work is done is the
task's status, reachable through `task_ref`, and a second copy of that
fact would need a second writer to stay true.

`task_ref` is a list even with one element, like `spec_ref` — and it is
the **only** link between the two kinds. The task schema is unchanged:
nothing on a task points back at the report that produced it, and
finding that is a scan of `work/reports/`, which costs a grep and
touches no contract.

`doc_ref` is a path relative to `docs/` with an anchor, exactly as a
task's is. One fact under both routes — **the doc this observation is
answered by** — which reads as the violated rule for `tracked`, and as
the rule that had to be written for `authored`. Those are the same
sentence read before and after the rule existed, not two fields sharing
a name. It stays `null` when nothing documents the thing observed, which
is the common case for `fixed`: a typo violates no rule, and a report
that ends `fixed` usually names no doc at all. `declined` may name the
doc that says the behaviour was never a defect, and is otherwise `null`.

At Stage 3 a report is mirrored like a task — `writrun:report`, titled
`[REPORT-NNNN]`, `status:open` until triage closes it
([labels](../product/stage-3-github-issues/labels.md#the-report-mirror)).
A pull request title never carries a `[REPORT-NNNN]` tag: that bracket
is how the machinery reads which tasks a pull request carries.

**The status line's writer is a human or an agent, at every stage.**
This is the one place `work/` departs from the task queue, whose status
line from Stage 2 has exactly one writer and it is the machinery — no
forge event corresponds to a judgement
([0064](decisions/tasks-and-specs/0064-a-report-is-an-artefact.md)).

## Front matter is canonical

The front matter above is a fixed shape, not general YAML. Every reader
in the machinery is line-based on purpose — plain `bash`/`awk`/`sed`, no
YAML parser, no runtime dependency — and YAML permits the same meaning
in forms a line-based reader cannot see: a block list under `spec_ref:`
reads as an empty list, a quoted value never matches a path comparison,
a folded scalar reads as nothing. Silently, in every case.

So the canonical form is a checked contract, not an assumption: one
field per line as `key: value`, values bare (no quotes, no `>`/`|`
block scalars), every schema field present exactly once even when
`null`, lists inline (`[]` or `[spec-0001, spec-0002]`), `id` agreeing
with the filename — exactly for a spec, as the `task-NNNN` prefix of
`task-NNNN-<subject>.md` for a task — statuses and priority drawn only from their
documented vocabularies, `blocked`/`blocked_reason` paired both ways,
every date an RFC 3339 UTC timestamp
(`2026-08-21T09:14:00Z`), and `doc_ref` written relative to `docs/`.
Unknown keys in canonical shape are allowed — an adopter may extend the
schema, not reshape it. Extensions enter through the project template's
own front-matter block: `new.sh` appends those fields to the generated
contract block, refuses a template that redefines a contract field or
writes a non-canonical line, and the agent fills their values the same
way it fills the body — the template's placeholder text is the
project's instruction for what belongs in each
(`writrun-create-task-and-spec`'s SKILL.md says so explicitly).

**Body shapes resolve in layers, and the project's wins.** The generated
body comes from the project's own `.writrun/conventions/templates/task.md`
(or `spec.md`) where it defined one; otherwise from the shipped default in
`.writrun/templates/`; otherwise from the generator's built-in skeleton.
A file written by hand honours the same order. The *contract* front matter
is never templated — the generator writes it, and refuses a template that
redefines a contract field — and a spec template must keep the two
Proposed-changes headings and Outcome or it is refused too.

`.writrun/skills/writrun-check-front-matter/check_front_matter.sh` enforces all of it —
`writrun check` runs it before the lifecycle rules, so a file the
line-based readers would misread never merges — and `new.sh` only ever
generates this form, so the contract costs nothing on the happy path.

**The shape is held wherever it is shown, not only where it is stored.**
A schema enforced at the machinery's door leaves every example a chapter
prints unheld, and an example is documentation that lies with a straight
face: a reader copies it and the first check refuses what it taught. This
repository's own concept chapters printed a task with no `origin` and a
bare `created` date, and the adoption kit shipped that for weeks with
nothing noticing. `check_doc_shapes.sh` reads every fenced `yaml` block
under `docs/`, `template/`, `.writrun/` and the root's three documents,
and hands the whole ones to the same checker. **The language tag is the
declaration of intent**: a block that is deliberately not canonical — a
shape that is history, or one shown to say what the checker refuses — is
fenced as ```text, which is the only escape and is always visible in a
diff.

Its second half holds the *words*.
`.writrun/scripts/stage-2-pull-requests/retired_vocabulary.txt` carries
one line per word this project stopped having, and the backticked form is
refused wherever the documents instruct — `docs/technical/decisions/` is
exempt, because a record has to be able to name what it retired, and
ordinary English is untouched because it carries no backticks. A
vocabulary the check cannot find is *said*, never assumed empty: a half
that answers "clean" for having read nothing is the same blindness a
block silently skipped is. Retiring a
word without adding its line is how the next one ships; the file is the
single source, and it is the price of the guard. **This paragraph cannot
spell its own example**, and that is the rule working: the token form is
what the check refuses outside a record, so a section that defines the
rule names the word as a word or not at all.

