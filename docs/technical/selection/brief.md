# The brief

**Step 7 in one call** — the reader that assembles a task's whole brief. One chapter of [`selection/`](README.md).

## `brief.sh` — step 7 in one call

Step 7 says to read the task's body, every spec in `spec_ref`, and the
section `doc_ref` anchors, before any code. By hand that is four to six
whole-file reads to reach one section of each, so it is a script:

```bash
bash .writrun/skills/writrun-select-next-task/brief.sh <task-id> \
  [task-dir] [spec-dir] [docs-dir]
```

The id resolves by **number**, at any width and with or without the
`task-` prefix — a person types `34`, the file says `task-0034`, and both
name the one file. The output is one header line (id, status, priority,
and each spec's id and status — the same cross-check step 4 makes, shown
rather than fetched), then each part behind a `== <path> ==` divider: the
task file whole, each `spec_ref` entry's file whole in list order, and
the `doc_ref` section last.

A `doc_ref` is written relative to `docs/`, so the file read is
`docs/<path>` and never `<path>` from the repository root. Its anchor
selects the section from the heading whose slug matches to the next
heading of the same or higher level; with no anchor the whole file is the
section. **Slugs are GitHub's own rule** — lowercase, spaces to hyphens,
backticks dropped, punctuation stripped except hyphens and underscores,
duplicate heading text taking `-1`/`-2` in document order — because that
is what every `doc_ref` in a queue already targets.

**A router stub is followed once.** Where the resolved section's whole
body is a single link line — the shape
[`technical/README.md`](../README.md) takes for a section that moved to a
chapter — the reader follows it and prints the chapter's section, with
the divider naming both hops. A brief that looked complete while holding
one link is the failure that rule exists to prevent.

Exit codes: **0** the brief is complete; **1** the id resolves to no
task file, naming what was looked for; **2** the brief is partial — every
part that resolved is printed, and the ones that did not are named. An
empty `spec_ref` and a null `doc_ref` are answers, not failures: the
divider says so and the exit stays 0.

It is a reader — no git, no network, no writes, and no judgement.
Eligibility stays the lister's, and whether a `doc_ref` section now
contradicts its spec stays the reader's.
