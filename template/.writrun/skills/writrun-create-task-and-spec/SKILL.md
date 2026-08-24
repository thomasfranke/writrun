---
name: writrun-create-task-and-spec
description: Use this skill when creating a new task or spec in a project that follows the WritRun methodology — when the user asks to track a piece of work, when work is found that isn't yet tracked, or when an existing task needs its spec drafted before implementation can start. Covers front-matter schema, id assignment, when a spec is warranted, and how to fill the Proposed changes sections.
---

# Create a task, and its spec when warranted

Turns the WritRun schema into a checklist instead of something re-derived
from memory each session. Read `docs/technical/README.md` in the target
project first if it's present — it may state adopter-specific choices (id
prefix, whether a spec is mandatory) that override the defaults below.

## Does this even need a task?

A typo or a one-line fix is a commit, not a task. Create one only for work
that justifies tracking: a behaviour change, a new subsystem, anything a
future reader might reasonably ask "why was this done" about.

## Creating a task

Run the generator rather than writing the front-matter from memory — a
hand-written task drifted on four of these fields while this methodology's
own `docs/product/` chapters were being drafted (see
`docs/product/concepts/task.md#example`), which is exactly the kind of
drift this script exists to make impossible:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh task "<title>" \
  [--priority high|medium|low] \
  [--depends-on task-nnn,task-mmm] \
  [--doc-ref path/to/doc.md#anchor] \
  [--milestone name]
```

It finds the highest existing `task-nnn` id and increments it (never reuses
or renumbers one, even if a task was later deleted), and writes
`work/tasks/task-nnn.md` with every field present explicitly — an empty
list is never the same as an omitted field:

```yaml
---
id: task-nnn
status: pending
blocked_reason: null
spec_ref: []
doc_ref: null            # or --doc-ref's value
priority: medium              # or --priority's value
depends_on: []                 # or --depends-on's value, as a list
milestone: null                # or --milestone's value
created: <today, ISO date>
completed: null
---
```

Then fill in the generated body: the request only — what to do, and why it
matters. No acceptance criteria, no step-by-step plan, no technical detail:
that belongs in the spec, not the task. Fill any extension fields the
project's template added to the front matter too — see the next rule.

If the script isn't available in the target project (not yet copied in, or
no bash), do the above by hand — the schema is normative either way, the
script is just the mechanical way to hit it exactly.

**Body shapes resolve in layers, and the project's wins.** The generated
body comes from `.writrun/conventions/templates/task.md` (or `spec.md`) when the
project defined one; otherwise from the shipped default in
`.writrun/templates/`; otherwise from the script's built-in skeleton.
When writing by hand, honour the same order.

**Read the resolved template as the project's brief, not just a shape.**
The *contract* front matter is never templated — the script generates
it, and refuses a template that redefines a contract field. But a
project template may open with a front-matter block of its own:
**extension fields** (owner, estimate, whatever the project tracks),
which the script appends to the generated contract block, placeholder
values and all. Filling them is your job, exactly like the body: treat
each extension field's placeholder text — and anything the template's
body says about it — as the project's instruction for what belongs
there, and never hand over a task or spec with a generated placeholder
still standing. A spec template must also keep the two Proposed-changes
headings and Outcome, or the script refuses it.

## Does this task need a spec?

Skip the spec only if the task is small enough that its own body plus
`doc_ref` is a complete, unambiguous brief. Default to writing a spec
whenever:

- the work touches more than one file or subsystem,
- there's more than one reasonable way to implement it, or
- the task references a `doc_ref` that needs translating into concrete
  technical steps.

When in doubt, write the spec — an unnecessary spec costs a review; a
missing one costs an agent guessing at scope.

## Creating a spec

Same generator, second subcommand:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh spec task-nnn "<title>"
```

`task_ref` must point at a task that already exists — the script refuses
otherwise, because a spec is never created before its task. It finds the
highest existing `spec-nnn` id and increments it, writes
`work/specs/spec-nnn.md` with `status: draft` and a body skeleton (Scope,
Steps, Acceptance criteria, Edge cases, Tests required, Definition of Done,
and both Proposed-changes sections defaulted to "none"), and **appends**
the new spec's id to the task's `spec_ref` list itself — never overwriting
existing entries.

Then fill in the skeleton:

1. Scope, steps, EARS-format (`When <trigger>, the system shall <response>`)
   acceptance criteria, edge cases, tests required, Definition of Done.
2. Replace both Proposed-changes placeholders with real entries whenever the
   task changes behaviour or machinery:

   ```markdown
   ## Proposed product changes
   - `path/to/doc.md#anchor` — one line on what changes and why.

   ## Proposed technical changes
   - `path/to/doc.md#anchor` — one line on what changes and why.
   ```

   Every path here must be one the completing diff will actually touch —
   this list is the merge contract checked by the `writrun-check-spec-deltas`
   skill. Leave either section as "none" only if genuinely nothing in that
   category changes.
3. Fill any extension fields the project's template added to the front
   matter — their placeholder text is the project's instruction for what
   belongs in each.
4. Leave `status: draft`. Moving to `approved` is a human decision (or
   whatever the target project's `AGENTS.md` states) — never set it here.

If the script isn't available, do the same steps by hand, including the
manual `spec_ref` append on the task file.

## When completing a task

1. Fill the spec's **Outcome** section: what was actually built, and any
   divergence from the original plan, and why. Do not silently edit the
   Proposed changes sections to match reality after the fact — the
   divergence is the record.
2. Set the spec's `status: implemented`.
3. Set the task's `status: completed` and fill `completed` with today's date.

## Never

- Never create a spec without a `task_ref` that resolves to a real task.
- Never rename or renumber an existing id.
- Never move status information into a folder structure — it lives in
  front-matter only.
