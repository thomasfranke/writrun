# Checks

**How the gate scripts are called** — the rules that belong to the caller, where a wrong call passes. One chapter of [`distribution/`](README.md).

## Running the checks

Three of the skills are gates, and five rules about *how* they are
called belong to the caller rather than to any script — a wrong call
passes, which is why they are stated here and not left to whoever
remembers.

**`check_front_matter.sh` takes all four directories or none.** It
defaults to `work/tasks`, `work/specs`, `docs` and `work/reports`, and a
project whose queue lives elsewhere must name every one. Naming only the
first two leaves `work/reports` resolved against the working directory,
finds nothing there, and reports success over the reports it never read —
and hand-edited reports are exactly what the check exists for, since
three of triage's four ends are written by hand. A report directory that
is not there is zero reports and still exit 0: an adopter who has never
recorded one has a complete state, not a broken checkout.

**`check_deltas.sh` reads a multi-spec change in one call, never one
spec at a time.** A change completing a multi-spec task passes the ids
comma-separated: MISSING is judged per spec, so each contract must be
honoured in full and the report names whose promise went unmet, while
UNDECLARED is judged against the **union** of their promises. Run one
spec at a time against the same diff and every sibling's promised docs
come back as undeclared for the other — a red result the change did not
earn, and the fastest way to teach a reader to ignore the check.

**Neither result is resolved by editing the promise to match the diff.**
MISSING is either a forgotten doc update or a promise that was wrong, and
UNDECLARED is either an incomplete Proposed-changes section or a change
that touched what it should not have; both are surfaced and decided,
never papered over. A spec is marked `implemented`, and a task's
`completed` date written, on exit 0 and on nothing else.

**A `PR_*` name carries pull-request event data, set by the workflow
step that calls the script.** `PR_HEAD_REF`, `PR_TITLE`, `PR_AUTHOR`,
`PR_DRAFT`, `PR_MERGED`, `PR_NUMBER`, `PR_TITLE_FROM` and `PR_STATE` reach
`apply_pr_event.sh` and its siblings that way. A script an agent also runs locally reads the
bare name:
`check_state.sh` reads `HEAD_REF`, because outside CI there is no pull
request for the prefix to be true about. Copying one workflow's `env:`
block into another's step therefore sets a name the callee never reads,
and neither direction is loud. `check_state.sh` falls back to the
checkout's own branch name, so it announces the skip only when *that* is
unreadable too — and the announcement is of **half** a rule standing
down, not the whole one: rule K's diff half needs no name and runs
anyway, so a change carrying code is still refused past that line. What
the skip costs is the name check, which on an attached HEAD is worse
than absent — it judges rule K against whatever the runner happens to
sit on, and a `main` or `pr-NNN` checkout reads a `work/`-only
`tracked` flip as legitimate. `apply_pr_event.sh` has no fallback
to reach for: with neither `PR_HEAD_REF` nor `PR_TITLE` set it exits 0
printing `head '' and title '' carry no task — nothing to record`, the
line every pull request carrying no task legitimately prints, so a
miswired `writrun-progress.yml` stops recording the task lifecycle and
looks ordinary doing it. Two names rather than one is a wider way to be
miswired, not a narrower one: the step goes quiet if *either* is copied
wrong, and says the same ordinary thing. An empty `PR_NUMBER` is
quieter still, and costs more. The close arm drops the closing pull
request's own row from the open listing by matching that number, so
with none set the drop is a no-op and the pull request finds *itself*
surviving — and on a listing that still shows it open it then claims
every task its title carries, not only the one its head branch spells
([spec-0068](../../../work/specs/spec-0068-survivor-every-route.md)).

**`PR_TITLE_FROM` is the whole test for a body-only edit.** The
`edited` event fires on body and base changes as well as titles, and
only a title change carries a claim. The forge sets
`github.event.changes.title.from` on exactly the edits that moved the
title, so the recorder stands down on an empty one without reading a
file or calling the forge. A step that omits the name makes every
`edited` event look like a body edit, and the retitle it was added for
goes unrecorded — silently, and green
([spec-0077](../../../work/specs/spec-0077-retitle-window.md)).

**`check_state.sh` gets the pull request body, or one of its rules
cannot run.** The owed-spec rule asks whether the change declares that a
task warrants no spec, and that declaration lives in the body — nowhere
in the diff can answer it, because an empty `spec_ref` means both "owed"
and "never needed"
([statuses](../../product/stage-2-pull-requests/statuses.md#criteria)).
A step that omits `PR_BODY` leaves the half standing down and the task
unjudged; the run still exits 0, so the omission costs a rule and
nothing tells the maintainer except the stand-down line. The trigger
list is part of the same obligation: the declaration is written by
editing the body, so a workflow that does not run on `edited` reads the
body as it was before the reviewer asked for the line.

