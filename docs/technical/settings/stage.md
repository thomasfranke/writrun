# The stage

**The single global switch**, and what each value stops. One chapter of [`settings/`](README.md).

## `stage`

Ordered and cumulative, so one value rather than three switches. Each stage
stops the machinery the one below it does not need:

- `1` (tasks and specs) — no workflow runs. The four scripts still run as
  ordinary commands, so every guarantee they carry survives; what stops is
  the *enforcement*, which a person then performs deliberately.
- `2` (pull requests) — `writrun check` and `writrun approve` run.
- `3` (GitHub issues) — adds `writrun issues` and `writrun progress`.

**The four human gates are core at every stage.** A gate asks for *a human
decision, recorded*, never for a pull request specifically
([gates](../../product/stage-1-tasks-and-specs/gates.md)). At Stage 1 a person performs each
directly and names how in their `AGENTS.md`, which Adoption already requires.
No check can verify that, which is why it is stated here: `stage: 1` is
not permission to drop them.

