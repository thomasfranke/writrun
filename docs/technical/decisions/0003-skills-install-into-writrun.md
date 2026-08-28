# skills install into `.writrun/skills/`, not a top-level `skills/`.

**2026-08-21**

Matches the convention already live in both source projects
(swoop and TOM). Rejected: a dedicated top-level `skills/` — that shape is
right for a project shipping a skill as a *product feature to its own
users* (swoop's `bootstrap-taskfile` is the real example), which is not
what WritRun's four skills are; they operate the methodology on the
adopting project itself, the same role swoop's `.writrun/skills/` fills for
swoop.
