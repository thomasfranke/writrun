---
id: spec-0065
task_ref: task-0046
status: implemented
created: 2026-09-04T15:22:26Z
---

# spec-0065 — The mirror lookup refreshes instead of trusting one snapshot

**References:** [task-0046](../tasks/task-0046-rederive-snapshot.md)

- **Goal:** a mirror minted seconds before the label pass runs is
  labelled by it, and an id that job minted can never be reported
  missing in silence.

## Scope

In: how `rederive_labels.sh` resolves an id to its mirror, and what it
does when the resolution fails.

Out: `mirror_issues.sh` and the minting itself. It wrote the mirrors
correctly, with `writrun:task` and `origin:` landing on all of them —
only the projection ran early.

Out: repairing the six mirrors already drifted on `writrun-cli`
(#11–#16). They are another repository's, their queue files are correct,
and a `rederive_labels.sh` run there fixes them once this ships. Naming
the repair as work here would put another project's state in this
queue.

Out: the rebase-merge divergence the existing comment in
`writrun-approve.yml` guards. Same outcome, different cause, and its
guard stays as written.

**Why the read is retried rather than replaced.** Three approaches were
weighed:

- *A lookup per id* — rejected. It trades one read for N on every merge
  and it does not follow that a per-id read is fresher; the list is
  eventually consistent either way. The single fetch was a deliberate
  design and the fault is its timing, not its shape.
- *Thread the mint's Issue numbers through* — rejected as the primary
  fix. `mirror_issues.sh` knows the numbers it just created, so this
  removes the lookup for freshly minted ids — but only for those. The
  same stale snapshot answers the `scope` ids beside them, so the class
  of failure survives, and the mint's output becomes a second source of
  truth for a number the forge already owns.
- *Refresh the snapshot when an id misses* — chosen. It targets the
  cause: a read that landed before the writes it must see. One re-fetch
  serves every id still unresolved, so the cost is bounded by staleness
  actually observed rather than paid per merge.

## Steps

1. Split the fetch out of the assignment at
   `rederive_labels.sh:145` so the list can be re-read into the same
   variable, and do the same for the report list.
2. On a lookup miss, re-fetch once and retry the id against the fresh
   list. Bound the retries and space them — the observed gap between the
   create and the stale read was about four seconds.
3. Mark the ids this job minted. The workflow already passes them from
   a separate step (`steps.mint.outputs.tasks`,
   `steps.mint.outputs.reports`); pass them behind a flag so the script
   can tell a minted id from a `scope` id.
4. Make an unresolved *minted* id exit non-zero after the retries, with
   a message naming the id and the mirror it should have had. An
   unresolved `scope` id stays the notice it is today — a task whose
   mirror genuinely does not exist is a finding, not a fault.
5. `make template-sync` — `.writrun/` and `.github/workflows/` are
   mirrored into `template/`.
6. Update the comment in `writrun-approve.yml` that names
   minted-and-never-labelled: it guards one path to that outcome and
   this is a second one.

## Acceptance criteria (EARS)

- When a lookup finds no mirror for an id, the system shall re-fetch the
  mirror list and retry that id before reporting it missing.
- When the re-fetch resolves the id, the system shall label it exactly
  as a first-pass hit, and shall answer every still-unresolved id in the
  run from the refreshed list.
- When an id the same job minted stays unresolved after the retries, the
  system shall exit non-zero naming that id.
- When an id the job did not mint stays unresolved, the system shall
  report it missing and leave the exit code unmoved.

## Edge cases

- **Every id resolves on the first pass.** No re-fetch happens; the
  common path pays nothing.
- **A mirror that genuinely does not exist**, on a task passed in
  `scope` whose mirror was never minted. Reached only after the retries,
  and still a notice.
- **The re-fetch itself fails** — no network, a rate limit. Treated as an
  unresolved id, so a minted one still fails the step rather than
  passing quietly.
- **A repository with more than 100 mirrors.** Both reads already
  `--paginate`; the refresh must keep it.
- **`writrun:report` mirrors** take the same path, and their list is
  fetched lazily. The refresh must not force that fetch where no report
  was named.

## Tests required

- A unit case with a stubbed `gh` whose first list omits an id and whose
  second contains it: the id is labelled, and the stub records exactly
  two list calls.
- A unit case where a minted id is absent from every list: exit
  non-zero, and the id is named.
- A unit case where a non-minted id is absent from every list: the
  notice is printed and the exit code stays 0.
- A unit case where all ids resolve first time: the stub records one
  list call.

## Definition of Done

- [ ] The lookup refreshes on a miss, bounded, for tasks and reports.
- [ ] A minted id that stays unresolved fails the step.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] `writrun-approve.yml`'s comment names both paths to
      minted-and-never-labelled.
- [ ] The sequence in
      [report-0021](../reports/report-0021-rederive-labels-sh.md) —
      fourteen mirrors minted, the label pass invoked milliseconds later
      — labels all fourteen.

## Proposed product changes

- none — the rule already stands.
  `product/stage-3-github-issues/labels.md#criteria` requires the
  machinery to re-label a task's mirror from the queue as it then
  stands. This spec makes the script keep it.

## Proposed technical changes

- none — no technical chapter describes this pass. `distribution/`
  covers the kit, the checks and the release; the label pass is
  documented where it runs, in `writrun-approve.yml`'s own comment, and
  that comment is machinery this change updates rather than a permanent
  doc. The rule the script must keep is
  `product/stage-3-github-issues/labels.md#criteria` and it already
  stands; restating it beside the script is the second copy that
  disagrees later.

## Outcome

Built as planned, all six steps. `rederive_labels.sh` reads its list
through one `fetch_mirrors <label>` helper — the two reads differed only
in the label, so splitting the fetch out of the assignment split it out
of both — and a miss now goes through `resolve_mirror`, which re-reads
and retries before it concludes. `--minted` marks the ids the mint
answered for; an unresolved one prints to stderr, naming the id and the
`[TASK-NNNN]` mirror it should have had, and exits 1. An unresolved id
nobody minted prints the notice it always did. `writrun-approve.yml`
passes the mint's two outputs behind the flag, and its comment now names
both paths to minted-and-never-labelled: the rebase divergence it always
guarded, and the read that lands before the writes it must see.

Five decisions the spec left to the build.

The retry budget is the run's, not each id's: two re-reads per list, each
preceded by a wait. The Scope's reasoning — one re-fetch serves every id
still unresolved — is only true if the budget is shared, and a run whose
six latecomers each spent their own would pay six re-reads and thirty-six
seconds for one moment of staleness.

The wait is three seconds and `WRITRUN_MIRROR_REFRESH_WAIT` overrides it.
The suite must not spend the seconds the real thing spaces its retries
with, and `read_usage.sh` and `take_task.sh` already reach into a run
this way.

The non-zero exit is deferred to the end of the run rather than taken at
the miss. One mirror this pass cannot find is no reason to leave the rest
of the ids unlabelled, and the step fails either way.

The argument that means "nothing to do" had to be re-read. The flag is
always passed now, so a merge that recorded nothing arrives with
`--minted` and two empty outputs behind it — an argument count of one,
where the old check saw zero and returned before touching the forge.
The check counts ids and not arguments, and the case that says most
merges pay nothing says it again with the flag present.

The minted set is collected in a pre-pass over the arguments rather than
read as the loop walks past the flag. The same id arrives twice — once
from the commit range, once from the mint — and the loop labels it on the
first arrival, so a scope-first ordering would have made every real miss
a notice and the flag would have marked nothing.

The fixture grew two pieces to test any of it: `forge_relists` in
`tests/mirror_lib.sh`, which makes the fake forge answer a later read
with rows the earlier one could not see, and `forge_told_times` in
`tests/harness.sh`, for the cases whose subject is how many reads a run
costs. Both sit beside their neighbours and neither is mirrored — `tests/`
is not in `tests/template_mirrors.txt`. The four cases the spec named are
there, plus the report list taking the same path, and plus the report's
own sequence replayed: fourteen mirrors minted, eight of them in the
first read, all fourteen labelled and one re-read between the six
latecomers.
