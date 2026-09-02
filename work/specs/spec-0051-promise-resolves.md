---
id: spec-0051
task_ref: task-0035
status: draft
created: 2026-09-02T18:52:55Z
---

# spec-0051 — A promise whose path cannot resolve is refused where the spec enters

**References:** [task-0035](../tasks/task-0035-promise-resolves.md)

- **Goal:** a spec promising a repository-root path — one that
  normalises to a `docs/…` path no diff will ever touch — is refused at
  the pull request that creates or amends it, so the defect that reached
  `spec-0041` and `spec-0044` is caught where fixing it is one edit
  instead of an amendment under a finished branch.

## Scope

In: the check, run by `writrun check` against the specs the range adds
or modifies; its fixture tests; the template mirror; the decision that
records why shape is the test.

**Shape, never existence.** A spec legitimately promises a doc its own
change will create, so "does the file exist today" is not askable here —
at spec entry the promised doc is precisely what has not been written
yet. What *is* askable is whether the path is a documentation path at
all. Two conditions, both certain and both read off the repository
rather than a table:

- **Root-relative.** The path's first segment names an entry at the
  repository root for which `docs/` holds no counterpart. `tests/`,
  `template/`, `.github/`, `.writrun/` and a leading `docs/` are all
  caught this way; `product/` and `technical/` are not root entries, so
  a promise into them passes whether or not the file exists yet.
- **Not a document.** The path ends in neither `.md` nor `/` — a folder
  promise being the trailing-slash form `check_deltas.sh` already reads.

Out: `writrun-check-spec-deltas`, which stays the completion gate — this
check exists so that one fires less, not differently. Out: teaching
either check to pass repository-root paths through, which
[report-0005](../reports/report-0005-delta-doc-paths.md)'s triage
already rejected — the sections close the loop on permanent docs, and a
promise of `tests/` is one the loop has no use for. Out: `new.sh`'s
templates, on spec-0038's reasoning — a nudge can follow as trivial work
if the refusal proves not to be enough.

## Steps

1. `check_promise_paths.sh`: for each spec the range adds or modifies,
   parse both Proposed-changes sections, strip anchors as
   `extract_paths` does, and fail on either condition above — naming the
   spec, the bullet as written, and the `docs/…` form it was read as.
2. Wire it into `writrun-check.yml` **before** the companions check: a
   path that is not a document path cannot meaningfully be asked whether
   its companion is present, so shape is judged before relations.
3. Decision `0065`, under `pull-requests` — why the test is shape and
   not existence — and its chronology row.
4. `make template-sync`; tests.

## Acceptance criteria (EARS)

- When a changed spec promises a path whose first segment names a
  repository-root entry that `docs/` holds no counterpart for, the check
  shall exit non-zero naming the spec, the path, and the `docs/…` form
  it was read as.
- When a changed spec promises a path ending in neither `.md` nor `/`,
  the check shall exit non-zero naming it.
- When a changed spec promises a path under `docs/`'s own top level, the
  check shall pass — including one whose file does not exist yet.
- When a Proposed-changes section reads "none", the check shall not fire
  on it.
- When a spec carrying an offending path sits on the base branch and the
  range does not touch it, the check shall not fire.
- When the range is missing or unreadable, the check shall exit 3 —
  never the code it uses for a refused promise.

## Edge cases

- **A doc the change itself creates**: passes, because existence is
  never read. This is the case that rules existence out as the test.
- **A `docs/` top level that collides with a root name** — a project
  holding both `docs/tests/` and `tests/`: the documentation reading
  wins, since refusal requires that `docs/<first-segment>` *not* exist.
- **A promise into a docs area that neither exists yet nor has a root
  counterpart**: passes on the first condition, and the second still
  holds it to `.md` or `/`.
- **A promise into a docs area that does not exist yet and collides with
  a root name**: refused, and wrongly. Vanishing case, one edit to fix,
  and the refusal prints the reading it took so the author sees why.
- **A spec already on the base branch with an offending path**: out of
  reach — the check reads the range and history is not re-judged, the
  same boundary the companions check draws. The completion gate still
  holds it, which is how `spec-0044`'s five were going to surface.
- **A bullet path containing a space**: parsed as the companions check
  parses it; the existing fixture shape carries over.

## Tests required

A fixture reproducing `spec-0044`'s five real paths, each refused and
each naming its `docs/…` reading; a promise naming a not-yet-existing
`product/` doc, passing; a non-`.md`, non-folder path refused; "none"
ignored; an offending spec on the base branch the range does not touch,
ignored; an unreadable range and a missing argument, both exit 3. Mirror
test.

## Definition of Done

- [ ] Every acceptance criterion holds, each with a test.
- [ ] The five paths from `spec-0044` are refused by the fixture.
- [ ] The check runs before the companions check in the workflow.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the rule is already carried by
  `product/concepts/spec.md#the-doc-delta-contract` (a promise is
  refused where the spec enters) and by the `docs/`-relative path
  convention in the spec schema; this change builds the refusal they
  state.

## Proposed technical changes

- `technical/decisions/pull-requests/0065-a-promise-is-judged-by-shape.md` —
  new dated entry: why the test is the path's shape and never the file's
  existence, and what that deliberately leaves to the completion gate.
- `technical/decisions/README.md` — the chronology row for 0065.

## Outcome

_(fill after execution)_
