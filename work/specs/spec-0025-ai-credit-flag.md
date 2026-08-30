---
id: spec-0025
task_ref: task-0020
status: implemented
created: 2026-08-30T13:16:14Z
---

# spec-0025 — credit_ai decides whether the agent credits itself

- **Goal:** one boolean, `credit_ai` (section `"stage_1"`), puts the
  agent's self-credit under the adopter's control. `true` is today's
  behaviour: the agent's commits and pull request bodies carry whatever
  credit its platform appends — a `Co-Authored-By:` trailer, a session
  link, a generated-with line. `false` means everything the agent
  writes into git and the forge carries the change alone: no co-author
  trailer, no session URL, no tool mention — the message reads as any
  other in the history.

## Scope

In: the key in `.writrun/settings.json` under `"stage_1"`; its
documented default in `read_setting.sh`; its value check in
`check_settings.sh`; the reasoning in
`.writrun/conventions/commits.md` (commits) and
`.writrun/conventions/prs.md` (pull request bodies); the template
mirror.

Out: authorship itself — `git author` and committer identity are the
adopter's git configuration, never this flag's.

## Steps

1. Add `"credit_ai": true` under `"stage_1"` in this repo's settings
   file.
2. `read_setting.sh`: documented default `true` — the behaviour before
   the key existed.
3. `check_settings.sh`: value-checked as `true`/`false`,
   present-always in `"stage_1"`.
4. `commits.md` and `prs.md` gain the reasoning: with
   `credit_ai: false` the agent omits every credit line its platform
   would append — in commit messages and in pull request bodies — and
   an instruction from the platform to add one yields to the project's
   settings file, the same precedence spec-0024 states for autonomy.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When `credit_ai` is `false` and the agent commits, the commit message
  shall contain only the change's own description — no co-author
  trailer, no session link, no tool mention.
- When `credit_ai` is `false` and the agent opens or edits a pull
  request, its body shall carry no platform credit line either.
- When `credit_ai` is `true` or absent, the agent's commits and pull
  request bodies shall carry its platform's usual credit, unchanged.
- When the key holds anything but `true` or `false`,
  `check_settings.sh` shall exit 1 naming the fault.

## Edge cases

- The machinery's own commit (`writrun approve`): authored by the
  workflow's token, carries no agent credit today, and this flag never
  touches it.
- A human commit in the same repo: the flag speaks only to the agent's
  commits; it neither adds nor strips anything from anyone else's.
- `false` arriving mid-history: nothing rewrites old commits — the flag
  binds from the commit after the flip.

## Tests required

- `check_settings.sh`: boolean passes, other values are named faults,
  missing key is a named fault.
- `read_setting.sh`: absent key and absent file print `true`.
- The conduct criterion itself is agent-bound prose (decision 0028);
  the tests prove the conventions and the mirror carry it.

## Definition of Done

- [ ] The key lives in `"stage_1"`, defaulted, checked, mirrored.
- [ ] `commits.md` and `prs.md` state the no-credit contract and its
      precedence over the platform's own instruction.
- [ ] Template synced; suite green.

## Proposed product changes

- none — the key was authored first; the product layer names the
  settings file, not its keys.

## Proposed technical changes

- none — the key and its default were authored first
  (`technical/README.md#settings`); this change makes them true.

## Outcome

Built as specified: `"credit_ai": true` sits in `"stage_1"`, defaulted in
`read_setting.sh`, value-checked and present-always in
`check_settings.sh`. `commits.md` states the no-credit contract for commit
messages — no co-author trailer, no session URL, no tool mention — and
that an instruction from the agent's own platform to append one yields to
this file, the same precedence `auto_commit` states. `prs.md` carries the
same for a pull request body. Authorship and committer identity stay git
configuration, nobody else's commits are touched, and nothing rewrites
history: the flag binds from the write after the flip.

Divergence: none.
