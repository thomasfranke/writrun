---
id: spec-0028
task_ref: task-0022
status: implemented
created: 2026-08-31T02:58:23Z
---

# spec-0028 — Queue references are clickable links

**References:** [task-0022](../tasks/task-0022-queue-vocabulary.md)

- **Goal:** a reader follows the queue by clicking. The generated body
  of a task links its `doc_ref` and each spec in `spec_ref`; the
  generated body of a spec links its `task_ref` — all as relative
  markdown links that resolve on the forge and in any editor. The front
  matter stays plain strings: it is the machine contract, and the
  line-based readers never see the body.

## Scope

In: `new.sh` (both subcommands and the `spec_ref` append), the shipped
body templates, a backfill sweep over the existing queue, and the
template mirrors.

Out: the front-matter schema (unchanged, canonical form untouched);
link-checking machinery (a broken body link is a doc bug, not a
lifecycle violation — no new check); the Issues mirror's body (its own
rendering, not this spec's).

## Steps

1. `new.sh task`: when `--doc-ref` is given, the generated body carries
   a References line linking it —
   `[product/adoption.md#three-stages](../../docs/product/adoption.md#three-stages)`
   — resolved relative to `work/tasks/`.
2. `new.sh spec`: the generated body's References line links the task
   file — `[task-0022](../tasks/task-0022-queue-vocabulary.md)` — and
   the same run appends a matching spec link to the task's References
   line, in the same edit that appends to `spec_ref`.
3. The shipped default templates in `.writrun/templates/` carry the
   References placeholder the script fills; a project template that
   omits it simply gets no links (taste, not contract).
4. Backfill: one sweep adds References lines to the existing files
   under `work/tasks/` and `work/specs/` — links only, no other body
   edit, front matter untouched.
5. `make template-sync`.

## Acceptance criteria (EARS)

- When `new.sh task` runs with `--doc-ref`, the generated body shall
  contain a relative markdown link to that doc that resolves from
  `work/tasks/`.
- When `new.sh spec` runs, the generated spec body shall contain a
  relative markdown link to its task file, and the task's body shall
  gain a link to the new spec in the same run.
- When either generator writes links, the front matter it writes shall
  remain byte-identical to the canonical form `check_front_matter.sh`
  accepts today.
- When the backfill sweep runs, every existing task and spec body shall
  carry links for its `doc_ref`, `spec_ref` and `task_ref` values, and
  `check_front_matter.sh` shall still exit 0 over the queue.

## Edge cases

- A task with empty `spec_ref` and null `doc_ref`: no References line —
  an empty scaffold heading is noise.
- A `doc_ref` whose anchor no longer exists: the link still renders
  (file-level navigation survives); anchor drift is caught where doc
  edits are reviewed, not here.
- A retitled task: links target filenames, which never change
  (identity is never order), so no link maintenance on retitle.

## Tests required

Generator tests covering the three link cases (task with doc_ref, spec
linking back, append adding the task-side link); the front-matter suite
green over the backfilled queue; template-mirror test green.

## Definition of Done

- [ ] Both generators emit links; the append keeps task and spec bodies in step.
- [ ] Existing queue backfilled; full suite green.
- [ ] Template mirrors byte-identical.

## Proposed product changes

- none — navigation is machinery behaviour; no product rule changes.

## Proposed technical changes

- none — the rule was authored first (`technical/README.md`, the
  "References are navigable" bullet); this change brings the generator
  and the queue up to it.

## Outcome

Built as specified. `new.sh` gained a `refs_line` helper and a
`{{references}}` placeholder in `render_template`; a task's generated
body carries `**References:** [doc_ref](../../docs/<doc_ref>)`, a
spec's carries `[task-NNNN](../tasks/<file>)`, and the `spec_ref`
append writes the matching spec link into the task's References line in
the same run. The shipped templates carry the placeholder; a project
template that omits it gets no links, unchanged. An empty references
value takes the placeholder's whole line with it, so a task with no
`doc_ref` and no spec has no empty heading. Front matter is
byte-identical to what the checker accepted before.

Backfill: one sweep added References lines to all 19 tasks and all 34
specs, links only, front matter untouched — every link verified to
resolve from the file it sits in. Divergence from the plan, one, and it
is an addition: the append also *creates* the References line when the
task had none, since the acceptance criterion is unconditional and a
task with `doc_ref: null` starts without one. Tests: three generator
cases (task with doc_ref, spec linking back, the append) plus the
no-links edge case; the front-matter suite and the template mirror
green.

Review, before merge, found that addition had swallowed the opt-out:
the append wrote a References line into a body whose template never
asked for one, so "gets no links" lasted exactly until the task's first
spec — and where the body opened at no `#` heading, the insert landed
nowhere at all while the run still reported it appended. Both are fixed
here. The append reads the resolved task template and leaves the body
alone when it carries no `{{references}}`; where it does insert, it
anchors on the body's first heading of any level and falls back to the
line after the front matter, so there is no body shape it can silently
skip. Two generator cases cover it.
