---
id: spec-0008
task_ref: task-0011
status: draft
created: 2026-08-28
---

# spec-0008 — Record queue dates as UTC timestamps

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

(filled when the task completes)
