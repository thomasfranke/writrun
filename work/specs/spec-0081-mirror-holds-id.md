---
id: spec-0081
task_ref: task-0057
status: approved
created: 2026-09-05T13:48:48Z
---

# spec-0081 — An id the mirror holds is never minted again

**References:** [task-0057](../tasks/task-0057-id-claims-unseen.md)

- **Goal:** an id a mirror on the forge already carries is never minted
  a second time, and a run that could not ask the forge says so.

## Scope

In: `ql_next_id`'s inputs, and the pre-pass that fills them —
`ql_forge_scan`, `ql_mint_note` and `QL_FORGE_VIEW` in
`queue_lib.sh:168-282`. Both callers of that stack are in reach:
`new.sh` and `intake_report.sh`.

Out: `check_unique_ids.sh`. It could consult the mirror too, and it
should not. The mint is the writer and the check is the reader, and one
rule with two implementations is two rules that agree today
([prose](../../.writrun/conventions/prose.md)) — but the deciding
argument is cost against benefit at each end. The mint pays once, at the
moment the fix is free: pick a different number. The check pays on every
pull request, to refuse a number the mint would no longer have produced.
Where a hand-written id slips past both,
[spec-0080](spec-0080-collision-is-named.md) is what surfaces it, at the
mirror, where the damage lands.

Out: spec ids. Only tasks and reports are mirrored
([labels](../../docs/product/stage-3-github-issues/labels.md#the-report-mirror)),
so there is no fourth input for a spec to be minted above, and inventing
one would mean minting Issues nobody asked for. A spec id dropped with
its branch can therefore still be re-minted. That is the honest residue
of this fix, and it is the small half: a spec is referenced from its
task's `spec_ref`, which lives on the same branch and dies with it, so a
re-minted spec id has no public record to contradict.

Out: `ql_forge_scan`'s per-pull-request `--paginate` over the file
lists. Its cost is what it is and this change does not touch it.

**The three inputs are three views of the same two things, and neither
survived the branch.** `ql_next_id` reads the directory, then
`git log --diff-filter=A` over it, then `QL_FORGE_PATHS`
(`queue_lib.sh:253-278`). The first two are the tree and its history;
the third is a set of branches. A file minted on a branch and dropped
before that branch merged is in none of them — the working tree never
held it, no commit reachable from here added it, and the pull request
that carried it is closed. What did survive is the mirror: an Issue,
titled `[REPORT-0001] …`, that a person has read and may have linked to.
**The mirror is the only record of the id that outlives the branch, so
it is the fourth input.**

**The mirror is a projection, and consulting it is not a claim
otherwise.** The file is the authority and the Issue is its projection
([stage 3](../../docs/product/stage-3-github-issues/README.md)) — so
reading the mirror to decide *what a file says* would be backwards.
This reads it to decide something else: whether the number was ever
spent. An Issue is published. It carries the id in its title, people
link to it, and the intake even lets one become a file
([intake](../../docs/technical/reporting/intake.md#the-scripts-contract)).
A number that has been published is spent whatever became of the file,
which is the rule `an id is never reused` already states
([report](../../docs/product/concepts/report.md#statuses--the-route-not-a-lifecycle)).

**Three answers were weighed.**

- *A closed-pull-request scan* — rejected, on cost that only grows. It
  answers almost exactly what the mirror answers, by asking `gh pr list
  --state closed` and then paginating each one's file list, exactly as
  `ql_forge_scan` does for the open ones. Open pull requests are a
  working set and stay small; closed ones are the repository's whole
  history and never shrink, so a mint's cost would rise with the age of
  the project — on the path that runs at every mint. And it answers a
  weaker question: a closed pull request says the number was *proposed*,
  where the mirror says it was *published*.
- *Both* — rejected. It buys the unbounded cost above for a set the
  mirror already covers, and it gives `ql_mint_note` a matrix of partial
  views nobody reads.
- *The forge's Issues, filtered to the kit's own labels* — chosen. One
  paginated listing per kind, the same listing `mirror_issues.sh:353-365`
  already reads on every pull-request event, so the two readers agree by
  construction on what a mirror is and the project pays no new order of
  cost. The id is in the title, so `id_of_title`'s grammar answers and no
  body is parsed.

**The cost, named.** Two paginated listings per mint —
`issues?labels=writrun:task&state=all&per_page=100` and the
`writrun:report` one — against the `1 + N` calls the scan already spends
for `N` open pull requests. Both are fetched even when only one kind is
being minted, and even for a spec mint, which can use neither. That is
deliberate: `ql_next_id` runs inside a command substitution
(`new.sh:482`, `:610`, `:741`), so it cannot make forge calls without
risking a stray line landing in the id, and every forge call in this
stack belongs to the one pre-pass that already owns them
(`new.sh:87-92`). A kind argument on `ql_forge_scan` would save one
listing and add a second thing every caller must get right, silently,
where a wrong value produces exactly the reuse this spec closes.

`--paginate` means the cost scales with the repository's Issue count,
not its queue's: a project with 2,000 mirrors pays twenty calls per
listing. Asking cheaper is not available — the listing is ordered by
issue number and the id lives in the title, so the highest id is not the
newest Issue, and reading only the first page would be a guess. It is
the same bill `mirror_issues.sh` settles on every pull-request event.

**The degradation stays honest, and gains a third state.** Today
`QL_FORGE_VIEW` is `local` or `forge`, and `ql_forge_scan` returns 0
from every failure — no `gh`, a call that errored, a listing that filled
its own limit and may have been cut. Collapsing a failed mirror listing
to `local` would throw away a correct open-pull-request answer and make
the note claim less than the run knew. So the view takes three values,
and `ql_mint_note` says which of them the run had. **A listing that
succeeds and returns nothing is a complete answer, not a failure** — an
adopter below Stage 3 has no mirrors, and that is a repository with
nothing to hide rather than a question unasked.

## Steps

1. Give `ql_forge_scan` a second half, after the pull-request loop:
   one `gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100"
   --paginate` and one for `writrun:report`, each `--jq`'d to the title
   alone. Pin them to the same repository the first half used — with an
   argument, `-R`/`repos/${repo}`; without one, the checkout's own
   remote — for the reason the function's header already gives: two
   channels that disagree read one repository's numbers and another's
   answers.
2. Store the ids, not the titles: `QL_FORGE_MIRROR_IDS`, one
   `task-NNNN` or `report-NNNN` per line, parsed out of each title by
   the same leading-tag grammar the mirror writes. A title with no tag —
   a hand-labelled Issue awaiting intake — contributes nothing and is
   not an error.
3. Feed it to `ql_next_id` as a fourth pass, guarded by the prefix it
   was called with, so a `task` mint reads only `task-` ids. Reuse
   `bump` unchanged: it takes a name, strips `.md`, and reads the digits
   after the prefix, which a bare `task-0011` satisfies. **Do not
   synthesize paths** into `QL_FORGE_PATHS` — that list is filtered by
   `case "$f" in "$dir"/*)`, and `$dir` is the caller's argument, so a
   synthesized `work/tasks/…` is wrong for any adopter whose queue lives
   elsewhere.
4. Make `QL_FORGE_VIEW` three-valued: `local` (no forge answer),
   `open-pull-requests` (the file lists answered, the mirrors did not),
   `forge` (both). A mirror listing that errors sets the middle value;
   one that succeeds with no rows sets `forge`.
5. Update `ql_mint_note` to say which view the run had, in three
   shapes. Keep the substring `every open pull request` in the full
   shape and `this checkout and its history only` in the local one — two
   existing cases assert on those, and this change has no reason to move
   what they pin.
6. Say the fourth input in `ql_forge_scan`'s header, beside the
   all-or-nothing paragraph it already carries, and in `ql_next_id`'s
   own comment where the third input is introduced.
7. `make template-sync` — `.writrun/` is mirrored into `template/`.

## Acceptance criteria (EARS)

- When a mint runs and the forge answers, the system shall mint above
  every id a `writrun:task` or `writrun:report` mirror names in its
  title, whether that mirror is open or closed.
- When an id's file exists in no directory, no commit and no open pull
  request, and a closed mirror carries it, the system shall not mint
  that id.
- When a spec is minted, the system shall read the three views it reads
  today, and no mirror shall raise or lower the number.
- When a mint runs against a repository holding no mirrors, the system
  shall mint from the three views and report a complete forge view.
- When the mirror listing cannot be read but the pull-request file
  lists could, the system shall mint above the three views it had and
  report that the mirrors were not consulted.
- When `gh` is absent or unauthenticated, the system shall mint from the
  checkout and its history, exit 0, and say the forge answered nothing —
  exactly as it does today.
- When `ql_forge_scan` is given a repository, the system shall ask that
  repository for its mirrors, never the checkout's remote.
- When a mirror's title carries no id tag, the system shall ignore that
  Issue rather than fail the mint.

## Edge cases

- **A mirror whose file is on the authority branch.** The ordinary case:
  the directory already reports that id, and the fourth input agrees
  with the first. Agreement is the common outcome, not the exception.
- **A closed mirror for an id whose file was legitimately deleted.** An
  id is never reused after deletion either
  ([task](../../docs/product/concepts/task.md)), so the mirror and the
  `--diff-filter=A` history give the same answer and the mint sits above
  both.
- **An intake-born Issue not yet minted.** It carries a `writrun:report`
  label from the maintainer and no `[REPORT-NNNN]` tag until the intake
  retitles it, so it names no id and raises nothing. The intake's own
  id race is settled where it already is
  ([intake](../../docs/technical/reporting/intake.md#the-id-race-and-the-concurrency-answer))
  and this input does not change it.
- **An Issue titled by hand to look like a mirror.** It raises the
  number by whatever it spells. That is the same exposure the existing
  title-tag readers carry, and it fails toward burning an id rather than
  reusing one — the safe direction.
- **A repository with no `writrun:report` label at all.** The listing
  answers with nothing, or the forge refuses the unknown label. The
  first is a complete answer; the second is the middle view. The
  implementation must establish which the forge does and pin it in a
  case, because the two answers must not be conflated.
- **More Issues than one page.** `--paginate` is not optional, for the
  reason the file-list loop already states in its own comment.
- **A rate limit hit part way through pagination.** `gh` exits non-zero,
  the listing is discarded whole, and the view is the middle one. A
  partial listing is never folded in: a scan that under-reports without
  saying so is the failure the uniqueness rule exists to prevent.
- **`intake_report.sh` minting on the authority branch.** It gets the
  fourth input for free, and it is the caller that needs it most: it
  mints straight onto `main` with no pull-request gate behind it.

## Tests required

- The mint sits above a closed mirror whose file is in no view: the
  directory holds `report-0001`, nothing else does, a closed
  `[REPORT-0003]` mirror exists, and the mint writes `report-0004`. This
  is report-0031's sequence, stated as a case.
- The same shape for a task, so the kind guard is exercised in both
  directions: a `[TASK-0009]` mirror raises a task mint and leaves a
  spec mint where it was.
- A run with mirrors and no open pull requests: the mirror alone decides
  the number.
- A run whose mirror listing fails and whose file lists succeed: the
  number comes from the three views, exit 0, and the note names the
  narrow view. This is the middle state, and it must be pinned or a
  later refactor will collapse it back to two.
- `no_forge_mints_locally_and_says_so_test.sh` and
  `mints_above_every_open_pull_request_test.sh` pass unchanged — their
  assertions are substrings step 5 preserves, and a change to either is
  a change this spec did not intend.
- `mints_above_a_file_past_the_first_page_test.sh` passes unchanged: the
  file-list pagination is untouched.
- A wiring case that `ql_forge_scan "$REPO"` asks that repository for
  its mirrors — the pinned channel, which `intake_report.sh:133` is the
  only caller of and which no case covers today.
- `tests/pipeline_lib.sh` gains a `forge_issue`-shaped helper for
  `stub_forge`, answering the two `issues?labels=…` calls the way
  `forge_pr` answers the file lists. It is a harness addition, named
  here because the cases above cannot be written without it, and
  because `tests/mirror_lib.sh` already has a `forge_issue` and the two
  must not silently mean different things.

## Definition of Done

- [ ] `ql_next_id` reads four inputs for a task and for a report, and
      three for a spec.
- [ ] An id carried only by a closed mirror is never minted.
- [ ] `QL_FORGE_VIEW` has three values and `ql_mint_note` prints all
      three; the two pinned substrings are unmoved.
- [ ] A mirror listing that fails narrows the view and fails nothing
      else; a mirror listing that returns nothing is a full view.
- [ ] Every forge call in the minting stack is still made by
      `ql_forge_scan`, never from inside `ql_next_id`.
- [ ] `intake_report.sh` mints above the mirrors of the repository it
      was pinned to.
- [ ] Decision 0070 exists, names 0013 as the entry it extends, and the
      chronology in `decisions/README.md` carries its row.
- [ ] `make template-sync` run; `template/` matches byte for byte.
- [ ] The sequence in
      [report-0031](../reports/report-0031-id-the-mirror-holds.md) — a
      report minted on one pull request, dropped before the merge, its
      mirror still holding the id — mints a different number the second
      time.

## Proposed product changes

- none — the rule stands as written.
  `product/concepts/report.md#statuses--the-route-not-a-lifecycle` says
  ids are never reused, and
  `product/concepts/task.md` says the same for a deleted task's id. This
  change makes one more reader keep a rule already stated; writing
  "and the mirror counts" beside it would put the list of views in a
  second place, and the two would disagree the next time a view is
  added.

## Proposed technical changes

- `technical/schemas/task.md#task-schema` — the uniqueness paragraph
  names the union an id is unique across: the authority branch and every
  open pull request. The mirror joins it, with the one-line reason a
  mirror outlives the branch that made it.
- `technical/schemas/report.md#report-schema` — "the same three views"
  becomes four, and names them.
- `technical/reporting/intake.md#the-scripts-contract` — step 1 of the
  minting path says "the same three views the generator reads"; the same
  correction, and the intake's own line about the forge view being
  all-or-nothing gains the middle state.
- `technical/decisions/tasks-and-specs/0070-the-mirror-is-the-fourth-view.md`
  — the dated entry: an id is minted above the mirror, because the
  mirror is the only record of it that survives a dropped branch;
  extends [0013](../../docs/technical/decisions/tasks-and-specs/0013-new-sh-reads-git.md),
  which added the history as the second view, and rewrites nothing —
  the log is append-only. **0069 is already promised by
  [spec-0077](spec-0077-retitle-window.md), which merged unimplemented,
  so 0070 is the next free number at drafting; the implementer re-reads
  the chronology before writing, because the number is identity.**
- `technical/decisions/README.md` — the chronology gains 0070's row.
  The index is the entry's mandatory companion.

## Outcome

_(fill after execution)_
