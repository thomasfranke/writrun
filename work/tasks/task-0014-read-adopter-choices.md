---
id: task-0014
status: done
blocked_reason: null
taken_by: null
spec_ref: [spec-0011]
doc_ref: technical/README.md#settings
origin: rule
priority: medium
depends_on: [task-0006, task-0008, task-0010, task-0013]
milestone: null
created: 2026-08-28T00:00:00Z
queued: 2026-08-28T23:01:30Z
completed: 2026-08-29T03:27:50Z
merged: 2026-08-29T17:15:35Z
provenance: []
---

# Read adopter choices from a settings file

**References:** [technical/README.md#settings](../../docs/technical/README.md#settings) · [spec-0011](../specs/spec-0011-read-adopter-choices.md)

The schema now says `.writrun/conventions/settings.json` holds the choices
Adoption leaves open, that both the machinery and the agents read it, and
that its shape is a checked contract. None of it exists: there is no file,
nothing reads one, and the values it would hold are still hardcoded across
four scripts.

Ship the file, give the scripts one reader to share, and add the check that
keeps its shape honest — so an adopter changes a rule by setting a value
instead of editing a script `writ update` will overwrite.

`depends_on` is real: three queued tasks already rewrite the label and
mirror logic this touches, and one rewrites id minting. Landing first would
force all four to be redone against it.
