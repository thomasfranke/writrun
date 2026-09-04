# Architecture

**How the pieces fit together** — the map a reader holds before opening
any chapter. Every rule named here lives in the chapter linked beside
it; this file states none of its own.

## Two halves, one loop

The repository is a permanent half and an ephemeral half.
[`docs/`](../product/README.md) says what the system does, written by
and for people; `work/` is the queue that closes the gap between what
the docs say and what the code does. A rule is authored into `docs/`,
tasks and specs derive from it into `work/`, a pull request implements
an approved spec, and the merge records the loop closed — the flow
[`product/`](../product/README.md) prescribes, and everything below is
machinery serving it.

## The readers are line-based

Every script reads files with `bash`/`awk`/`sed` — no YAML parser, no
`jq`, no runtime dependency. That choice ripples into every contract:
queue front matter is a [canonical shape](schemas/front-matter.md), the
settings file is a [restricted subset of JSON](settings/schema.md), and
both are checked rather than assumed. What a line-based reader would
silently misread is refused at the door.

## The layers

| Layer | Is | Chapter |
|---|---|---|
| The queue | `work/tasks`, `work/specs`, `work/reports` — front matter the machinery reads | [`schemas/`](schemas/README.md) |
| The skills | five markdown instructions in `.writrun/skills/`, each backed by one deterministic script | [`distribution/skills.md`](distribution/skills.md) |
| The scripts | testable bash in `.writrun/scripts/`, one folder per adoption stage | [`distribution/checks.md`](distribution/checks.md) |
| The workflows | four `writrun-*.yml` — `check` at the door, `approve` and `progress` recording, `issues` mirroring | [`settings/stage.md`](settings/stage.md) |
| The settings | one file, `.writrun/settings.json`, read by machinery and agents alike | [`settings/`](settings/README.md) |
| The kit | `template/`, shaped like the destination root, mirrored from this repository | [`distribution/kit.md`](distribution/kit.md) |

## One session, end to end

A session starts on the [session card](distribution/session-card.md),
picks work by the [selection algorithm](selection/algorithm.md), takes
the task in [one command](distribution/take-task.md), records what it
noticed through the [report entry point](reporting/entry-point.md), and
completes against [preflight's three gates](distribution/preflight.md)
— the same three CI runs, in the same order. Statuses on the queue are
written by the machinery from forge events, never by the agent; the
[stage](settings/stage.md) says how much of that machinery is awake.
