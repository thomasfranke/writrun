---
id: spec-0046
task_ref: task-0034
status: draft
created: 2026-09-02T06:02:27Z
---

# spec-0046 — the skills say run-and-interpret, the docs keep the why

**References:** [task-0034](../tasks/task-0034-session-cost.md)

- **Goal:** each `SKILL.md` costs what it earns: the trigger, the
  command, how to read its output, and only the judgement rules no
  script checks — with every normative sentence living once, in the
  permanent doc that owns it, and the skill linking there.

## Scope

In scope: the five `SKILL.md` files under `.writrun/skills/`; the
technical chapters spec-0045 creates, where they must absorb a
sentence that today exists only in a skill; `make template-sync` (the
skills are mirrored byte-identical).

Out of scope: every script (no behaviour change anywhere); the YAML
`description` front matter of each skill (it is the retrieval trigger
and already earns its length); `AGENTS.md` (its pointers to the skills
stay as they are).

Builds on spec-0045 — the chapters are where the prose lands — and is
implemented after it in the same change.

## Steps

1. Audit each `SKILL.md` sentence against the docs: already stated in
   a permanent doc → delete and link; stated nowhere else and
   normative → move it into the owning chapter in this same diff;
   operational (the command, the output's meaning, a judgement the
   script cannot make) → keep.
2. `writrun-select-next-task/SKILL.md` (8.6KB): steps 0–7 restate
   `technical/selection.md` and `list_tasks.sh` implements them — the
   skill becomes: trigger, run the lister, how to read its three
   sections, the resume-first and handed-a-task judgement calls as
   pointers into the chapter. Target ≤ ~2.5KB.
3. `writrun-create-task-and-spec/SKILL.md` (17KB): the schema prose
   restates `technical/schemas.md`; the triage table exists in three
   docs already — the skill becomes: the three `new.sh` command
   blocks with their flags, the fill-in-the-body instructions, when a
   spec is warranted (pointer to the setting + the three bullets),
   and the completion checklist with `record_provenance.sh`.
   Target ≤ ~6KB.
4. The three check skills (`writrun-check-front-matter`,
   `writrun-check-spec-deltas`, `writrun-check-task-state`): keep
   command + exit-code interpretation + the when-to-run rule; drop
   rule lists the scripts themselves enforce and the chapters state.
5. `make template-sync`; full suite.

## Acceptance criteria (EARS)

- When a sentence is deleted from a `SKILL.md`, it shall already
  stand in a permanent doc or move into one in the same diff — the
  audit in the PR body names which, per deletion of substance.
- When an agent follows a slimmed skill, every command, flag and exit
  code it needs shall still be in the skill itself — only rationale
  and restated rules require the link.
- When the suite runs, the template mirror test shall hold (skills
  synced byte-identical).

## Edge cases

- A sentence that is half rule, half interpretation (the
  check-task-state "run it **after** step 4" warning) — the rule half
  lives in the chapter; the skill keeps the one operational line.
- The select skill's "when a person asks what is available" conduct —
  agent conduct, not machinery: it stays in the skill, compressed.
- Adopters who copied the fat skills — they update with the next kit
  sync; nothing here breaks a stale copy, it is only longer.

## Tests required

None new — prose only. The template mirror test is the gate that the
copies moved together.

## Definition of Done

- [ ] Five skills at run-and-interpret size; no normative sentence
      lost — moved or already present, named in the PR body.
- [ ] Template synced; full suite green.

## Proposed product changes

- none — agent-facing process files and technical chapters only

## Proposed technical changes

- `technical/selection.md` — absorbs what the select skill alone said.
- `technical/schemas.md` — absorbs what the create skill alone said.
- `technical/reporting.md` — absorbs any triage sentence the create
  skill alone carried.

## Outcome

_(fill after execution)_
