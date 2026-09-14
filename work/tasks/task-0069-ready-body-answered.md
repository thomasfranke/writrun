---
id: task-0069
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0097]
doc_ref: product/stage-2-pull-requests/body.md#a-section-the-body-carries-is-a-section-it-answered
origin: rule
priority: high
depends_on: []
milestone: null
created: 2026-09-14T01:11:37Z
queued: 2026-09-14T11:41:53Z
completed: null
merged: null
provenance: []
---

# A ready pull request has answered the sections its body carries

**References:** [product/stage-2-pull-requests/body.md#a-section-the-body-carries-is-a-section-it-answered](../../docs/product/stage-2-pull-requests/body.md#a-section-the-body-carries-is-a-section-it-answered) · [spec-0097](../specs/spec-0097-ready-body-answered.md)

`body.md` now binds every section a body carries, not just `## How to
test`, and nothing enforces any of it. `take_task.sh` seeds the sections
and a unit test confirms the headings exist; no check asks whether they
were answered, and the moment the rule names — marking a pull request
ready — has no gate on it at all.

What has to exist: a check that reads a non-draft pull request's body and
refuses a section still holding its seeded comment or standing over
nothing, wired to the `ready_for_review` event `writrun-check.yml` does
not yet listen for.

**And the instruction that should have said so.** `AGENTS.md`'s
*Completing a task* lists four steps — implement, update the promised
docs, fill the Outcome and dates, run preflight — and the body is none of
them. Step 4 reads "mark the PR ready on nothing else", which is
literally true and is exactly how two pull requests were marked ready
over empty sections. The kit's copy carries the same four.

It matters because this is the second instance today of one shape: a rule
stated correctly in a chapter, and absent from everything the executor
actually reads (`report-0042` was the first). The difference here is that
the absence has a signature — the seeded comment survives verbatim — so
unlike the kit omission, this one is guardable rather than only
documentable.
