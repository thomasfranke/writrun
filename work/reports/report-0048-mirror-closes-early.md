---
id: report-0048
status: tracked
task_ref: [task-0074]
doc_ref: product/stage-3-github-issues/labels.md#the-report-mirror
created: 2026-09-17T20:03:55Z
triaged: 2026-09-18T17:12:19Z
---

# A report's mirror closes on the pull request's copy of the file, before the merge

**References:** [product/stage-3-github-issues/labels.md#the-report-mirror](../../docs/product/stage-3-github-issues/labels.md#the-report-mirror) · [task-0074](../tasks/task-0074-mirror-waits-for-merge.md)

Issues #268 and #269 — the mirrors of report-0045 and report-0046 —
closed *completed* on 2026-09-17, twenty-two seconds after the pull
requests that triage those reports opened (#273 at 19:48:12Z, the
close at 19:48:34Z). Neither pull request had merged; both were still
open when this was written, and the authority branch held both files
`status: open`. The lister, reading `main`, listed all three reports
under `Open reports` while the forge showed two of them closed.

The mirror job runs on `pull_request_target` and reads the pull
request's copy of the file, which says `authored`, so it takes the
close the table in `labels.md#the-report-mirror` reserves for *"triaged,
and out of the pipeline"*. The same table gives a task's mirror
`status:proposed` for exactly this window — *"proposed by an open pull
request — not on the authority branch yet"* — and a report born in a
diff gets it too; a report whose **triage** is proposed by an open pull
request gets the close instead.

What it costs: the one state the mirror exists for is `open` — *"a
report nobody is prompted to read is a report that rots"* — and a pull
request that is never merged leaves the file `open` on `main` with no
Issue asking anyone to read it. The two channels the concept relies on
disagree for as long as the pull request is open, and permanently if
it closes unmerged.

Observed while triaging report-0044 to report-0047 in this session;
not investigated further. Whether the mirror should hold
`status:proposed` for a triage still in flight, or close only on the
merge that lands the status, is triage's question.
