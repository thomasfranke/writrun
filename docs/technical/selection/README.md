# Task selection

**How "what should I work on next" gets one answer, whoever asks.** The
algorithm the lister implements and every agent runs unchanged. Read it
when picking up work; the technical router is
[`../README.md`](../README.md).

| Chapter | Holds |
|---|---|
| [`algorithm.md`](algorithm.md) | the steps, what "active owner" means, why nobody claims a task |
| [`visibility.md`](visibility.md) | what the files can show about work in flight, and what only the forge can |
| [`brief.md`](brief.md) | `brief.sh` — step 7 in one call |

## The skill is the operational pointer

[`writrun-select-next-task`](../../../.writrun/skills/writrun-select-next-task/SKILL.md)
is this folder's operational half: `list_tasks.sh` implements steps 0–6
and prints what is eligible, what is in flight and what is held back;
`brief.sh` is step 7's mechanical form. The skill carries the commands
and how to read their output — the rules are here.
