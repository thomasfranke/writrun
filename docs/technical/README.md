# Technical overview

**How the methodology is structured and distributed.** For whoever builds
tooling on top of it, or adopts it into a new project.

What the methodology *is* is [`about.md`](../about.md); what it *prescribes*
for an adopting project is [`product/`](../product/README.md). This file
covers the mechanics: folder layout, file schemas, the selection algorithm,
and how a project pulls the methodology in. The dated why behind each
piece — and what was rejected — is [`decisions/`](decisions/README.md),
one numbered file per decision, history split out so this reference stays
a short read.

## Folder layout an adopting project ends up with

```
docs/
  about.md            # shared context — what the project is, precedes the fork
  product/            # business rules, chapter by chapter — stakeholder-facing
  technical/          # architecture, testing, subsystems — decisions per subsystem, or one file each
work/
  tasks/              # the queue — front-matter only, no technical detail
  specs/              # the detail of one change — EARS criteria, proposed doc deltas
  reports/            # what was observed — findings, and which way triage sent each
AGENTS.md             # entry point for AI agents, links into the above
.writrun/             # WritRun's home: skills, scripts, shipped templates, conventions
.github/workflows/    # only what the platform dictates lives here
```

One split is structural and mandatory: `docs/` is the permanent half,
written by and for people; `work/` is the machine-managed queue. The
machinery prescribes paths **only under `work/`** and treats everything
under `docs/` as permanent documentation — the input tasks are created
from. **Inside `docs/`, the tree above is this repo's own layout, not a
requirement**: an adopting project shapes `docs/` entirely to its
stakeholders' taste. The audience split (principle 2) remains a rule
about *files* — product intent and technical design never share one —
not about folder names.

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

```text
---
id: report-0003
status: open                       # open | tracked | authored | fixed | declined
task_ref: []                       # the tasks triage produced; a list, always
doc_ref: null                      # the doc violated, or the doc the rule was written into
created: 2026-09-01T14:02:11Z
triaged: null                      # when triage decided; null while open
---
```

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

## Settings

`.writrun/settings.json` holds the choices
[Adoption](../product/adoption.md#three-stages) leaves open — values only, no
prose — read by both the machinery and the agents. It sits at the root of
WritRun's own home because it is the first file a reader or a tool goes
looking for: the one address ends the hunt. The file is the project's from
adoption onward and `writ update` never touches it — the same exemption
`conventions/` carries, stated for this file by name now that it no longer
lives there. A file left at the old address, `.writrun/conventions/settings.json`,
is still honoured flat by the reader under the contract frozen at the
move, and `check_settings.sh` is what names the move — the bridge
outlives the migration it covered, because an adopter may still be
carrying one.

**The choices are sectioned by stage** — the same rule that put the stage
on folder names ([Adoption](../product/adoption.md#three-stages)): one
top-level `stage`, the single global switch, then one object per stage
holding the keys that stage's readers act on, so a reader knows which
choices their stage may ignore without knowing each key. A section exists
only when it holds a documented key — no empty placeholder objects.

```json
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
```

**Keys are alphabetical inside each section.** Mint order is a history the
file cannot show, and a reader checking whether a key is present should
not have to know when it was added. This is the schema's rule and nothing
enforces it: a fault over an adopter's working file would cost more than
the order buys, so the file above is the statement and the eye is the
check.

| Key | Section | Values | Read by |
|---|---|---|---|
| `stage` | top level | `1` / `2` / `3` | the workflows, and agents |
| `decisions_style` | `stage_1` | `per-subsystem` / `chronological` | agents only |
| `product_layout` | `stage_1` | `by-concept` / `by-feature` | agents only |
| `provenance_ledger` | `stage_1` | `true` / `false` | agents only |
| `spec_required` | `stage_1` | `always` / `when-warranted` | agents only |
| `agent_coauthor` | `stage_2` | `true` / `false` | agents only |
| `auto_commit` | `stage_2` | `true` / `false` | agents only |
| `auto_pr` | `stage_2` | `true` / `false` | agents only |
| `auto_push` | `stage_2` | `true` / `false` | agents only |
| `pr_title_style` | `stage_2` | `conventional` / `bracketed` | agents only |

**Every key is present, always** — the same reason the front matter carries
`null` fields rather than omitting them: a reader sees the whole
configuration without knowing the defaults. Each key's documented default
is the behaviour from before the key existed, so a project without the
file, or without the key, behaves exactly as it did: `stage` defaults to
`3`, `pr_title_style` to `conventional`, and the three conduct flags —
`auto_commit`, `auto_pr`, `auto_push` — to `true`, `agent_coauthor` with
them. `provenance_ledger` defaults to `false` by the same rule and lands
on the opposite side of it: no ledger existed before the key, so recording
nothing is the behaviour it preserves.

### `stage`

Ordered and cumulative, so one value rather than three switches. Each stage
stops the machinery the one below it does not need:

- `1` (tasks and specs) — no workflow runs. The four scripts still run as
  ordinary commands, so every guarantee they carry survives; what stops is
  the *enforcement*, which a person then performs deliberately.
- `2` (pull requests) — `writrun check` and `writrun approve` run.
- `3` (GitHub issues) — adds `writrun issues` and `writrun progress`.

**The four human gates are core at every stage.** A gate asks for *a human
decision, recorded*, never for a pull request specifically
([gates](../product/stage-1-tasks-and-specs/gates.md)). At Stage 1 a person performs each
directly and names how in their `AGENTS.md`, which Adoption already requires.
No check can verify that, which is why it is stated here: `stage: 1` is
not permission to drop them.

### `pr_title_style`

Governs every pull request title, including authoring ones, which carry no
task tag — and nothing else:

```
conventional   [TASK-0007] feat(ci): record approval on the merge
               docs(product): the merge is the assenting act

bracketed      [TASK-0007][Feat][CI] Record approval on the merge
               [DOCS] The merge is the assenting act
```

Composed by agents, and from Stage 2 checked at the door —
[observance](#observance-is-checked-where-it-leaves-a-trace): `writrun
check` fails a title that ignores the declared style. Nothing parses
the summary beyond that — not the release notes, which the forge
generates from pull requests.

**The commit subject is not this key's, and is not settable.** It is
Conventional Commits everywhere, whatever the title style: the squash
dialog's subject is the merging maintainer's to type, and the
machinery's own recording commits take theirs from `commit_subject.sh`
under the scope `queue`, now one literal per event rather than one per
event per style. A project choosing `bracketed` chooses it for the queue
its people read, never for `main`
([0063](decisions/pull-requests/0063-title-and-subject-are-two-texts.md)).

**The `[TASK-NNNN]` tag is in both and is not settable.** It is how
the machinery and `list_tasks.sh` learn which tasks a pull request
carries, and a branch name holds one id: a title without it reduces a
multi-task pull request to reporting one task, silently.

### The conduct flags

The adopter's word on the agent's own git actions, one flag per act:
`auto_commit` holds the commit, `auto_push` holds the push, `auto_pr`
holds the pull request. `true` — the default, and the behaviour from
before the keys existed — lets the agent take that action on its own as
its flow requires. `false` gates the action, never the work: the agent
still composes the whole thing — the full commit message, or the branch
and the pull request's complete title and body — presents it, and acts
only on an explicit yes. Approval is per action, never a session-wide
grant.

**`auto_push` exists because the push is the act that makes work
public.** A commit is private and a pull request is already a
conversation; between them sits the moment an adopter's work lands on
someone else's server, and until this key that moment was covered by
inference alone — read as `auto_pr`'s when a pull request was open, as
nobody's on a branch's first push. The inference covered the wrong half.
Taking a task pushes the branch and *then* opens the draft, so an
adopter who set `auto_pr: false` had their branch on the forge before
the gate they asked for was reached: what waited for the word was only
the pull request, half a step behind the act the gate exists to hold.

**Before a pull request exists, the push and the pull request are one
act, gated once.** The agent presents the branch, the title and the body
together, and `false` on either flag holds all of it — two prompts for
one moment is not a stricter gate, it is a worse one. Once the pull
request is open, a further push to its head branch is `auto_push`'s
alone: `auto_pr` has been answered, and what is being gated again is
work becoming visible.

**The flags outrank the agent platform's own autonomy mode.** An agent
running auto-accept, autonomous, or any mode in which its harness would
not ask, still stops: the platform's mode governs what the *harness*
asks, these flags govern what the *adopter* allowed — a setting that only
bound an agent already asking would control nothing, and a setting
controls (below). All three sit in `stage_2` because that is where the
actions they govern begin: git starts at Stage 2
([Adoption](../product/adoption.md#three-stages)), so below it there is
neither a commit, a push nor a pull request for a conduct flag to gate —
Stage 1 needs nothing but files. No flag touches the commits the
machinery makes nor any workflow-driven write — those are not the
agent's actions.

### `agent_coauthor`

The adopter's word on whether an agent appears as a co-author of what it
writes. `true` — the default — obliges the agent to append a
`Co-Authored-By:` trailer **naming the model** to every commit it makes,
and a credit line to every pull request body it writes. `false` means both
carry the change alone: no co-author trailer, no session URL, no tool
mention; the message reads as any other in the history.

**`true` states a shape, not a permission.** The key formerly said the
agent kept "whatever credit its platform appends", which named no artifact
and so could not be checked at all in that direction — a promise with no
shape is a promise nothing holds. Naming the trailer makes both directions
checkable ([observance](#observance-is-checked-where-it-leaves-a-trace)),
and it is what lets the commit history answer, on its own, which model
worked a change. The obligation follows from that: on a platform that
appends no credit of its own, the agent **writes** the trailer rather than
having nothing to keep.

The model is named specifically, not as a category — `Co-Authored-By:
Claude Opus 5`, never "an AI" — because the record has to survive the next
model's arrival to be worth reading a quarter later.

An instruction from the agent's own platform, in either direction, yields
to this file, with the same precedence the conduct flags above state. The
flag speaks only to what the agent writes: authorship identity stays git
configuration, other authors' commits are untouched, and nothing rewrites
history — it binds from the write after the flip. It is deliberately not
an `auto_` flag: those gate whether the agent may act, this states what
the act leaves written. It is also not commit signing, which is git
configuration and unrelated.

This is one half of what [Provenance](../product/concepts/provenance.md)
records. `provenance_ledger` is the other, and the two are independent:
turning either off never silently turns off the other.

### The declarations

Unlike the conduct flags, these gate no action — each answers, once, a
question every agent session otherwise re-asks. `spec_required` is the
project's word on when a task needs a spec: `always`, or
`when-warranted` (the default — the creation skill's own judgement
guidance applies). `decisions_style` names where dated decisions live:
`per-subsystem` (the methodology's default, and this repository's own
shape — an entry sits in the folder of the adoption level it concerns,
and the index carries the chronology the folders do not) or
`chronological` (one log across the whole project). `product_layout`
names how the product half is organized: `by-concept` (chapters about
ideas — this repository's shape) or `by-feature` (one doc per feature
— TOM's shape). `provenance_ledger` is the project's word on whether its
tasks carry a [provenance ledger](../product/concepts/provenance.md):
`false` (the default) means they carry none and every check is satisfied
by their carrying none — a project that works without agents, or that
wants no accounting, states so here and is asked for nothing. Each is a
declared variant from
[Adoption's open list](../product/adoption.md#mandatory-core-vs-documented-variant),
stated here so it is never reverse-engineered from the file tree.

### Observance is checked where it leaves a trace

A conduct flag binds the agent, but only some disobedience is visible
afterwards — and what is visible is checked, not trusted. From Stage
2, `writrun check` fails a pull request whose title ignores the
declared `pr_title_style`, and one that disagrees with `agent_coauthor`
**in either direction** — commits or a body carrying credit while the flag
is `false`, or an agent's commit lacking the model-naming
`Co-Authored-By:` trailer while it is `true`. The second direction is only
checkable because the flag now names an artifact rather than deferring to
whatever a platform appends, and it reads commits alone: a trailer has a
fixed shape and a place, a body's credit line has neither, so the body's
obligation at `true` stays instruction-bound. What leaves no trace at all
(`auto_commit`, `auto_pr` — whether the agent *asked*) is not checked: no
diff can show a question that wasn't asked, and no check infers one.

`check_observance.sh` is where both live. The title check strips the
`[TASK-NNNN]` tags — not the settable part — and reads what is left
against the declared style: the type against the vocabulary
`conventions/commits.md` carries, the scope against it too when one is
present, and nothing about the summary. Case inside a bracketed label
is not judged, because the convention writes both `[Fix]` and `[DOCS]`.
The credit check reads the pull request's own commits and body — never
`main`'s past, since nothing rewrites history — and skips the
machinery's recording commits **by committer identity**, not by subject.
The subject is now the machinery's own, and constant whatever the title
style says — but reading it would still be the wrong
test: a subject is text, and what makes those commits exempt is who
wrote them, which only the identity says.

**The `true` direction's unit is the pull request, and it has to be.**
Judging per commit would need a signal that does not exist: an agent
commits under whoever ran it, with the same name and the same email as
any other work of theirs, and the check is handed a title, a body and a
range. So the declaration is read where one exists — at `true` the flag
obliges a credit line in the body, and that line is the pull request
saying an agent worked it. When it is there, every commit that is not the
machinery's owes the trailer; when nothing declares agent work, no commit
is judged and the run says so.

That keeps the rule that matters: a human's pull request is asked for
nothing, because using an agent is not obligatory and a check demanding
the trailer everywhere would read absence as disobedience. It costs the
converse — a person's commit on a declared-agent branch is asked for the
trailer too, which is the trade
[0057](decisions/pull-requests/0057-the-credit-flag-names-its-artifact.md)
records. What the direction catches is partial compliance; what it cannot
catch is an agent that credits itself nowhere, and no check infers that
either.

**A category is not a model.** `Co-Authored-By: AI` satisfies any trailer
regex and answers nothing a quarter later, which is the whole reason the
trailer is worth reading — so a small vocabulary of category words, bare
family names among them, is refused. It is a tripwire and not a proof: a
name written to evade it evades it, exactly as the core-rule stems in
`check_settings.sh` do.

The ledger itself is not checked here. It is a queue field an agent
writes, not a trace left in the forge, and `provenance_ledger` gates
whether it exists at all — a project declaring `false` has nothing for a
check to read, which is a legal state and not a fault.

### The shape is a checked contract

JSON permits arbitrary nesting, arrays and free-form whitespace; a
line-based reader sees none of it and would misread in silence. So the
file is restricted to what such a reader can see — a two-level object and
nothing deeper. At the top level: scalar pairs (`"stage": 3`) and stage
sections, each opened by a two-space-indented `"stage_N": {` line of its
own and closed by a two-space `}` line of its own. Inside a section:
scalar pairs at four spaces. Every pair is one `"key": value` line,
values `true`, `false`, an unquoted integer, or a double-quoted string —
and `check_settings.sh` enforces all of it, including that every
documented key sits in its documented home. The subset is ordinary JSON
that any editor or `jq` reads.

`read_setting.sh` addresses a sectioned key through its section —
`read_setting.sh stage_2.pr_title_style` — and a top-level key bare:
`read_setting.sh stage`. The address, not the name, is a key's identity.

What the restriction buys is that no script needs `jq`, which would be this
project's first runtime dependency (see the non-goal in
[`about.md`](../about.md#non-goals--equally-important)): one nesting level,
entered and left on lines of fixed shape, is still sed/awk territory.
Strictness is scoped
to where the risk is: keys a workflow parses are shape-checked; keys only an
agent reads are checked for value alone, since an agent reads JSON the way it
reads prose.

Two things the file may never do: carry a key that switches off anything in
Adoption's **core** list, and carry reasoning — that stays in
`.writrun/conventions/*.md`, and nothing is stated in both.

**A setting controls; it never merely describes.** `stage: 1` means the
workflows stop, not that a reader is told they were deleted. The alternative
is the failure [`0041`](decisions/0041-the-issues-mirror-is.md) named when it
rejected a flag: two ways to say one thing, free to disagree.

## Task selection algorithm

Deterministic, independent of file layout on disk:

0. **Resume before selecting.** If any task has `status: in-progress` or
   `in-review` with no open pull request working it (the machinery keeps
   the two in step with the forge, so a lasting mismatch is work someone
   abandoned without the forge hearing about it), or whose open pull
   request is this session's own, resume it — do not pick new work
   while started work sits unfinished. An in-flight task whose open
   pull request is someone else's stays theirs, however stale: the
   lister names it as in flight rather than hiding it, and taking it
   over — closing or adopting their pull request — is a human decision,
   never the algorithm's. **Resuming re-checks the authorization**: read
   the resumed task's `spec_ref` against the authority branch *and*
   against open pull requests — an amendment may have suspended the task
   mid-flight, and the authority branch alone cannot show an amendment
   still riding an open pull request
   ([statuses](../product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request)).
   A suspended task is resumed by finishing or waiting out the
   amendment, never by implementing against a spec whose approval is in
   question. Only when no resumable task exists does selection proceed.
1. Read the front-matter of every task.
2. Keep those with `status: ready` — `backlog`, `blocked` and the
   in-flight and terminal states are excluded here by construction, with
   no extra rule needed.
3. Keep those whose every `depends_on` entry has `status: done`.
4. Confirm every `spec_ref` entry holds `status: approved` or
   `implemented` — at Stage 2+ the machinery already wrote `ready` from
   exactly that fact, so this is a cross-check; at Stage 1, where
   statuses move by hand, it is the gate itself. A task with a spec
   still in `draft` is not authorized work: the approval gate has not
   been passed, so selecting it would hand an agent a brief nobody
   assented to. A task with an empty `spec_ref` passes this step by
   construction.
5. Sort by `priority` — `high`, then `medium`, then `low`.
6. Break ties by `created` ascending, then by `id` ascending.
7. Take the first. Read every entry in `spec_ref` (if any) and `doc_ref`
   (if set) before writing any code.

`ready` is stored, and steps 2–4 still agree by construction: the
machinery derives the flip from the same facts step 4 re-checks
([statuses](../product/stage-2-pull-requests/statuses.md)). The cross-check is
deliberate — a stored status that could silently disagree with the facts
it summarizes is exactly what the old derive-don't-store rule feared, so
the algorithm keeps reading both and stops loudly on a mismatch.

**Steps 2–4 are eligibility; steps 5–6 are only order**, and the two bind
differently. The filters bind everyone: a task that is `blocked`,
dependency-gated, or whose spec is still `draft` is unavailable to anybody,
and no judgement overrides that — those are the gates, expressed as a
query. The sort binds agents only. It exists so repeated sessions reach the
same answer instead of each re-deriving one, not to claim the
highest-priority task is the only legitimate one. **A human may take any
eligible task, out of order, and bypasses nothing by doing so.** An agent
may not, because determinism is the whole property the sort provides.

Step 7 has to branch on an empty `spec_ref`: with no spec, the task's own body
plus `doc_ref` is the whole brief, and whether that's sufficient — or
whether the agent should stop and ask for a spec first — is a call this
methodology leaves to the adopting project, stated explicitly in its
`AGENTS.md`.

## The report entry point

The cheapest way work enters the system, and the one a client wraps
first: **a report is one free-form sentence** — "checkout returns
500", "the generator reuses ids" — plus whatever evidence is at hand.
No form and no prose requirement — but the report is **kept**,
not consumed: it becomes a file that records the observation and,
later, the route triage sent it down ([report schema](#report-schema)).
Everything else structured about it is still produced *from* it,
downstream. The product-side flow, gates and triage table live in
[authoring — reporting](../product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight);
this section is the operation's contract, for agents today and the CLI
tomorrow.

The operation, deterministic end to end:

1. **Record** — the observation becomes a file: `new.sh report`,
   `status: open`, evidence in the body as text and links. This runs
   **before** triage and before the dedup search, because capture is
   the step that has to cost nothing — a duplicate report is cheaper
   than a finding nobody wrote down. It rides whatever change is
   already open: a report is neither a rule nor work, so the
   one-kind-per-change rule does not reach it.
2. **Dedup** — at triage, the non-completed tasks are read; a report
   matching one ends `tracked` against that task and the operation
   stops there. New evidence it carried enriches the existing task's
   body through a normal queue change. A client implements this as a
   search over `work/tasks/` front matter and titles, never as a
   question to the reporter.
3. **Triage** answers two questions in order — *is this worth acting on
   at all?*, then, for what survives, *is what "correct" means already
   written?* Four outcomes, and each writes the report's terminal
   status: not a defect, or not worth acting on → `declined`, with the
   reason in the body; a defect against documented behaviour → a task,
   `tracked`; a rule nobody wrote → route to authoring, `authored`; a
   trivial fix → a commit, `fixed`. The first question is new: while
   reports evaporated there was nothing to close, so one question
   sufficed and the table never had to name a "no". Both are the
   agent's to answer, `declined` included — triage is not a human gate
   ([gates](../product/stage-1-tasks-and-specs/gates.md)).
4. **Generation**, on the defect path: `new.sh task` with
   `--origin report`, `--doc-ref` when a doc states the violated
   behaviour (null when the broken thing was never documented),
   priority from impact; a spec via `new.sh spec` when the fix is more
   than the body can brief. **Evidence — the error, the log excerpt,
   the reproduction — lives in the task body, as text and links**: the
   mirror is one-way, so anything attached only to an Issue never
   reaches the file that is the authority. The generated queue is
   **presented to the human before any PR opens** (the
   derivation-review gate). The new task's id is written onto the
   report's `task_ref`, which is the only link between the two — the
   task schema carries nothing pointing back.
5. **Recording**, at Stage 2+: branch `report/short-name` — no task id
   in the name, because the PR records work rather than working it —
   and a PR that only adds queue files. The merge authorizes the task;
   the approval gate takes over. **This branch is for a change that is
   only a report**; a report file added alongside other work needs no
   branch of its own, which is step 1's exemption seen from the forge
   side.

One inversion a client must know: **an outage ships the fix first.**
When documented behaviour is down, the patch goes out through an
ordinary PR at whatever size the outage demands, and the report runs
immediately behind it, triaging what remains — the patch itself gets
no retroactive task
([the reporting rules](../product/stage-1-tasks-and-specs/authoring.md#reporting--work-found-or-reported-mid-flight)).
This is the one case where step 1 follows the work instead of leading
it: "capture costs nothing" is the reason recording comes first, and no
reason of that shape outranks a live outage. The report still gets
written — `tracked` when work remains, `fixed` when the patch was all of
it — because an outage nobody recorded is the finding most worth having.

What a client (`writ report`) builds on is exactly the public contract
below: the task, spec and report schemas (`origin: report`
included), the generator's arguments and refusals, the `report/` branch
prefix, and the `## Derived work` marker in the PR body. The triage judgement
itself is the one step that is not mechanical — a client either asks
an agent to make it or asks the person, and the contract stays the
same either way.

## Distribution

The operational half of the methodology — selecting the next task, drafting a
task or spec, checking a spec's promised deltas against a diff — ships as
**skills**: copied files, no binary, no install step. A CLI exists as a
separate, optional client (`writrun-cli`, below); the methodology itself
never depends on it. Three reasons the skills are the mandatory form:

- **The agent already writes the files.** An agent with file tools and
  `AGENTS.md` in context can create a correctly-shaped task or spec directly —
  a CLI subcommand that also writes the file duplicates work the agent
  already does natively.
- **No language lock-in.** Skills are markdown instructions, all five of them
  backed by a small deterministic script for the one step each that must
  not be self-graded or hand-derived from memory — see below. This keeps
  the methodology's own non-goal — "not tied to one language, framework, or
  agent platform" — true of its tooling, not just its docs.
- **Distribution is already solved.** Skills install through the same
  mechanism adopters already use for other reusable instructions — no
  install script, no binary to build per platform.

The five skills, in `.writrun/skills/` — WritRun's own home, never the
project's skill folder; see
[Adoption's skills-namespacing note](../product/adoption.md#skills-namespacing)
for how the two sets stay apart by path and by prefix:

- **`writrun-select-next-task`** — runs the [selection algorithm](#task-selection-algorithm)
  exactly as specified, so every agent session gets the same answer instead of
  each one re-deriving it from the prose.
- **`writrun-create-task-and-spec`** — turns `AGENTS.md`'s prose instructions on task
  and spec creation into an active, checklist-driven skill: what front-matter
  to fill, when a spec is warranted, how to fill the Proposed changes
  sections. Backed by `new.sh`, which scaffolds a schema-correct
  `task-nnn.md` / `spec-nnn.md` — id increment, list-typed fields, every
  field present — mechanically rather than from an agent's memory of the
  schema (see [Task's worked example](../product/concepts/task.md#example)
  for the drift this replaces).
- **`writrun-check-spec-deltas`** — verifying that a completed diff touches
  everything a spec's Proposed changes section promised, and nothing
  permanent it didn't, is objective, mechanical checking. An agent grading
  its own diff is the wrong shape for that — the skill wraps a small
  deterministic script (grep/diff based, no runtime dependency) instead of
  asking the agent to self-attest.
- **`writrun-check-task-state`** — the same argument applied to status rather than
  paths. The transition it exists to reject is `draft → approved`, which an
  agent may never make, including on a spec it wrote itself; asking that
  agent whether it respected the gate is asking the wrong party. Backed by
  `check_state.sh`, which also rejects the two ways of routing around the
  gate: `draft → implemented`, and completing a task whose spec is not
  `implemented`.
- **`writrun-check-front-matter`** — every reader above is line-based on
  purpose, and YAML permits shapes those readers silently misread: a block
  list that reads as empty, a quoted value that never matches a path
  comparison. So the canonical form of
  [Front matter is canonical](#front-matter-is-canonical) is a checked
  contract, not an assumption — `check_front_matter.sh` validates every
  queue file against it, on files alone, no git and no forge, which makes
  it the one check available at every adoption stage.

The whole adoption kit ships as [`template/`](../../template), one folder
**shaped exactly like the destination root** — that is what a template
is: `.writrun/`, the four `writrun-*.yml` workflows, `work/`, the
skeletons for `AGENTS.md` and `docs/`, and the guide itself as
`WRITRUN.md` — a name that collides with nothing and stays behind as a
provenance pointer after adoption. **Severing the mirror is the `stage`
setting, not a deletion.** An adopter that wants no GitHub Issues lowers
the top-level `stage` below `3`, and every mirror in the kit stands down
at once: `writrun-issues.yml` is wholly Stage 3, so is
`writrun-progress.yml`'s `reflect` job, and so are the two mirror steps
`approve` carries. Those steps are what changed the instruction — a
merged close has exactly one owner, and it has to be the workflow that
writes the queue, because a label derived from anything but the queue
after the recording commit is derived from a state the merge already
changed. Delete the two mirror workflows and leave `stage` at its
default of `3`, and `approve` goes on minting and labelling mirrors at
every merge; lower the stage, and deleting them is tidying rather than
severing. `writrun-issues.yml` is the only one a deletion severs
cleanly: `writrun-progress.yml` also carries Stage 2's in-flight status
recording, and `check` and `approve` stand alone. The guide names the
kit's two collision
points — an existing `AGENTS.md` is grafted, never overwritten; existing
docs are kept — while everything else the copy lands is
WritRun-namespaced. The kit deliberately ships **no README.md**: the one
file whose blind copy would replace the adopting project's own. The mirrored parts are a
**deliberate full copy**, kept byte-identical to this repository's own
root files by a unit test (`make template-sync` refreshes; the mirror
list is `tests/template_mirrors.txt`, the single source of what ships).

**A script's data file ships beside the script.** The vocabulary lives
in `.writrun/scripts/stage-2-pull-requests/`, next to the check that
reads it, and not in this repository's `tests/` — the mirror carries
`.writrun` whole and carries nothing else, so a data file left outside it
reaches no adopter, and the check they run passes by knowing nothing.
That is a silence, not a pass, which is why the absent case says so.

**The mirror holds bytes; the kit's own prose is held by words.**
Everything under `template/` that is *not* mirrored — its `AGENTS.md`,
its `WRITRUN.md`, its `docs/` and `work/` chapters — has no byte-for-byte
guard, and cannot have one: those documents differ from this
repository's on purpose. What they share is the vocabulary, so
`check_doc_shapes.sh` reads them for both halves — the front matter they
show, and the words they use. That is the structural reason the kit
shipped a retired status long after the queue stopped having it, and the
reason a second mirror was not the answer.

**One file leaves the mirror on purpose: `.writrun/settings.json`.** The
kit ships it cautious — `stage: 1`, every conduct flag `false` — because
a fresh copy of this repository's own file would start an adopter at
Stage 3 with every workflow armed and the Issues mirror opening issues on
their first pull request, while the guide is still telling them to
declare a stage. `tests/template_exceptions.txt` is the single source of
what differs, read by the sync and by the unit test alike. The sync
stashes each listed path before the mirror runs and restores it after —
not merely declining to overwrite it, because the mirror list names
`.writrun`, a directory, and a directory is refreshed by removing it and
copying it back; every path it keeps is named in the output. The test
drops the same paths from both sides before comparing, by path and never
by name, so `.writrun/conventions/settings.json` — the legacy address the
reader still honours — stays compared.
This repository's own CI beyond the writrun workflows — the pull-request
suite in `.github/workflows/tests.yml` and the release-readiness
pipeline on `main`, `.github/workflows/release-readiness.yml` — is not
part of the kit and stays home.

**A red `main` that a script can fix is the bot's to fix.** The
readiness pipeline separates two kinds of failure. Drift a
deterministic regeneration repairs — the template out of sync with the
root it mirrors — it repairs itself: the pipeline runs the
regeneration and, when that produces a diff, commits the sync to
`main` with the same token and the same rebase-not-force pattern the
queue recording uses. Because a `GITHUB_TOKEN` push triggers no new
runs, the same job then re-runs the suite itself, so the verdict on
the healed tree lands in the run that healed it. Readiness goes red
only for what regeneration cannot repair — a genuine breakage that
needs thought. A pipeline that fails asking a person to run
`make template-sync` is a machine demanding a human do a machine's
job, which is the failure the queue recording already refuses
everywhere else.

**Skills are the plumbing; a CLI is welcome porcelain — in its own repo.**
Nothing above forbids a human-facing command line (`writ list`,
`writ init`, `writ doctor` — the binary is `writ`, per About); it forbids
the methodology *depending* on one. A CLI lives in a separate repository (`writrun-cli`), wraps the
same scripts and files, and everything here keeps working without it —
agents use skills, CI uses scripts, files stay the authority. What tooling
like that builds on is this file's **public contract**: the task and spec
front-matter schemas, the `docs/` + `work/` split, each script's arguments
and exit codes, and the handful of grep-level markers the machinery reads
— the `## Derived work` heading in a PR body, the two Proposed-changes
headings in a spec, a task file's `# ` title line, a `task-nnn` /
`spec-nnn` id at the start of a branch name, and the labels the machinery
owns and filters on: `writrun:task`, the `status:*` values
(`proposed`, `backlog`, `ready`, `in-progress`, `in-review`, `blocked`)
and the `origin:*` values (`rule`, `report`)
— renaming any of these means adapting the workflows. One carve-out runs the other way:
`docs/writrun-instructions.md` is process metadata, not project truth —
no task derives from it and every check ignores it. **Everything else about
commits, pull requests, and task/spec style is the adopter's convention,
not the methodology's**, and it lives in one editable folder at the
repository root — `.writrun/conventions/`: commit types and scopes, branch naming,
the PR title rule, the merge policy, task and spec taste. The one commit
the machinery makes has its title as a variable at the top of
`writrun-approve.yml`, and the PR template ships as an editable default
alongside. Versions are tags on `main`
(the first: `v0.0.01`, and the third field stays two digits) — everything merges to `main` continuously, and a
version exists when its tag does. The number measures this contract, not
the code, and it is computed, never typed: `make release` cuts one, with a
vocabulary that is deliberately WritRun's own rather than SemVer's —
`minor` bumps the third digit (the default), `major` the middle one,
`epoch` the first, reserved for historic milestones. The target derives
the next number from the latest tag, stamps it into `.writrun/VERSION` —
the kit carries the stamp, so an adopter, and the future `writ update`,
knows which tag a copy came from — syncs the template, runs the suite,
and only then commits, tags, pushes, and publishes the GitHub Release
with notes generated from the conventional commits. While the methodology
is alpha (0.x), the contract itself moves without notice; a client or an
adopter pins the tag it targets.

## Decisions

In [`decisions/`](decisions/README.md) — the dated why behind each piece
of machinery and what was rejected, append-only, one numbered file per
decision with the index carrying the chronology. This heading stays so
old links keep resolving; the entries live there.

