# Tasks

The front-matter schema is contract, not convention — see the
[task schema](../docs/technical/README.md#task-schema) — and the
generator (`new.sh`) writes it. What is taste, and this file's to state:

- **Title**: imperative and outcome-shaped ("Mirror the queue into
  Issues"), never activity-shaped ("Work on the mirror").
- **Filename subject**: `task-NNNN-<subject>.md` — the id plus an
  extremely short kebab-case echo of the title, two or three words
  (`task-0012-issue-mirrors.md`). Fixed at creation: a later retitle
  never renames the file.
- **Body**: the request only — what to do, and why it matters. No
  acceptance criteria, no step-by-step plan, no technical detail: that
  belongs in the spec.
- **Priority**: `high` means it blocks other queued work or a named
  milestone; `medium` is the default; `low` means "whenever".
- **Milestones**: kebab-case, versioned when they map to a release
  (`v0.1-core`); `null` is normal, not an omission.

To reshape the generated body itself, create
`.writrun/conventions/templates/task.md` — it wins over the shipped default in
`.writrun/templates/`. `{{id}}` and `{{title}}` are substituted;
front-matter is contract and never templated.
