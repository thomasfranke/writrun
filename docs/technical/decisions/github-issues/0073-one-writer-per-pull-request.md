# one writer per pull request, and a reconciler that retires duplicates.

**2026-09-06**

The forge-writing workflows serialize per pull request through
`concurrency` groups: `writrun-issues.yml` and `writrun-approve.yml`
share `writrun-mirror-<pr>` because they write the same mirrors, and
`writrun-progress.yml` holds `writrun-progress-<pr>` of its own because
its writes — the status line and the labels projected from it — are a
different artifact that converges by re-derivation.
`writrun-intake.yml` had already drawn this conclusion for issue
events; this entry extends it to the pull request's.

The incident is
[report-0038](../../../../work/reports/report-0038-mirror-race.md): a
push and the `gh pr ready` one second behind it — a routine agent flow
— ran the mirror pass twice concurrently. Each run searched the issue
list, neither saw the other's mint, and one record got two mirrors
(#234, #235). The merge's own pass then adopted the younger and the
elder stood open, `status:proposed`, pinned to a head SHA forever:
nothing downstream ever retired a duplicate, because every lookup took
its first match and stopped.

**Queue, never cancel.** Every serialized pass is a reconciler, so the
run that waits reconciles the newest state anyway — a superseded event
loses nothing. Rejected: `cancel-in-progress: true` — a reconciler
cancelled mid-write can die between two writes it meant as one (a
mirror minted, its label never derived; a status recorded, its
projection never run), and the half-written state looks exactly like
the corruption these passes exist to prevent.

**The group is half the answer.** It serializes one pull request's own
events; duplicates minted across pull requests, or standing from
before the group existed, are met in `mirror_issues.sh` itself, which
now sees every open mirror for an id, keeps the oldest — the one
references had the longest to accumulate — and closes the rest naming
the survivor. `rederive_labels.sh` labels by the same rule (oldest
open match), so the row it labels is the row that survives.
