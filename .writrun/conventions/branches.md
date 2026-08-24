# Branches

## Strategy

**This repository is trunk-based**: `main` is the only long-lived branch
and is always green. That is a choice, not a methodology rule — the
methodology needs exactly one thing from a branching strategy: **one
authority branch**, the branch the flows' pull requests target, protected,
with the human gates applied — where `docs/` and `work/` are the truth.
Call it `main`, `develop`, or anything else; run git-flow or releases
around it; WritRun neither knows nor cares what happens beyond it.

## Naming

- `docs/short-name` — authoring (flow 1).
- `queue/short-name` — tracking: a change that only adds tasks and specs
  for work discovered mid-flight, touching no permanent doc. Deliberately
  carries no `task-NNN` id at the start — a tracking PR records work, it
  is not working it, and must not read as in flight.
- `spec/NNN-short-name` — implementing spec NNN (flows 3–5);
  `task/NNN-short-name` for a spec-less task. The `spec-NNN` / `task-NNN`
  id at the start of the name is a **contract marker**: it is what lets
  the machinery report the task as in flight and move its mirror.
- `<type>/short-name` (e.g. `fix/broken-anchor`) — trivial work, which is
  a commit and never a task; `main` is protected, so even a typo rides a
  branch and a PR.
