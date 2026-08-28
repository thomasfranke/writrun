---
id: spec-0011
task_ref: task-0014
status: approved
created: 2026-08-28
---

# spec-0011 — Read adopter choices from a settings file

## Scope

`.writrun/conventions/settings.json` exists, one reader serves whatever
needs it, a check keeps the file honest, and `level` actually gates the
workflows.

In scope: the settings file; `.writrun/scripts/read_setting.sh`;
`.writrun/scripts/check_settings.sh` wired into `writrun-check.yml`; and the
level gate in all four writrun workflows.

**Out of scope, and worth stating because it is surprising: the queue
scripts need no change.** `pr_title_style` is read by agents, not by code —
nothing parses the summary after the tag. Only `level` is machine-read.

Also out of scope: adding any key beyond the two the schema names, and the
conventions prose, which the authoring change already rewrote.

## Steps

1. Ship `.writrun/conventions/settings.json` with the two documented keys at
   their current values (`level: github-issues`, `pr_title_style: conventional`).
2. `read_setting.sh <key>` — prints the value, or the documented default
   when the file or key is absent. Absence is not an error: an adopter who
   deletes the file keeps working, the same posture `list_tasks.sh` takes
   when no forge is reachable. `sed`/`awk` only, never `jq`.
3. `check_settings.sh` — canonical shape (flat object, one `"key": value`
   per line, two-space indent, values `true`/`false`/quoted string), both
   keys present exactly once, values inside their vocabularies, and **no key
   naming a rule Adoption lists as core**. Shape is enforced for `level`,
   which the workflows parse; `pr_title_style` is checked for value only.
4. Wire it into `writrun-check.yml` as its own read-only job.
5. Each of the four workflows gains a first step that reads `level` and
   stops the job below the level it needs: `writrun-check` and
   `writrun-approve` need `pull-requests`, `writrun-issues` and `writrun-progress`
   need `github-issues`. The files stay installed and inert — the setting is what
   turns them off, not deleting them, which is the reversal of 0041 this
   implements.

## Acceptance criteria

- When a key is present, `read_setting.sh` shall print its value.
- When the settings file is absent, `read_setting.sh` shall print the
  documented default and exit 0.
- When a documented key is missing, `check_settings.sh` shall reject the
  file.
- When a value falls outside its vocabulary — `pr_title_style: gherkin`,
  `level: everything` — the system shall reject it.
- When the file is not in the canonical shape (nested, an array, two keys
  on one line, a duplicated key), the system shall reject it.
- When a key names a rule Adoption lists as core, the system shall reject
  it.
- When `level` is `tasks-and-specs`, no writrun workflow shall act, and each shall
  report why.
- When `level` is `pull-requests`, `writrun check` and `writrun approve` shall act and
  the two mirror workflows shall not.
- When `level` is `github-issues`, all four shall behave exactly as they do today.

## Edge cases

- A quoted value containing a colon (`"status:"`) — the reader must not
  truncate at the colon.
- Trailing comma on the last key: invalid JSON, and the check must say so
  rather than silently reading the file anyway.
- `jq` absent from `PATH`: everything works, because nothing calls it.
- An adopter who deletes the workflows *and* leaves `level: github-issues` —
  allowed. Deleting a workflow was always permitted and the setting cannot
  resurrect a file that is gone; the key controls what runs, not what exists.

## Tests required

One case per acceptance criterion, in a new `settings` suite. The mirror
cases reuse the forge stub the `mirror_issues` suite already builds. Plus
the whole existing suite, unchanged, as proof that shipping the mechanism at
today's values changed no behaviour.

## Definition of Done

- `make tests` green, including the new cases and every existing one
  untouched.
- `make template-sync` changes nothing beyond the synced copies.
- No permanent doc touched.

## Proposed product changes

none — the authoring change stated the rule in
`product/adoption.md#three-levels` first.

## Proposed technical changes

none — the same authoring change covered the schema in
`technical/README.md#settings`.

## Outcome

(filled when the task completes)
