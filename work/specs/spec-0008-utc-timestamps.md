---
id: spec-0008
task_ref: task-0011
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0008 — Record queue dates as UTC timestamps

**References:** [task-0011](../tasks/task-0011-utc-timestamps.md)

## Scope

Every date field in a task or spec becomes an RFC 3339 UTC timestamp
spelled with `Z`, in the generator, in the canonical check, and in every
file already in the queue.

In scope: `new.sh` (`created` on both subcommands),
`check_front_matter.sh` (`check_date`), and a one-time migration of the
queue. Out of scope: which fields exist and who writes them — this
changes the *shape* of a date, not the meaning of any field. Anything a
concurrent change adds must be written in the new shape from the start
rather than migrated twice.

## Steps

1. `new.sh`: stamp `date -u +%Y-%m-%dT%H:%M:%SZ`. Not `date +%s` piped
   through anything, and not local time — the `-u` is the whole point.
2. `check_front_matter.sh`: `check_date` accepts
   `YYYY-MM-DDTHH:MM:SSZ` and rejects a bare date, a local time, and an
   offset form such as `+02:00`. Rejecting the offset is deliberate: it
   would order wrongly under a lexicographic sort.
3. Migrate every task and spec in `work/`, widening each existing date to
   `T00:00:00Z`. The hour is a normalization, not a claim — see the
   decision entry — so it is applied uniformly rather than guessed at
   per file.
4. Check the suite's own fixtures: `pipeline_lib.sh` and `mirror_lib.sh`
   write dates into generated task and spec files, and every one of them
   has to move too or the fixtures stop being canonical.

## Acceptance criteria

- When `new.sh` generates a task or spec, `created` shall be a UTC
  timestamp ending in `Z`.
- When a queue file holds a bare `YYYY-MM-DD` date,
  `check_front_matter.sh` shall report it malformed.
- When a queue file holds a timestamp with an offset instead of `Z`, the
  system shall report it malformed.
- When a queue file holds `null` in a nullable date field, the system
  shall accept it.
- When this change lands, every file in `work/` shall carry timestamps
  and the queue shall pass its own check.

## Edge cases

- A nullable field (`completed`) stays `null` — nullability is unchanged.
- A field with a valid timestamp and trailing whitespace: already
  rejected by the canonical shape check, and must stay rejected.
- Leap seconds and `T24:00:00Z` are not accepted; the format is the
  narrow one the generator writes.

## Tests required

One case per acceptance criterion, in the `front_matter` and `new`
suites.

## Definition of Done

- `make tests` green, including the new cases and the migrated fixtures.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated the rule in
`product/pipeline.md#criteria` first.

## Proposed technical changes

none — the same authoring change covered the schema and the canonical
form in `technical/README.md`.

## Outcome

Built as planned, all four steps. The suite went from 169 to 176 case
files.

Step 4 earned its place: `pipeline_lib.sh` and `mirror_lib.sh` write
`created` into every generated task and spec, and had they stayed on
bare dates the fixtures would have kept passing while testing the old
contract — a whole suite quietly grading the wrong shape.

Three notes, one of them a divergence:

- **The existing `bad_date_rejected_test.sh` was tightened, not left
  alone.** It asserted the message contained `YYYY-MM-DD`, which is a
  *substring* of the new `YYYY-MM-DDTHH:MM:SSZ` — so it passed against
  both the old code and the new, discriminating nothing. It now asserts
  the full expected shape. Worth recording because the case looked green
  throughout and was the one case that had stopped meaning anything.

- **Criterion 5 got a case that reads this repository, not a fixture.**
  Every other case builds a temp queue; "every file in `work/` carries
  timestamps" is a claim about the real tree, so
  `repository_queue_is_canonical_test.sh` runs the check against
  `REPO_ROOT` and additionally asserts that no file is left holding a
  bare date. CI already runs the same check on the repository, but the
  suite is where the claim belongs when a spec makes it.

- **`completed` on this task is a real time, not `T00:00:00Z`.** The
  migration normalized files whose precision was never recorded; a field
  written now knows the hour, and writing midnight would discard a fact
  the decision entry only accepted losing where it was already lost.

- **Three approved specs were returned to `draft`, which no step
  foresaw.** Step 3 says "migrate every task and spec in `work/`", and
  three of them — `spec-0006`, `spec-0007`, `spec-0009` — were
  `approved`. Widening their `created` field edits a body under an
  approval, which `check_recorded_approvals.sh` forbids, and it caught
  this on the pull request rather than after the merge.

  The guard's own escape hatch is an approving review, and this
  repository cannot use it: its pull requests are authored by the
  maintainer, whom the forge will not let approve their own
  (`AGENTS.md`). So the only path is the documented one — the amendment
  goes through `draft`, and the merge that carries it is the assent
  (`product/pipeline.md#a-spec-changes-after-its-approval`).
  `flip_approved_specs.sh` already flips a re-drafted amendment back, so
  the three return to `approved` on the merge with no further action.

  Recording it because the instinct was to argue the guard was too
  blunt — a date widening changes no meaning a human assented to. It is
  blunt, and it is right to be: a diff cannot tell a normalization from
  an edit, and the flow it forces costs one automated flip. A spec that
  migrates the shape of every queue file should say this step out loud;
  this one did not.

Not done here, and deliberately: `queued` and `merged` do not exist yet
(task-0009), and `spec-0006` still specifies them as `YYYY-MM-DD`. That
spec is stale against the schema and must be amended through `draft`
before task-0009 is implemented — which is this spec's Scope talking
("anything a concurrent change adds must be written in the new shape from
the start rather than migrated twice"), now with the ground prepared for
it.
