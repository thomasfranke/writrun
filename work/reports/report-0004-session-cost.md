---
id: report-0004
status: tracked
task_ref: [task-0034]
doc_ref: null
created: 2026-09-02T06:02:13Z
triaged: 2026-09-02T06:02:19Z
---

# The per-session reading path has outgrown what the work needs

**References:** [task-0034](../tasks/task-0034-session-cost.md)

Measured on this checkout (2026-09-02), the reading path `AGENTS.md`
prescribes before a first line of work is written:

| Read | Bytes |
|---|---|
| `AGENTS.md` | 10,612 |
| `docs/about.md` (always) | 10,701 |
| `docs/technical/README.md` (before touching `tasks/` or `specs/`) | 56,671 |
| `.writrun/conventions/` commits + prs + branches (before committing / opening a PR) | 15,599 |
| `.writrun/settings.json` | 333 |
| the relevant `docs/product/` chapter | 3,000–14,000 |

That is ~97KB — roughly 22–25k tokens — per implementing session,
before the task, its specs, or any code is read. The trigger for this
report is the maintainer observing sessions slow down and token spend
grow as tasks and reviews take longer.

Where the cost concentrates:

- `docs/technical/README.md` is one 57KB file with nine `##` sections.
  A queue touch needs one schema section (~5KB), but the instruction —
  and the anchor granularity every reference uses — is file-scoped, so
  the whole file is what gets read.
- The `SKILL.md` files restate what their scripts compute.
  `writrun-select-next-task/SKILL.md` is 8,589 bytes of prose spelling
  out steps 0–7, and `list_tasks.sh` beside it is ~450 lines
  implementing exactly those steps; a session reads the prose *and*
  runs the script. `writrun-create-task-and-spec/SKILL.md` is 17,152
  bytes restating the schemas `technical/README.md#task-schema` already
  states, plus the triage table that `product/concepts/report.md` and
  `stage-1-tasks-and-specs/authoring.md` also carry — four copies of
  one table in the reading path.
- Several instructions are O(queue) for the reader: "read the
  front-matter of every task file" is 31 files today and grows with
  every task, while the lister already performs the same sweep for
  zero context cost.
- The mechanical flows are re-derived from prose each session: taking
  a task (branch name, push, draft PR, title grammar, template body)
  is composed step by step from three convention files; the completion
  gates are three separate scripts whose required ordering lives in a
  prose warning ("run it **after** step 4 and not before"); a task's
  brief is gathered by opening whole files to read one anchored
  section; and the conventions are re-read per session largely to
  recover values `settings.json` states in 333 bytes.

None of this is a defect in any one file — every piece is doing what
its rule says. The observation is that the sum grows with the project
itself (every new task, spec, and decision adds to it), so the cost
compounds precisely as the methodology is exercised. `about.md#personas`
already names the standard this strains: the AI agent persona "needs a
deterministic answer … that doesn't require reading the whole
repository to find out".

**Triage:** the reading path and the mechanical flows are one finding
about one property (the per-session cost of running the process) →
task-0034, carved into six specs.
