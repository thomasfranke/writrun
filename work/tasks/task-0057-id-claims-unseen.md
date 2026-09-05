---
id: task-0057
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0081, spec-0079, spec-0080]
doc_ref: technical/schemas/task.md#task-schema
origin: report
priority: high
depends_on: []
milestone: null
created: 2026-09-05T13:48:35Z
queued: 2026-09-05T18:04:02Z
completed: null
merged: null
provenance: []
---

# Close the four ways a claim on an id goes unseen

**References:** [technical/schemas/task.md#task-schema](../../docs/technical/schemas/task.md#task-schema) · [spec-0081](../specs/spec-0081-mirror-holds-id.md) · [spec-0079](../specs/spec-0079-rename-is-seen.md) · [spec-0080](../specs/spec-0080-collision-is-named.md)

An id is unique across the queue and every open pull request, and it is
never reused.
[report-0031](../reports/report-0031-id-the-mirror-holds.md) found four
places where the machinery misses a claim on one, and a single blindness
under three of them: it reads what a change adds and what it modifies,
and a rename is neither.

An id whose file a branch dropped before merging is minted a second
time — the mirror is the only record that outlived the branch, and
nothing that allocates an id asks it. A change that renumbers a file to
free an id and then claims that id is refused as colliding with itself.
A renumbered file gets no mirror, so an id nobody can see is also an id
nobody can triage. And when the mirror answers a returning id by
reopening a triaged Issue, the run says nothing about it.

Make each of those four readers see what it is looking at.

Why it matters: the first fault has already corrupted an adopter's
Issue tracker. In `writrun-cli`, Issue #18 was triaged and closed; the
second mint of the same id reopened it and rewrote its `Introduced by`
row to name pull request #20 — a pull request that never mentioned the
finding the Issue's title and body describe. A maintainer reading that
tracker sees an open item, wrongly attributed, and nothing distinguishes
it from a real one. That is wrong data in the place this methodology
asks people to trust, in a project that has already adopted the kit,
and it is why this is `priority: high`.

Three specs, split by mechanism rather than by symptom, so each is
implementable alone:
[spec-0081](../specs/spec-0081-mirror-holds-id.md) gives the allocator a
record that survives a dropped branch,
[spec-0079](../specs/spec-0079-rename-is-seen.md) takes the two readers
that share the rename blindness — one line each — and
[spec-0080](../specs/spec-0080-collision-is-named.md) makes the run say
when the mirror answered an id that came back. Only the third depends on
nothing: the other two are independent of each other, and the third is
worth landing whether or not either has.
