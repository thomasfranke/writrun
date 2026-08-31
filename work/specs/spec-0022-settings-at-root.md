---
id: spec-0022
task_ref: task-0020
status: implemented
created: 2026-08-30T13:16:05Z
---

# spec-0022 — Settings move to WritRun's root

**References:** [task-0020](../tasks/task-0020-settings-restructure.md)

- **Goal:** `.writrun/settings.json` is the settings file's one address —
  the root of WritRun's home, not a corner of `conventions/` — and every
  reader, check, doc and mirror knows it, while a file left at the old
  address keeps working and is told to move.

## Scope

In: moving the file to `.writrun/settings.json`; pointing both scripts
(`read_setting.sh`, `check_settings.sh`) at the new address with a
legacy bridge for the old one; sweeping every reference to the old path
— `AGENTS.md`, the root `README.md`, `.writrun/conventions/README.md`,
`docs/product/adoption.md`, `tests/pipeline_lib.sh`, and the
`template/` mirror of all of it.

Out: the file's internal shape (spec-0023) and any new key
(spec-0024, spec-0025). History stays untouched: decision 0052,
spec-0011 and task-0014 keep naming the address that was true when they
were written.

## Steps

1. `git mv .writrun/conventions/settings.json .writrun/settings.json`.
2. In `read_setting.sh`: `SETTINGS=".writrun/settings.json"`; when that
   file is absent, fall back to reading
   `.writrun/conventions/settings.json` unchanged — the bridge freezes
   the old contract, exactly as the `level` bridge froze the old
   vocabulary.
3. In `check_settings.sh`: check the new address; when only the old one
   exists, fault naming the move — the reader honours the old file
   meanwhile, but only this check will tell you.
4. Sweep the remaining references named in Scope, then
   `make template-sync`.

## Acceptance criteria (EARS)

- When `.writrun/settings.json` exists, `read_setting.sh` shall read it
  and ignore the legacy address entirely.
- When only `.writrun/conventions/settings.json` exists,
  `read_setting.sh` shall honour it exactly as before the move.
- When only the legacy file exists, `check_settings.sh` shall exit 1
  with a fault naming the new address.
- When neither file exists, `read_setting.sh` shall print the documented
  defaults and `check_settings.sh` shall pass, both as today.
- When the sweep is done, no file outside `work/` history and
  `docs/technical/decisions/` shall mention
  `.writrun/conventions/settings.json` except the two scripts' bridge
  and the docs that document that bridge.

## Edge cases

- Both files exist: the new address wins, and `check_settings.sh` faults
  the leftover — one file, one address, never a silent tie.
- An adopter's kit updated mid-flight: the bridge is why their stage
  choice survives until they move the file themselves.

## Tests required

- Reader: new address read; legacy address honoured when alone; new
  address wins when both exist; defaults when neither.
- Check: legacy-only faults naming the move; new-only passes; absent
  passes.
- The template mirror stays byte-identical (`make template-sync`
  produces no diff).

## Definition of Done

- [ ] The file lives at `.writrun/settings.json`; both scripts read it
      there.
- [ ] The legacy bridge honours an unmoved file; the check names the
      move.
- [ ] Every live reference swept; the template mirror synced; the suite
      green.

## Proposed product changes

- `product/adoption.md#three-stages` — the settings link follows the
  move.
- `product/adoption.md#mandatory-core-vs-documented-variant` — the same
  link, same move.

## Proposed technical changes

- none — the address and the bridge were authored first
  (`technical/README.md#settings`); this change makes them true.

## Outcome

Built as specified: `.writrun/settings.json` is the one address, both
scripts read it there, and the bridge honours a file left at
`.writrun/conventions/settings.json` — read flat, under the contract
frozen at the move, so a sectioned address finds its key at the top
level there and a key the old contract never had falls back to its
documented default. `check_settings.sh` faults a legacy-only file by
naming the move, and faults a leftover one when both exist; the new
address wins outright either way. The sweep took `AGENTS.md`, the root
`README.md`, `.writrun/conventions/README.md`, `docs/product/adoption.md`
(both promised anchors), `stage_gate.sh`'s off-switch message,
`tests/pipeline_lib.sh`, the `writrun-check.yml` comment, and the
`template/` mirror.

Divergence: the sweep also fixed a broken link in
`.writrun/conventions/README.md` — its `decisions/0052` reference was
missing the `tasks-and-specs/` segment, one line above the `0053`
reference this change adds. A typo is a commit, and it rode this one.

The one live mention of the old address left outside the scripts and
`docs/technical/decisions/` is the parenthetical in
`technical/README.md#settings`, which documents the bridge — permitted by
this spec's last criterion — but frames it as "until the machinery catches
up", which is no longer true. Raised in the pull request rather than
edited: no spec promised a technical-doc change, and an approved spec's
promises are amended through `draft`, never out-implemented.
