---
id: spec-0011
task_ref: task-0014
status: implemented
created: 2026-08-28T00:00:00Z
---

# spec-0011 — Read adopter choices from a settings file

**References:** [task-0014](../tasks/task-0014-read-adopter-choices.md)

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

Done as specified. `.writrun/conventions/settings.json` ships at today's
values; `read_setting.sh` reads it with `sed`; `check_settings.sh` runs as
its own read-only job in `writrun-check.yml`; and `level_gate.sh` gates all
four workflows — `pull-requests` for check and approve, `github-issues` for
issues and progress. The scope's surprise held: no queue script changed,
because `pr_title_style` is read by agents and only `level` is machine-read.

A new `settings` suite carries one case per acceptance criterion, with the
two edge cases folded into the case they belong to — a colon inside a
quoted value into the reader's, a trailing comma into the shape's. The
whole existing suite passes untouched: 203 case files, 0 failed, which is
the proof asked for that shipping the mechanism at today's values changed
no behaviour.

Six divergences, and the first two are one decision:

- **The gate is a job, not a first step.** Step 5 says each workflow gains
  a first step. A step cannot end a job without failing it, so that shape
  would have meant guarding every later step with an `if` — fifteen of
  them in `writrun-check.yml` alone, each an independent chance to forget
  one. As a job with an output, every other job carries `needs: gate` and
  a single `if`, a project below the level starts no runner at all, and
  the reason is reported once per workflow instead of once per job. The
  behaviour the criteria describe is unchanged; only where the decision
  sits moved.

- **The mirror cases do not reuse the forge stub.** Tests required expects
  them to, which only works if the gate lives inside `mirror_issues.sh` —
  and putting it there while the workflows also gate would be two ways to
  say one thing, which is exactly what 0041 objected to. So the level
  cases run `level_gate.sh` directly, and the wiring is covered by the one
  thing the suite cannot reach by running a script:
  `every_workflow_is_gated_test.sh` reads the four YAML files as text and
  fails if any job does not wait on the gate. Verified against the defect
  — remove one `needs: gate` and the case names that job.

- **An absent settings file passes the check.** Step 2 makes absence
  legitimate for the reader; a check that failed on the same absence would
  make the file mandatory by the back door and contradict it. It reports
  that the documented defaults apply.

- **A `level` outside its vocabulary is read as the default, not as a
  stop.** The gate could have refused to run anything, but a typo that
  silently switched off the machinery is the failure mode this whole
  change exists to remove. It says the value is unreadable, names
  `check_settings.sh` as what will fail over it, and lets the jobs run.

- **The core-key check is a substring tripwire, not a proof**, and says so
  in the script. The shapes such a key could take are not enumerable, and
  a key named to evade the list evades it. What it catches is the honest
  attempt — someone reaching for a switch the methodology does not offer,
  told where the rule is instead of finding out at review that their file
  was ignored.

- **A key the schema does not document reads as empty, not as an error.**
  The documented defaults exist for the two documented keys; an adopter's
  own variant key has none to fall back to. The reader prints nothing and
  exits 0 — it reads a value, it does not judge the file, which is
  `check_settings.sh`'s job.
