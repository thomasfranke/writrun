---
name: writrun-create-task-and-spec
description: Use this skill when creating a new task, spec or report in a project that follows the WritRun methodology — when the user asks to track a piece of work, when work is found that isn't yet tracked, when something is observed that is worth writing down but not yet worth working, or when an existing task needs its spec drafted before implementation can start. Covers front-matter schema, id assignment, which of the three kinds a change needs, when a spec is warranted, and how to fill the Proposed changes sections.
---

# Create a task, its spec when warranted, or a report

Turns the WritRun schema into a checklist instead of something re-derived
from memory each session. Read `docs/technical/README.md` in the target
project first if it's present — it may state adopter-specific choices (id
prefix, whether a spec is mandatory) that override the defaults below.

## Which of the three?

A typo or a one-line fix is a commit, not a task. Create a task only for
work that justifies tracking: a behaviour change, a new subsystem,
anything a future reader might reasonably ask "why was this done" about.

**A report is the third answer, and it is the cheap one.** A task says
work will happen; a spec says how. A report commits to nothing — it says
only that something was seen, and that seeing it was worth a file. Its
bar is deliberately far below a task's: a task needs work worth
tracking, a report needs an observation worth remembering.

| You have | Write |
|---|---|
| work that justifies tracking | a task |
| an observation, and no decision yet about what follows | a report |
| a one-line fix you are making now | a commit — and a report only if the finding outlives it |

The line between the first two is what the sentence *says*, not how
important it is. "The mirror shows `backlog` for four tasks `main` holds
as `ready`" is a report. "Fix the mirror to read the merged ref" is a
task with no task file — it names an action, so it is a commitment
wearing a report's front matter.

When in doubt, write the report. It costs one file, it can be triaged
into a task in one command, and the failure it exists to prevent — the
finding that stayed in a conversation — is not recoverable later.

## Creating a task

Run the generator rather than writing the front-matter from memory — a
hand-written task drifted on four of these fields while this methodology's
own `docs/product/` chapters were being drafted (see
`docs/product/concepts/task.md#example`), which is exactly the kind of
drift this script exists to make impossible:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh task "<title>" \
  --origin rule|report \
  --slug <two-or-three-words> \
  [--priority high|medium|low] \
  [--depends-on task-nnnn,task-mmmm] \
  [--doc-ref path/to/doc.md#anchor] \
  [--milestone name]
```

**`--origin` is required, and it records a fact, not a preference:** how
this task came to exist.

- `rule` — it was derived from an authored rule a human declared
  finished (flow 1). The doc came first and the task exists to bring the
  system up to it.
- `report` — it was born from a report of work an existing rule already
  authorizes: a defect someone hit, a gap found in the code or the
  machinery. The doc it points at validates the task; it did not
  generate it.

There is no default and no third value. An unstated origin refuses,
because the one thing worse than being asked is a wrong fact recorded
silently — and the field is written once and never rewritten.

**Choose the slug. Deriving it is the fallback, not the default.** It is
shown above without brackets for that reason: `--slug` is the one argument
you are expected to think about, because "which task is this, among these"
is a judgement about the queue and not a string operation on the title. The
derivation takes the title's first three words, which is why
`work/tasks/` grew `task-0009-stamp-queued-and.md` — a filename that breaks
mid-phrase and tells a reader scanning the directory nothing. Two or three
words that name the *subject*: `stamp-queue-dates`, not the title's opening.

Omit it and the derivation runs, unchanged. It is there so the generator
works when nobody chose, never as the outcome to aim for.

It finds the highest existing `task-nnnn` id and increments it (never reuses
or renumbers one, even if a task was later deleted), and writes
`work/tasks/task-nnnn-<subject>.md` — the id plus the subject slug, which
makes a directory listing readable without ever being identity — with every
field present explicitly, an empty list never the same as an omitted field:

```yaml
---
id: task-0007
status: backlog
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: null                       # or --doc-ref's value
origin: rule                        # or report — --origin's value, always one of the two
priority: medium                    # or --priority's value
depends_on: []                      # or --depends-on's value, as a list
milestone: null                     # or --milestone's value
created: 2026-08-21T09:14:00Z       # now, in UTC
queued: null                        # machinery only
completed: null
merged: null
provenance: []                      # the ledger, empty until somebody records
---
```

Then fill in the generated body: the request only — what to do, and why it
matters. No acceptance criteria, no step-by-step plan, no technical detail:
that belongs in the spec, not the task. Fill any extension fields the
project's template added to the front matter too — see the next rule.

**Leave the generated References line alone.** The body carries every
reference as a clickable relative link — the task's `doc_ref` and each
spec in `spec_ref`, a spec's `task_ref` — and the generator writes it,
including on the run that appends a new spec. The front matter keeps the
same references as plain strings, because that is what the machinery
reads; the two must never disagree, so neither is edited by hand.

If the script isn't available in the target project (not yet copied in, or
no bash), do the above by hand — the schema is normative either way, the
script is just the mechanical way to hit it exactly.

**Body shapes resolve in layers, and the project's wins.** The generated
body comes from `.writrun/conventions/templates/task.md` (or `spec.md`) when the
project defined one; otherwise from the shipped default in
`.writrun/templates/`; otherwise from the script's built-in skeleton.
When writing by hand, honour the same order.

**Read the resolved template as the project's brief, not just a shape.**
The *contract* front matter is never templated — the script generates
it, and refuses a template that redefines a contract field. But a
project template may open with a front-matter block of its own:
**extension fields** (owner, estimate, whatever the project tracks),
which the script appends to the generated contract block, placeholder
values and all. Filling them is your job, exactly like the body: treat
each extension field's placeholder text — and anything the template's
body says about it — as the project's instruction for what belongs
there, and never hand over a task or spec with a generated placeholder
still standing. A spec template must also keep the two Proposed-changes
headings and Outcome, or the script refuses it.

## Does this task need a spec?

**Read `stage_1.spec_required` first — the project may have answered
this already**
(`bash .writrun/scripts/stage-2-pull-requests/read_setting.sh stage_1.spec_required`,
which prints its documented default when the file or the key is
absent):

- `always` — every task gets a spec. There is no judgement left to
  make; the rest of this section does not apply, and a task shipped
  without one is the project's rule broken, not a call you were free
  to make.
- `when-warranted` — the default, and the judgement below is the
  guidance the project chose to keep.

Skip the spec only if the task is small enough that its own body plus
`doc_ref` is a complete, unambiguous brief. Default to writing a spec
whenever:

- the work touches more than one file or subsystem,
- there's more than one reasonable way to implement it, or
- the task references a `doc_ref` that needs translating into concrete
  technical steps.

When in doubt, write the spec — an unnecessary spec costs a review; a
missing one costs an agent guessing at scope.

## Creating a spec

Same generator, second subcommand:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh spec task-nnnn "<title>" \
  --slug <two-or-three-words>
```

`--slug` means the same thing here, and is chosen for the same reason.

`task_ref` must point at a task that already exists — the script refuses
otherwise, because a spec is never created before its task; it resolves the
argument by number, so any spelling of the task's id finds it, and records
the id the task file itself carries. It finds the
highest existing `spec-nnnn` id and increments it, writes
`work/specs/spec-nnnn-<subject>.md` — named the same way a task is, slug
included — with
`status: draft` and a body skeleton (Scope,
Steps, Acceptance criteria, Edge cases, Tests required, Definition of Done,
and both Proposed-changes sections defaulted to "none"), and **appends**
the new spec's id to the task's `spec_ref` list itself — never overwriting
existing entries.

Then fill in the skeleton:

1. Scope, steps, EARS-format (`When <trigger>, the system shall <response>`)
   acceptance criteria, edge cases, tests required, Definition of Done.
2. Replace both Proposed-changes placeholders with real entries whenever the
   task changes behaviour or machinery:

   ```markdown
   ## Proposed product changes
   - `path/to/doc.md#anchor` — one line on what changes and why.

   ## Proposed technical changes
   - `path/to/doc.md#anchor` — one line on what changes and why.
   ```

   Every path here must be one the completing diff will actually touch —
   this list is the merge contract checked by the `writrun-check-spec-deltas`
   skill. Leave either section as "none" only if genuinely nothing in that
   category changes.
3. Fill any extension fields the project's template added to the front
   matter — their placeholder text is the project's instruction for what
   belongs in each.
4. Leave `status: draft`. Moving to `approved` is a human decision (or
   whatever the target project's `AGENTS.md` states) — never set it here.

If the script isn't available, do the same steps by hand, including the
manual `spec_ref` append on the task file.

## Recording a report

Same generator, third subcommand:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh report "<title>" \
  --slug <two-or-three-words> \
  [--doc-ref path/to/doc.md#anchor]
```

`--slug` means the same thing here, and is chosen for the same reason.

**It takes neither `--origin` nor `--priority`, and both refuse by
name.** `origin` is a fact about how a *task* came to exist and a report
is one of its two answers — a report has no origin of its own.
`priority` orders work, and a report commits to none: whether anything
follows is triage's answer, written as the report's status.

`--doc-ref` is the doc this observation is **answered by** — the rule
that was violated, or the rule that had to be written. One field under
both readings, because those are the same sentence read before and after
the rule existed. Leave it out when nothing documents the thing observed,
which is the common case: a typo violates no rule.

The generated file carries `status: open`, `task_ref: []` and
`triaged: null`. Then write the body: **what was observed, with whatever
evidence is at hand** — the error, the log excerpt, the four Issue
numbers. What should be done about it is triage's output, never the
report's content. The moment a report carries scope, steps or a plan it
has become a task wearing the wrong front matter, and `work/` has grown
a second queue nobody selects from.

### Recording rides any change

A report may be added in **any** change — an implementing branch, an
authoring branch, a branch that is mostly about something else. The
one-kind-per-change rule does not reach it, and this exemption is the
whole feasibility of the feature: findings arrive while you are busy
with something else, and a note that costs its own branch, its own pull
request and its own review is a note nobody writes.

The `report/` branch prefix is for a change that carries *only*
reporting. **Recording** does not wait for one. The `tracked` route
does, and the next section is where that is stated.

### Triage, and the statuses that record it

A report's status is **the route triage took, not a lifecycle**. One
non-terminal value and four ends:

| Status | Means | What names the outcome |
|---|---|---|
| `open` | recorded, not yet triaged | — |
| `tracked` | a task now carries the work | `task_ref` |
| `authored` | no rule stated what "correct" was; a rule was written | `doc_ref` |
| `fixed` | a trivial change handled it | the git history |
| `declined` | not a defect, or not worth acting on | the body says why |

**There is no `resolved`.** Whether the underlying problem is fixed is
the *task's* status, one hop away through `task_ref`; a second copy of
it would need a second writer to stay true.

Triage answers two questions in order — *is this worth acting on at
all?*, then *is what "correct" means already written?* Both are yours to
answer, `declined` included: triage is not a human gate. Declining
destroys nothing — the file stays, the body carries the reason, and at
Stage 3 the mirror closes *not planned* where a person can disagree.
Disagreeing records a second report; **nothing reopens one**, and a
recurrence is a second observation with its own id and its own date.

**The `tracked` route never rides.** It is the one route that puts work
in the queue, and what enters the queue passes a gate: deriving a task
from a report is a reporting change of its own, on a `report/` branch,
whose pull request presents the report, the task and the spec together —
and the maintainer's squash-merge of *that* pull request is the assent
that the finding deserves the work. So the branch comes first:

```bash
git switch -c report/<short-name>
```

Riding an unrelated change here is not a style point. `check_state.sh`
refuses it, in CI too (`writrun-check-task-state`, rule K), and the
generator below refuses it as well rather than leaving three files
half-routed for you to undo by hand. From Stage 2 up, that is; a
branchless project has no pull request to be the vehicle, and the route
runs where it works.

Then let the generator close the link:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh task "<title>" \
  --from-report report-nnnn --slug <two-or-three-words> [...]
```

`--from-report` **states the origin** rather than defaulting it — the
flag names the report the task was born from, which is the whole content
of `origin: report`, so `--origin` becomes unnecessary and `--origin
rule` alongside it is refused. It appends the new task's id to that
report's `task_ref` (never overwriting, because triage can split one
finding into several tasks), stamps `triaged`, and moves a report still
`open` to `tracked`. Those move together by contract: `triaged` is null
exactly while a report is `open`.

The other three ends are written by hand, in the same change that took
the route: the status and the `triaged` timestamp, together. Any queue
file touched by hand goes through `writrun-check-front-matter` before it
is committed.

**Evidence lives in the file, never only in an Issue.** The mirror is
one-way, so anything attached to a mirrored Issue never reaches the
report or the task that is the authority.

## When completing a task

1. Fill the spec's **Outcome** section: what was actually built, and any
   divergence from the original plan, and why. Do not silently edit the
   Proposed changes sections to match reality after the fact — the
   divergence is the record.
2. Set the spec's `status: implemented`.
3. Fill the task's `completed` date (a UTC timestamp) — and touch its
   `status` line **never**: from Stage 2 up that line is the machinery's,
   and the merge is what flips the task to `done` when it lands your
   date (product/stage-2-pull-requests/statuses.md).
4. Record what the work cost, where the project keeps a ledger:

   ```bash
   bash .writrun/scripts/stage-1-tasks-and-specs/record_provenance.sh \
     task-nnnn by=agent model=<the model id> login=<who ran it> \
     input=N output=N cache_read=N cache_write=N
   ```

   The writer only ever **appends**, and that is the whole shape of the
   permission: this is the one machine field a branch may write, because
   no forge event carries a token count — only the session that spent
   them knows. An entry already written is never edited, and
   `writrun-check-task-state` refuses a diff that edits one.

   `record_provenance.sh` reads `stage_1.provenance_ledger` first, so
   running it in a project that declares none writes nothing and says so
   — run it unconditionally rather than deciding for the project. Where
   the agent platform keeps usage data, `read_usage.sh` proposes the
   entry from it and its output is this script's argument list; where it
   does not, the counts come from wherever the platform reports them, and
   a task worked by hand records `by=human` with no model and no counts.

## Never

- Never create a spec without a `task_ref` that resolves to a real task.
- Never rename or renumber an existing id.
- Never move status information into a folder structure — it lives in
  front-matter only.
- Never reopen a report, and never move it from one end to another. The
  same thing seen again is a second observation: record a second report.
- Never let a report carry scope, steps or a plan. That is a task, and
  the wrong front matter around it hides it from the only queue anyone
  selects from.
- Never route a report to `tracked` on a branch that is about something
  else — and never rename that branch to `report/…` to get past the
  check. The prefix is how a reporting change is recognised, not what
  makes one: a branch still carrying the implementation is exactly the
  ridden merge the rule exists to stop.
