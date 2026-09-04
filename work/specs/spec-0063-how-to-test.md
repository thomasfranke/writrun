---
id: spec-0063
task_ref: task-0044
status: draft
created: 2026-09-04T14:51:10Z
---

# spec-0063 — A pull request body says how to test

**References:** [task-0044](../tasks/task-0044-pr-body-shape.md)

- **Goal:** a reviewer opening a finished pull request finds the command
  that shows the change working, and never has to infer it from the diff.

## Scope

In: the `## How to test` section — the shipped template, its instruction
comment, `conventions/prs.md`, the no-template fallback body in
`take_task.sh`, and the template mirror.

Out: the bullet shape of the three declarations
([spec-0062](spec-0062-body-references.md)); any check that reads the
section — what a reviewer runs is prose, and a checker for its presence
would be satisfied by the word "none" a forgotten section already earns.

## Steps

1. `.writrun/templates/pull_request_template.md`: `## How to test` is
   added directly under `## How to verify`, inside the writrun-owned
   region, with an instruction comment stating the split — verify is the
   gates' result and anything to re-read by hand, test is what the
   reviewer runs and what to expect back — and stating that a change with
   nothing runnable says so in a line.
2. `.writrun/conventions/prs.md`: the **Body** bullet names the two
   questions and links
   [`body.md`](../../docs/product/stage-2-pull-requests/body.md) for the
   reasoning.
3. `take_task.sh`: the no-template fallback body gains the same section,
   in the same position, so a project whose template is missing is not
   handed a different contract.
4. The completion flow's own instruction — the skill step that says to
   run preflight until exit 0 — is left alone. Filling the section is the
   author's, at the moment they mark the pull request ready, which is
   where `finishing.md` already puts the last body edit.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When the shipped template is filled, it shall carry a `## How to test`
  section distinct from `## How to verify`, each stating which question
  it answers.
- When `take_task.sh` composes a body without the template, the composed
  body shall carry the same two sections in the same order as the
  template.
- When a change ships nothing runnable, the section shall be filled with
  that statement rather than left empty.

## Edge cases

- An authoring or reporting pull request, which ships prose: the section
  says so and names the doc checks if any were run. It is not deleted —
  a deleted section and a forgotten one look identical.
- A project that edited its own template before this change: the section
  is the kit's default, and an adopter who removed it has removed it.
  Nothing re-adds it on update.

## Tests required

- `tests/unit/take_task/`: the fallback body carries `## How to test`
  after `## How to verify`.
- `tests/unit/template/`: the mirror stays byte-identical.

## Definition of Done

- [ ] The template carries both sections, each with its instruction.
- [ ] The fallback body matches the template's sections.
- [ ] `conventions/prs.md` names the two questions.
- [ ] `make template-sync` leaves no diff.
- [ ] The suite is green.

## Proposed product changes

- none — the rule was authored ahead of this spec
  (`product/stage-2-pull-requests/body.md#the-body-says-how-to-test`);
  authoring closes the loop in advance.

## Proposed technical changes

- `technical/distribution/take-task.md#take_tasksh--the-taking-act-in-one-command`
  — the fallback body's sections are part of what the script composes.

## Outcome

_(fill after execution)_
