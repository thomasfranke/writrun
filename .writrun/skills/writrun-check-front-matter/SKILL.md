---
name: writrun-check-front-matter
description: Use this skill to verify that every task and spec file in a WritRun queue is in canonical front-matter form — when creating or hand-editing a queue file, before committing queue changes, or when a line-based reader is giving an answer that looks wrong. Runs on files alone: no git, no forge, no network.
---

# Check that the queue's front matter is canonical

Every reader in this methodology is line-based on purpose — plain
`bash`/`awk`/`sed`, no YAML parser, no runtime dependency. YAML permits
the same meaning in shapes those readers cannot see: a block list under
`spec_ref:` reads as an empty list, a quoted value never matches a path
comparison, a folded scalar reads as nothing. **Silently, in every case.**

So the canonical form is a checked contract rather than an assumption, and
this is the check.

```bash
bash .writrun/skills/writrun-check-front-matter/check_front_matter.sh [task-dir] [spec-dir]
```

Defaults to `work/tasks` and `work/specs`. Exit 0 when every file is
canonical, 1 when one is malformed — naming the file and what is wrong
with it.

## When to run it

**Whenever a queue file was written by hand.** The generator
(`writrun-create-task-and-spec`) only ever produces canonical form, so the
happy path costs nothing; this check exists for the files that did not come
from it.

It needs nothing but the files. No git repository, no remote, no `gh`, no
network — which is what makes it the one check available at every adoption
level, including a project that keeps its queue as markdown and nothing
else.

## What it enforces

The full contract is in WritRun's
[`technical/README.md`](https://github.com/thomasfranke/writrun/blob/main/docs/technical/README.md#front-matter-is-canonical).
In short: front matter opens at line 1 and closes with `---`; one field per
line as `key: value`; values bare — no quotes, no `>`/`|` block scalars, no
trailing whitespace; every schema field present exactly once even when
`null`; lists inline; `id` agreeing with the filename; statuses, priority
and dates drawn only from their documented forms; `blocked` and
`blocked_reason` paired both ways; `doc_ref` written relative to `docs/`.

An unknown key in canonical shape is allowed — an adopter may extend the
schema, not reshape it.

## What it does not do

It does not read git, so it says nothing about transitions — that is
[`writrun-check-task-state`](../writrun-check-task-state/SKILL.md). It
validates a `doc_ref`'s shape, not that the path exists.
