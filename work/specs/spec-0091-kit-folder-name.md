---
id: spec-0091
task_ref: task-0065
status: approved
created: 2026-09-08T16:48:56Z
---

# spec-0091 — The kit folder takes the kit's name

**References:** [task-0065](../tasks/task-0065-layered-homes.md)

- **Goal:** the shipped folder is `kit/`, the name every doc already
  uses for it — ending the collision with `.writrun/templates/`, which
  holds actual templates.

## Scope

The rename and every live reference to the old name: the folder, the
mirror machinery, the release scripts, the tests, and the two docs
that mention the path in passing. Historical records — `decisions/`,
the CHANGELOG — keep the old name; they describe the past.

## Steps

1. `git mv template kit`.
2. Rename the machinery to match what `kit.md` now names:
   `scripts/sync_template.sh` → `scripts/sync_kit.sh`, Makefile target
   `template-sync` → `kit-sync`, `tests/template_mirrors.txt` →
   `tests/kit_mirrors.txt`, `tests/template_exceptions.txt` →
   `tests/kit_exceptions.txt`, and every path inside them.
3. Update the readers: `tests/mirror_lib.sh`, `scripts/release.sh`
   (sync call, the stamp allowlist, the abort messages),
   `tests/release_lib.sh`, the release-readiness workflow's heal step,
   and the integration/e2e suites under `tests/` that spell either old
   name (`tests/integration/sync_template/` → `sync_kit/`, the release
   tests' fixtures and assertions).
4. Update the kit's own surfaces that name the folder:
   `.writrun/scripts/stage-2-pull-requests/check_promise_paths.sh`
   (the resolvable roots), `.writrun/README.md`, `README.md`,
   `CONTRIBUTING.md`.
5. Close the loop on the two docs that mention the path outside
   `distribution/kit.md`: the architecture table's kit row, and the
   promise-path roots in the front-matter schema.

## Acceptance criteria (EARS)

- When the repository is searched for `template/` outside `decisions/`,
  the CHANGELOG and git history, no live reference shall remain.
- When `make kit-sync` runs, the mirror shall land under `kit/` and
  the suite shall pass unchanged in count.
- When `release.sh` runs on a tree whose kit folder is stale, it shall
  heal it via the sync and abort on any drift beyond the version
  stamp, exactly as before under the old name.
- When a spec promises a path under `kit/`, `check_promise_paths.sh`
  shall resolve it as it resolved `template/` paths before.

## Edge cases

- An adopter pinning an old tag still copies `template/` from that
  tag; nothing about the rename reaches published tags. The next tag
  ships `kit/`, and the guide inside it names itself correctly.
- The release-readiness self-heal commits a sync diff; its pathspec
  must be the new folder or the heal silently stops healing.

## Tests required

The existing sync, release and readiness suites, renamed with the
machinery and green; no new cases — the rename changes no behaviour.

## Definition of Done

- [ ] `kit/` is the folder, `kit-sync` the target, `kit_mirrors.txt`
      and `kit_exceptions.txt` the lists, and the suite is green.
- [ ] No live `template/` reference outside historical records.

## Proposed product changes

- none — `product/` never names the folder.

## Proposed technical changes

- `technical/architecture.md` — the kit row of the reader's table
  names `kit/`.
- `technical/schemas/front-matter.md` — the promise-path roots name
  `kit/` where they named `template/`.

## Outcome

_(fill after execution)_
