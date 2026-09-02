---
id: spec-0046
task_ref: task-0034
status: implemented
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
and already earns its length); `AGENTS.md` — this spec adds no
`AGENTS.md` edit of its own (spec-0049 is the one reshaping the
completion steps' skill pointers, and that edit is its).

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

- A sentence that is half rule, half interpretation — the
  "run it **after** step 4" ordering warning, which lives in
  `AGENTS.md`'s completion steps, not in a skill: spec-0049 encodes
  that ordering in `preflight.sh`, and the check-task-state skill
  keeps one operational when-to-run line.
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

- `technical/selection.md` — gains the line naming its skill as the
  operational pointer, plus whatever the audit shows the select skill
  alone said.
- `technical/schemas.md` — the same, for the create skill's schema
  prose.
- `technical/reporting.md` — the same, for triage (report-0004 says
  the triage table already stands in three docs, so the definite
  delta is the pointer line; sentences move only where the audit
  finds one unstated).
- `technical/distribution.md` — absorbs the check skills' operational
  warnings no chapter states today ("pass all four gates or none";
  deltas never checked one spec at a time).

## Outcome

The five skills went from 39.7KB to 18.5KB. Select 8.6 → 2.9KB, create
18.4 → 8.0KB, check-front-matter 3.5 → 2.0KB, check-spec-deltas 4.0 →
2.4KB, check-task-state 5.3 → 3.3KB. Each keeps its command, its flags,
its exit codes and the judgements no script makes, and links the chapter
for everything else.

Four sentences existed nowhere but a skill and moved into the chapters in
this same diff:

- "WritRun has no claim mechanism", the forge as the only real-time
  signal, and the offline caveat → `selection.md#nobody-claims-a-task`.
- What step 0 cannot see — the recording window, a branch never pushed,
  an amendment riding an open pull request →
  `selection.md#where-step-0-can-see-and-where-it-cannot`.
- The template resolution order (project template, shipped default,
  built-in skeleton) → `schemas.md`, beside the extension-field rule it
  belongs to.
- "Pass all four directories or none" and "never check one spec at a time
  against the same diff" → `distribution.md#running-the-checks`.

Each chapter also gained the pointer line naming its skill as the
operational half.

Divergences: the create skill landed at 8.0KB against a ~6KB target. The
remainder is command blocks, flags and fill-in instructions — the parts
the spec says to keep — and cutting further would have deleted operational
content rather than restated rules. The select skill landed at 2.9KB
against ~2.5KB for the same reason: the lister prints four sections, not
three, and each needs its line.
