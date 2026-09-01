---
id: task-0027
status: in-review
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0037]
doc_ref: product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-31T14:48:46Z
queued: 2026-08-31T15:04:28Z
completed: null
merged: null
provenance: []
---

# An amendment in flight suspends the task, and the system names it

**References:** [product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request](../../docs/product/stage-2-pull-requests/statuses.md#an-amendment-under-an-open-pull-request) · [spec-0037](../specs/spec-0037-amendment-suspends.md)

A spec was amended while its task rode an open pull request, and for
five minutes the queue asserted that someone was working a task that
could not move: `in-progress`, `taken_by` set, nothing anywhere saying
the work waited on another pull request. Five minutes was that case's
number — the same shape with the maintainer asleep lasts a night. The
word for "stalled" is forbidden in flight, deliberately; the recording
machinery stays silent on such a merge, deliberately; and the selection
algorithm never re-reads the specs of a task already in flight. Every
exclusion is individually sound. Together they made the pause invisible.

The docs now state the rule the case was missing: the amendment moves no
status — flight belongs to the task's own pull request — but the task is
suspended, the suspension is derived from the authority branch and the
open pull requests together, and the amendment and the pull request it
suspends name each other, checked from Stage 2. Bring the machinery up
to it: the lister names a suspended task beside the pull request that
suspended it, the resume step re-checks authorization before advancing
resumed work, and the check fails an amendment that touches an in-flight
task's spec without naming that task's open pull request.

The union matters and is the part no shortcut survives: during the
amendment's open window the authority branch still shows the spec as it
was approved, so a reading of the files alone reports a healthy queue.
Only the forge's half shows the pause while it is happening — and at
Stage 1, where no forge exists, the suspended state persists in the
files themselves, and reading them alone is the whole answer.
