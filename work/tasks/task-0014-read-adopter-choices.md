---
id: task-0014
status: pending
blocked_reason: null
spec_ref: [spec-0011]
doc_ref: technical/README.md#settings
priority: medium
depends_on: [task-0006, task-0008, task-0010, task-0013]
milestone: null
created: 2026-08-28
completed: null
---

# Read adopter choices from a settings file

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
