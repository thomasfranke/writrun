---
id: report-0013
status: tracked
task_ref: [task-0041]
doc_ref: technical/schemas.md#front-matter-is-canonical
created: 2026-09-03T04:05:54Z
triaged: 2026-09-03T04:06:37Z
---

# check_state.sh reads the queue's README as a task

**References:** [technical/schemas.md#front-matter-is-canonical](../../docs/technical/schemas.md#front-matter-is-canonical) · [task-0041](../tasks/task-0041-readme-not-a-task.md)

Adopting the kit into a repository at Stage 2 or above fails
`check_state.sh`, on the kit's own scaffolding. The first pull request an
adopter opens carries `work/tasks/README.md` as an added file, and the
check reads it as a task being born outside `backlog`:

```
FORBIDDEN: work/tasks/README.md enters the tree already ''.
  A task is born backlog (or blocked, with its reason); every
  other state is the machinery's to write after the merge.
```

Observed on `writrun-cli`'s adoption pull request
(<https://github.com/thomasfranke/writrun-cli/pull/1>), against kit
`v0.0.02`. Nine of the ten checks pass; this is the one that does not.

The selector is `check_state.sh:349`, `work/tasks/*.md)`, which matches
the queue's README alongside the task files. The README has no front
matter, so `fm_now "$f" status` returns empty, and empty is not
`backlog` or `blocked` — the branch that refuses a task born in flight
refuses a file that is not a task.

This repository does not hit it because its own `work/tasks/README.md`
entered the tree before Stage 2 existed, so it never appears as added in
a pull request range. The condition is reachable only on a first
adoption, which is why it survived to be seen from outside.

`work/specs/README.md` and `work/reports/README.md` arrive added in the
same pull request and are matched by the sibling globs at `:255` and
`:286`; neither refused this diff.

The same `work/tasks/*.md` shape appears in `check_queue_impact.sh:62`,
`check_amendment_reference.sh:160`, `check_unique_ids.sh:131` and
`stamp_task_dates.sh:129`. All four ran green on the same pull request —
recorded as the boundary of what was observed, not as a claim about
them.
