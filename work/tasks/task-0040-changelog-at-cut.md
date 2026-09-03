---
id: task-0040
status: in-progress
blocked_reason: null
taken_by: thomasfranke
spec_ref: [spec-0056]
doc_ref: technical/distribution.md#distribution
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-09-03T03:34:27Z
queued: 2026-09-03T03:45:30Z
completed: null
merged: null
provenance: []
---

# The release cut writes the changelog it publishes

**References:** [technical/distribution.md#distribution](../../docs/technical/distribution.md#distribution)

The release cut publishes notes to the forge and leaves the repository
with none. `.writrun/VERSION` says which tag a copy came from and
nothing says what that tag changed, so an adopter pinned to one — and
the `writ update` that will read the same stamp — has to leave the
checkout to answer the first question anyone asks of a version.

Make the cut write what it publishes: `CHANGELOG.md` at the root,
newest first, composed from the conventional subjects between the last
tag and the one being cut, staged with the two version stamps so a
single commit carries the number and what earned it.

The rule it derives from is `technical/distribution.md#distribution`,
authored in the same change that created this task. What matters beyond
convenience is the single writer: the file is generated at the cut and
never edited, because a changelog anyone may touch is a second history
that agrees with the tags right up until the first time somebody
forgets.
