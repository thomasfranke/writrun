---
id: spec-0088
task_ref: task-0062
status: implemented
created: 2026-09-06T05:16:45Z
---

# spec-0088 — One writer per pull request, and a reconciler that retires duplicates

**References:** [task-0062](../tasks/task-0062-serialize-forge-writes.md)

- **Goal:** two forge events for one pull request never run a
  forge-writing pass concurrently, and a duplicate mirror that exists
  anyway is retired by the reconciler that finds it.

## Scope

In: `concurrency` groups for the three forge-writing workflows that
lack one — `writrun-issues.yml`, `writrun-progress.yml`,
`writrun-approve.yml` — keyed by pull request number,
`cancel-in-progress: false`. Queue, never cancel: every pass is a
reconciler, so the run that waits reconciles the newest state anyway,
while a cancelled run can die between two writes it meant as one.
Workflows that write the same artifact share one group so they
serialize against each other, not only against themselves; the
implementation reads each workflow's writes to draw that line, under
the rule that the mirror's writers (`issues`, `approve`) are one
family. `writrun-intake.yml` already declares its own and is untouched.

In: the duplicate a group cannot prevent — one already standing, or two
minted by runs on different pull requests. The mirror lookup in
`mirror_issues.sh` takes the first title match today and never looks at
the rest; it learns to see every open mirror for an id, keep the oldest
(the first minted, lowest issue number), and close the others with a
comment naming the survivor. `rederive_labels.sh` gets the same rule if
its lookup shape shares the blindness — read before assuming either way.

Out: any change to what the passes write per record — labels, bodies,
status projection all stand. This spec is about how many writers run
and how many mirrors survive, not what a mirror says.

Out: forge-side uniqueness. GitHub offers no unique constraint on issue
titles, so prevention is serialization plus a self-healing reconciler,
not a constraint the platform does not sell.

## Steps

1. The `concurrency` blocks, one per workflow, grouped per the rule in
   scope; queue, never cancel.
2. The lookup in `mirror_issues.sh`'s two loops (tasks, reports)
   collects every open match instead of the first; oldest survives,
   the rest are closed with a comment naming it and the run.
3. The same audit of `rederive_labels.sh`'s lookup, folding it into
   the shared rule where it is blind the same way.
4. `technical/decisions/github-issues/0073-one-writer-per-pull-request.md`
   — the group rule and the queue-not-cancel choice, with the rejected
   alternative (cancel-in-progress, and why a reconciler must not die
   mid-write) and report-0038 as the incident. `decisions/README.md`
   gains the chronology row.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When two events for one pull request trigger a forge-writing
  workflow, the system shall run their passes serially.
- When the reconciler meets more than one open mirror for one id, the
  system shall keep the oldest and close the rest, each close naming
  the survivor.
- When the existing suite runs, every pass shall write per record what
  it wrote before this spec.

## Edge cases

- **The duplicate wears status labels.** The close does not rewrite
  them — a closed duplicate's labels are history, and the survivor's
  labels stay the one writer's (the machinery's) to derive.
- **Both duplicates predate the rule's title shape.** The lookup that
  finds them is the widened one, so both shapes are in the candidate
  set before oldest-wins picks.
- **A third event lands while one run waits.** The forge keeps one
  queued run and supersedes it; the last run reconciles everything, so
  a superseded event loses nothing.

## Tests required

- Integration cases for the dedup: two open mirrors for one id — the
  older survives, the younger closes naming it; one mirror — untouched.
- The workflow YAML carries no executable logic to test (decision
  0012); the `concurrency` blocks are review's to check, and the
  decision entry records what to look for.
- The full existing suite green.

## Definition of Done

- [ ] Three workflows declare `concurrency`, grouped per the rule.
- [ ] The reconciler retires duplicates, oldest surviving, tested.
- [ ] Decision 0073 recorded, chronology row appended.
- [ ] `make template-sync` run; `template/` matches byte for byte.

## Proposed product changes

- none — the mirror's meaning is unchanged; one-mirror-per-record was
  always the intent, and this makes it hold.

## Proposed technical changes

- `technical/decisions/github-issues/0073-one-writer-per-pull-request.md`
  — new entry, per step 4.
- `technical/decisions/README.md` — append 0073's row to the
  chronology.

## Outcome

Implemented as specified. The three workflows declare `concurrency`,
grouped per the rule: `writrun-issues.yml` and `writrun-approve.yml`
share `writrun-mirror-<pr>` — the mirror's writers are one family —
and `writrun-progress.yml` holds `writrun-progress-<pr>` of its own;
both of its event kinds (`pull_request_target`, `pull_request_review`)
carry a `pull_request`, so the key resolves on every trigger.
`cancel-in-progress: false` is stated explicitly in all three, with
the why beside it. Decision 0073 records the rule and the rejected
cancel.

The dedup landed in `mirror_issues.sh` as a pass over the two lists it
already fetches, before any lookup reads them: `dup_pairs` derives the
open duplicates (oldest number surviving), `retire_dups` comments
naming the survivor and closes `not_planned`, and the retired rows are
filtered from the in-memory lists so the same run's lookups read the
healed forge. Drafts exit before the lists are fetched, so the pass
costs a draft nothing.

One divergence, the shape the spec left open: `rederive_labels.sh`'s
`find_mirror` shares the first-match blindness over the same list
format, but its writes are labels, not mints — so it got the *rule*
rather than the retire: the oldest open match wins the label, the
first match answers as before when none is open. Retiring stays the
reconciler's alone; the row rederive labels is the row that survives.
Its `queue_file` reads an extracted tree and was untouched, as scoped.

Three integration cases pin the behaviour: task duplicates (younger
closed naming the survivor, survivor untouched, no third mint), report
duplicates the same, and the single-mirror run writing no close at
all. Full suite green; `make template-sync` run.

The ledger entry carries no token counts: this task was worked in an
isolated worktree, and the platform's usage log attributes by branch —
a branch the worktree's transcript never names — so `read_usage.sh`
proposed nothing and the entry states what is known rather than
inventing what is not.
