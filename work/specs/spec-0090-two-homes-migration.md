---
id: spec-0090
task_ref: task-0064
status: draft
created: 2026-09-07T03:49:10Z
---

# spec-0090 — The two homes — settings, gates and conventions leave .writrun/

**References:** [task-0064](../tasks/task-0064-two-homes.md)

- **Goal:** every file under `.writrun/` is the kit's and every adopter
  answer lives under `writrun/`, per
  [Two homes](../../docs/product/adoption.md#two-homes) — so an update
  replaces one folder entire, a removal deletes it, and no script, doc
  or workflow names an adopter file at a kit address.

## Scope

- Move `settings.json`, `gates.md` and `conventions/` from `.writrun/`
  to a new `writrun/` at the repository root — in this repository and
  in `template/`, where the seed the kit ships lives.
- Repoint every reader of the old addresses: the stage-1 and stage-2
  scripts, `new.sh`, the approve workflow, and the prose in
  `.writrun/AGENTS.md`, `.writrun/README.md`, `WRITRUN.md` and the
  seeded `docs/` files.
- Update the permanent docs that state the addresses (listed below),
  and append the decision that supersedes
  [0053](../../docs/technical/decisions/tasks-and-specs/0053-settings-at-the-root.md)'s
  address choice.
- Out of scope: `writ` (the CLI) — it implements `update`/`remove`
  against the contract this change writes; its work is its own
  repository's.

## Steps

1. Create `writrun/` at the root; `git mv` `settings.json`, `gates.md`
   and `conventions/` (with `conventions/templates/` overrides intact)
   out of `.writrun/`. Fix the relative links inside the moved files.
2. Repoint the readers: `read_setting.sh`, `check_settings.sh`,
   `session_card.sh`, `commit_subject.sh`, `stage_gate.sh`, `new.sh`,
   `.github/workflows/writrun-approve.yml`.
3. Update the kit's prose: `.writrun/AGENTS.md` (settings and gates
   sections), `.writrun/README.md` (per-file ownership table goes —
   ownership is now the folder), `template/WRITRUN.md` ("What you
   decide", "What lives where", adopting steps),
   `template/docs/writrun-instructions.md` and
   `template/docs/technical/README.md` where they name addresses.
4. Mirror: seed `template/writrun/` (cautious `settings.json`,
   `gates.md` skeleton, default `conventions/`), update
   `tests/template_mirrors.txt`, run `make template-sync`.
5. Update the permanent docs in Proposed changes; append the new
   decision entry to `docs/technical/decisions/tasks-and-specs/`.
6. Run the suite; grep guard: no live file names
   `.writrun/settings.json`, `.writrun/gates.md` or
   `.writrun/conventions` — dated decision entries excepted, they are
   history.

## Acceptance criteria (EARS)

- When a fresh copy of `template/` lands in a project, the adopter's
  `settings.json`, `gates.md` and `conventions/` shall live under
  `writrun/`, and `.writrun/` shall hold no adopter-owned file.
- When a kit script or workflow reads a setting or a gate, it shall
  read it from `writrun/`, never from `.writrun/`.
- When an update replaces `.writrun/`, `WRITRUN.md` and the
  `writrun-`-prefixed files under `.github/`, nothing under `writrun/`
  and no seeded file shall change.
- When the kit is removed by the three deletions the rule names, no
  kit-owned file shall remain, and `writrun/`, `work/`, `docs/` and
  every seeded file shall stand untouched.
- When this repository's own session card runs, it shall report the
  values from `writrun/settings.json` — the dogfooding move rides this
  same change.

## Edge cases

- **A project on the old layout.** `.writrun/settings.json` exists,
  `writrun/` does not. The contract doc states the migration — the
  update moves the three adopter files once, then never touches
  `writrun/` again — so `writ update` has one written behaviour to
  implement, not a guess.
- **Both addresses present.** The new address wins and the old one is
  reported, never silently merged.
- **Dated decisions name the old paths.** Entries 0020, 0024, 0052,
  0053, 0054 and 0063 stay byte-identical — they are history, and the
  new decision entry is what supersedes them.
- **The pull request body template.** `.writrun/templates/` is the
  kit's and stays; only the adopter's override location moves with
  `conventions/`.

## Tests required

- Suite stays green; every test naming the old addresses moves with
  them.
- The mirror test covers the moved files at their new addresses
  (`tests/template_mirrors.txt` updated).
- A guard that fails when a live kit file names an adopter file at the
  old `.writrun/` address.

## Definition of Done

- [ ] `writrun/` exists here and in `template/`; the three adopter
      files live only there.
- [ ] Every script, workflow, skill and seeded doc names the new
      addresses; grep for the old ones hits only dated decisions.
- [ ] `tests/template_mirrors.txt` and the mirror are in sync; suite
      green.
- [ ] The permanent docs below are updated in this same change.
- [ ] The superseding decision entry is appended.

## Proposed product changes

- `docs/product/concepts/spec.md` — the settings address it names moves
  to `writrun/settings.json`.
- `docs/product/stage-1-tasks-and-specs/gates.md` — the gates file's
  address moves to `writrun/gates.md`.
- `docs/product/stage-2-pull-requests/README.md` — same repoint where
  it names the settings file.
- `docs/product/stage-2-pull-requests/body.md` — the template override
  address moves with `conventions/`.

## Proposed technical changes

- `docs/technical/architecture.md` — the tree gains `writrun/`; the
  ownership split is stated as the two homes.
- `docs/technical/distribution/kit.md` — what the template ships and
  what the mirror guards, at the new addresses; the update and removal
  contract per the rule.
- `docs/technical/distribution/release.md` — the public surface a tag
  freezes now includes the `writrun/` seed.
- `docs/technical/distribution/take-task.md` — repoint where it names
  the settings address.
- `docs/technical/schemas/front-matter.md`, `docs/technical/schemas/spec.md`
  — repoint the settings references.
- `docs/technical/settings/README.md`, `docs/technical/settings/schema.md`,
  `docs/technical/settings/stage.md` — the file's address is
  `writrun/settings.json`.
- `docs/technical/decisions/tasks-and-specs/` — new dated entry:
  the adopter's files leave `.writrun/`, superseding 0053's address
  choice.

## Outcome

_(fill after execution)_
