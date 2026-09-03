---
id: spec-0055
task_ref: task-0039
status: approved
created: 2026-09-03T03:32:34Z
---

# spec-0055 — The kit carries the report concept it ships the machinery for

**References:** [task-0039](../tasks/task-0039-kit-carries-reports.md)

- **Goal:** an adopter who copies `template/` is told, in the files they
  read, that reports exist — the folder, the four routes, and which of
  them may ride another change — so the cheapest entry the methodology
  has stops being the one the kit hides.

## Scope

In: the kit's hand-maintained prose (`template/work/README.md`, a new
`template/work/reports/README.md`, `template/AGENTS.md`,
`template/WRITRUN.md`); the mirrored `.writrun/README.md` counts and the
root `README.md` skills row; two structural tests; the two permanent
docs the change closes the loop on.

**The kit ships `work/reports/`.** That is the maintainer's call, taken
at triage over the alternative of naming the folder as one the first
report creates. A folder that exists is a folder an agent finds, and the
generator writes into it either way.

Out: `check_doc_shapes.sh` learning to read for absence. It already
judges the kit's words and shapes, and it cannot judge a silence — a
concept the prose never mentions uses no retired word and shows no
wrong shape. The guard this change does build is structural instead:
what the kit *ships* is compared against what its prose *names*, which
is the same drift caught from the side that has a signature.

Out: a dated decision entry. What was decided is on `report-0012`'s
triage and in this spec; the machinery gained no choice a future reader
would have to reconstruct.

## Steps

1. `template/work/reports/README.md` — new, the kit's shape of the
   root's own: what a report is for, that nothing selects one, and the
   four ends. `template/work/README.md` gains the third row and the
   framing that the queue also holds what was noticed.
2. `template/AGENTS.md` — a reporting section inside the
   `writrun:begin`/`end` markers: `new.sh report` records an
   observation; triage's four ends and that `fixed` and `declined` are
   the agent's; recording and the three ends that create no work ride
   any change; the `tracked` route takes a `report/` branch of its own
   and the merge of that pull request is the assent.
3. `template/WRITRUN.md` — the mid-flight clause stops describing a
   `report/` PR that adds "only task + spec"; the structure table names
   `work/reports/`.
4. `.writrun/README.md` — `skills/` says five, `templates/` names the
   report shape beside task and spec; root `README.md`'s skills row
   gains `writrun-check-front-matter`. `make template-sync` carries the
   first to the kit.
5. Two tests, under `tests/unit/template/`: every directory the kit
   ships under `template/work/` is named in `template/work/README.md`,
   and every skill directory under `template/.writrun/skills/` is named
   in `.writrun/README.md`.
6. The loop on the two docs the change makes untrue in part:
   `technical/distribution.md#distribution` names `work/` with its three
   folders, and `product/adoption.md#stage-1--the-minimum-bar` says that
   the kit shipping the folder leaves the minimum where it was.

## Acceptance criteria (EARS)

- When the kit is copied, `template/work/reports/` shall be present with
  its README, and `template/work/README.md` shall name it.
- When an agent reads `template/AGENTS.md`, it shall find the four
  triage ends, the rule that recording rides any change, and the rule
  that the `tracked` route does not.
- When `template/work/` gains a directory that `template/work/README.md`
  does not name, the suite shall fail naming it.
- When `template/.writrun/skills/` holds a skill `.writrun/README.md`
  does not name, the suite shall fail naming it.
- When `make template-sync` runs after the `.writrun/README.md` edit,
  the mirror test shall pass with no further edit.
- When the completing diff is checked, `writrun-check-spec-deltas` shall
  exit 0 against the two promised docs and no other permanent doc.

## Edge cases

- **`work/reports/` shipped against a minimum that does not require
  it.** Not a contradiction and the docs say so after step 6: the
  minimum is what a project must have to claim adoption, the kit is what
  a copy starts with. An adopter deleting the folder is still an
  adopter.
- **The kit's README is not the root's.** `template/work/README.md`
  describes a queue with no history in it; copying the root's file whole
  would hand an adopter this repository's own reports as if they were
  theirs.
- **`.writrun/README.md` is mirrored.** Editing the kit's copy directly
  is the one edit `make template-sync` undoes; the root file is the
  writer, always.
- **A skill directory that is not a skill** — a scratch folder under
  `skills/` would fail the second test. That is the test working: the
  kit ships what the folder holds.
- **The prose test reads names, not meaning.** A README naming
  `reports/` in a sentence that says nothing about it passes. The test
  guards the drift that has a signature; the review guards the rest.

## Tests required

The two structural tests of step 5, each with a failing fixture: a
`template/work/` directory absent from the README, and a skill directory
absent from `.writrun/README.md`. The existing mirror test covers the
sync. Suite green.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] `template/work/reports/README.md` ships and is named by its parent.
- [ ] `template/AGENTS.md` carries the reporting flow, markers intact.
- [ ] Template synced; suite green; deltas exit 0.

## Proposed product changes

- `product/adoption.md#stage-1--the-minimum-bar` — the kit ships
  `work/reports/`; the minimum is unchanged and its absence is still
  never a gap.

## Proposed technical changes

- `technical/distribution.md#distribution` — the kit-ships list names
  `work/`'s three folders, and the paragraph on the kit's prose gains
  what the two structural tests now hold.

## Outcome

_(fill after execution)_
