---
id: task-0031
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0043]
doc_ref: technical/README.md#report-schema
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-01T13:51:01Z
queued: 2026-09-01T14:36:27Z
completed: 2026-09-01T20:34:41Z
merged: null
provenance: []
---

# The machinery learns the report kind

**References:** [technical/README.md#report-schema](../../docs/technical/README.md#report-schema) · [spec-0043](../specs/spec-0043-report-kind.md)

[0064](../../docs/technical/decisions/tasks-and-specs/0064-a-report-is-an-artefact.md)
made a report an artefact: `work/reports/`, `report-NNNN`, a status that
records which route triage took. The docs now describe all of it. None
of it exists.

The machinery knows exactly two kinds, and each of the three places that
matter has to learn a third: the **generator** cannot mint a report id,
the **gates** do not recognise one when they see it, and the **mirror**
does not project reports into Issues — which is the half that decides
whether the feature is used at all, because an `open` report nobody is
shown is a report that rots.

It matters because the gap is the wrong way round. A permanent doc
leading its implementation is normal here; a doc describing a file kind
that no tool can create means the first person to follow the docs writes
`work/reports/report-0001-x.md` by hand, gets the front matter subtly
wrong, and finds out when a check that never heard of reports says
nothing at all.
