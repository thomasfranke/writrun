---
id: spec-0024
task_ref: task-0020
status: implemented
created: 2026-08-30T13:16:11Z
---

# spec-0024 — auto_commit and auto_pr gate the agent's git actions

- **Goal:** two booleans put the agent's own git actions under the
  adopter's control: `auto_commit` (section `"stage_1"`) and `auto_pr`
  (section `"stage_2"`). `true` is today's behaviour. `false` means the
  agent still does all the work — composes the full commit message, or
  the pull request's title and body — then presents it and acts only on
  an explicit yes. The flags bind the agent even when its own platform
  runs in an autonomous or auto-accept mode: the platform's mode governs
  what the *harness* asks, these flags govern what the *adopter*
  allowed.

## Scope

In: the two keys in `.writrun/settings.json` and their documented
defaults in `read_setting.sh`; value checks in `check_settings.sh`; the
agent-facing reasoning in `.writrun/conventions/commits.md`
(`auto_commit`) and `.writrun/conventions/prs.md` (`auto_pr`); the
template mirror.

Out: `credit_ai` (spec-0025). The one commit the machinery makes
(`writrun approve`) and every workflow-driven write: those are not the
agent's actions and no flag governs them. What counts as "explicit yes"
inside a given agent platform — the flags state the obligation; each
platform's harness owns its own ask.

## Steps

1. Add `"auto_commit": true` under `"stage_1"` and `"auto_pr": true`
   under `"stage_2"` in this repo's settings file.
2. `read_setting.sh`: documented defaults `true` for both — the
   behaviour before the keys existed, which is what a documented
   default is.
3. `check_settings.sh`: both keys value-checked as `true`/`false`,
   present-always in their documented sections; shape strictness stays
   scoped as today (agent-read keys get value checks only).
4. Write the reasoning where agents read conventions: `commits.md` —
   when `auto_commit` is false, compose the whole message first, show
   it, commit only on approval, and the obligation outranks the
   platform's own autonomy mode; `prs.md` — the same contract for
   opening a pull request, title and body composed and shown first.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When `auto_commit` is `false` and the agent has a commit to make, the
  agent shall compose the full commit message, present it, and commit
  only after explicit approval.
- When `auto_pr` is `false` and the flow calls for opening a pull
  request, the agent shall compose the title and body, present them,
  and open the pull request only after explicit approval.
- When the agent's platform runs in an autonomous or auto-accept mode,
  the two flags shall bind exactly as they do in an interactive one.
- When either flag is `true` or absent, the agent shall act as it does
  today, unprompted.
- When either key holds anything but `true` or `false`,
  `check_settings.sh` shall exit 1 naming the fault.

## Edge cases

- A flow whose *next* step is mechanical (the draft PR that marks a
  task as taken): `auto_pr: false` holds it too — the flag gates the
  action, not the reason for it; the agent presents, waits, then the
  taken flow continues unchanged.
- Several commits in one working session: each is presented — approval
  is per action, never a session-wide grant.
- The machinery's own commit and the workflows' pushes: untouched by
  both flags, by Scope.

## Tests required

- `check_settings.sh`: boolean values pass; any other value is a named
  fault; a missing key is a named fault (present-always).
- `read_setting.sh`: absent key and absent file print `true`.
- The agent-conduct criteria are not machine-judged (decision 0028) —
  they bind through the conventions prose the kit ships, which the
  tests only prove is mirrored.

## Definition of Done

- [ ] Both keys live in their sections with defaults documented and
      checked.
- [ ] `commits.md` and `prs.md` carry the ask-first contract, including
      its precedence over platform autonomy.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the keys and their conduct rule were authored first; the
  product layer names the settings file, not its keys.

## Proposed technical changes

- none — the keys, defaults and precedence rule were authored first
  (`technical/README.md#settings`); this change makes them true.

## Outcome

Built as specified: `"auto_commit": true` sits in `"stage_1"` and
`"auto_pr": true` in `"stage_2"`, both documented as defaults in
`read_setting.sh`, both value-checked as `true`/`false` and
present-always in `check_settings.sh`. `commits.md` and `prs.md` carry
the ask-first contract: the agent composes the whole message, or the
complete title and body, presents it, and acts only on an explicit yes,
per action and never as a session-wide grant — and the flags outrank the
agent platform's own autonomy mode, because a setting that only bound an
agent already asking would control nothing. `prs.md` states that
`auto_pr` holds the draft that reports a task as taken too: the flag
gates the action, not the reason for it. The machinery's own commit and
every workflow-driven write stay untouched, stated in `commits.md` where
that commit is already described.

Divergence: none. The conduct criteria are agent-bound prose
(decision 0028); the suite proves the keys are read, checked and
mirrored, not that an agent obeyed them.
