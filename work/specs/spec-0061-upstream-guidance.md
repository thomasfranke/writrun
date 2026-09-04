---
id: spec-0061
task_ref: task-0043
status: approved
created: 2026-09-04T06:26:08Z
---

# spec-0061 — The kit routes methodology defects upstream

**References:** [task-0043](../tasks/task-0043-cross-repo-reports.md)

- **Goal:** an adopter's agent that hits a WritRun defect knows where
  it goes: record locally, ask the user, open the issue upstream, end
  the report `routed`.

## Scope

The kit's prose only. The machinery the guidance leans on is
[spec-0059](spec-0059-routed-status.md) and
[spec-0060](spec-0060-report-intake.md); no script changes here. The
target file is the kit's agent flow — `template/.writrun/AGENTS.md`
once [task-0042](../tasks/task-0042-entry-point-pointer.md) lands,
which is why the task depends on it.

## Steps

1. The kit's agent-flow file: the "Recording what you noticed" section
   gains **"When the defect is WritRun's"** — record the report
   locally as for any observation; then, on the user's explicit yes,
   asked per report and never assumed from the conduct flags, open an
   issue on the WritRun repository (`gh issue create`, or the report
   form by hand): title the observation, body the evidence and the
   `.writrun/VERSION` line; end the local report `routed`, its body
   naming the issue; a refused or unanswerable ask leaves it `open`.
   The section names the repository the kit came from — the
   provenance pointer `WRITRUN.md` already carries.
2. The same section's triage sentence says five ends where it says
   four, and which of them are the agent's to write (`fixed`,
   `declined`, and `routed` — the last only behind the user's yes).
3. `template/work/reports/README.md` — the "For agents" section gains
   the upstream pointer, one paragraph, linking the concept rather
   than restating it.
4. `template/WRITRUN.md` — the human-facing guide names the channel in
   its report section: a defect of WritRun itself is reported to
   WritRun, and the intake receives it.

## Acceptance criteria (EARS)

- When an agent reads the kit's recording section, it shall find the
  upstream route stated, with the authorization ask and both outcomes
  (`routed` on yes, `open` on no).
- When the guidance names the destination, it shall be the WritRun
  repository the kit came from, not a placeholder the adopter must
  fill.
- When the kit's prose counts report ends, it shall say five,
  matching the root's.

## Edge cases

- An adopter below stage 3: the guidance holds — the issue opens on
  the upstream repository, whose stage is its own; the adopter's
  stage plays no part.
- No `gh` or no network in the session: the ask cannot complete; the
  report stays `open`, which the guidance states rather than leaving
  the agent to improvise.
- The defect is in the adopter's own use of the kit, not the kit —
  the guidance points the doubt at the evidence: reproduced against a
  clean kit copy is upstream's, otherwise it is a local report like
  any other.

## Tests required

- The ships-vs-names and doc-shape guards stay green over the edited
  kit prose; the counts changed by hand are covered by the review, as
  `kit.md` records.

## Definition of Done

- [ ] The kit tells an adopter's agent the whole route, and every step
      of it is one the shipped machinery accepts.
- [ ] No kit file still describes four ends.
- [ ] `check_doc_shapes.sh` exit 0 over the template roots.

## Proposed product changes

- none — the rule was authored ahead of this spec
  (`product/concepts/report.md#routing-upstream`); authoring closes
  the loop in advance.

## Proposed technical changes

- none — kit prose only; the technical chapters are
  [spec-0059](spec-0059-routed-status.md)'s and
  [spec-0060](spec-0060-report-intake.md)'s to update.

## Outcome

_(fill after execution)_
