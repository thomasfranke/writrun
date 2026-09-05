---
id: task-0056
status: backlog
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: null
origin: report
priority: low
depends_on: []
milestone: null
created: 2026-09-05T13:37:51Z
queued: null
completed: null
merged: null
provenance: []
---

# A mirror links the file it mirrors

A mirror's opening sentence names the file it mirrors; the link on that
name shall reach that file. Today it reaches the pull request's
changed-files view, for both task and report mirrors.

It matters because that sentence is how a mirror says where the
authority lives — the Issue is a projection and the file is the record.
A link that lands on a nine-file diff makes the reader do the lookup the
sentence exists to save, and the more the change carries, the worse it
reads.

The file is not on `main` while the pull request is open, so the route
the link takes before the merge is the spec's to decide, along with
whether the mirror is rewritten once the file lands.
