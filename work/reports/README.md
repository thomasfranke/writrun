# Reports — what was observed

**Findings, not commitments.** One file per report, named by id plus a
tiny subject slug (`report-0003-mirror-lag.md`), never renamed, never
moved. The concept, the statuses and the reason there is no `resolved`
are in [`concepts/report.md`](../../docs/product/concepts/report.md);
the front-matter schema is in
[`technical/README.md`](../../docs/technical/README.md#report-schema).

A report says something was seen. It does not say anyone will act on it
— that is what a [task](../tasks/README.md) is for, and a report becomes
one only if triage decides so.

## What earns a report

Anything you would otherwise say out loud and lose. The bar is
deliberately below a task's: a task needs work worth tracking, a report
needs an observation worth remembering.

State what was **observed**, with whatever evidence is at hand — the
error, the log excerpt, the four Issue numbers. What should be done
about it is triage's output, not the report's content.

## For agents

Record first, triage second. A report costs nothing to write and may
ride any change you already have open — you do not need a `report/`
branch to note something down, and waiting for one is how the finding
gets lost. That prefix belongs to the `tracked` route alone: routing a
report to the queue is what needs a change of its own, because the
merge of that pull request is the assent that the finding deserves the
work. The three ends that create no work — `authored`, `fixed`,
`declined` — ride like the recording does.

Use the generator rather than the schema from memory, **from the
repository root** — every path it reads and writes is relative to the
working directory, so run from here and it mints an id the queue already
holds into a `work/reports/` nested under this one, which no check and no
mirror ever looks at:

```bash
bash .writrun/skills/writrun-create-task-and-spec/new.sh report "<title>" \
  --slug <two-or-three-words> [--doc-ref path/to/doc.md#anchor]
```

It takes neither `--origin` nor `--priority` — a report has no origin of
its own, and it commits to no work. Triage's `tracked` route has a
generator too: `new.sh task --from-report report-NNNN` appends the new
task's id here and stamps the date. The other three ends are written by
hand, status and `triaged` together, and go through
[`writrun-check-front-matter`](../../.writrun/skills/writrun-check-front-matter/SKILL.md)
before the commit.

Do not select work from this directory. Reports are not queued work; the
[selection algorithm](../../docs/technical/README.md#task-selection-algorithm)
reads `work/tasks/` and nothing here.

Before triaging one, read the non-completed tasks: the same thing
reported twice is one piece of work, and the second report ends
`tracked` against the task that already exists.
