# derivation is reviewable before it is public.

**2026-08-22**

Two
pieces, one idea. First, the session default: when derivation runs
(authoring or tracking), the agent presents the derived tasks and specs
before opening the PR — the human reviews the queue a rule creates
while the feedback loop is still cheap; the declaration itself can say
"open directly", and the default is each adopter's to invert. Second,
the machinery honours draft PRs as the same idea on the forge: the
mirror and progress workflows skip open drafts and fire on
`ready_for_review` — a draft's tasks are not public queue entries yet,
and `status:in-review` would misname a PR nobody asked to review.
Alongside: **tracking is the third kind of change**, next to authoring
and implementing — work discovered mid-flight, already authorized by an
existing doc, entering as a `queue/short-name` PR that adds only tasks
and specs. The `queue/` prefix deliberately carries no `task-NNN` id at
the start: a tracking PR records work, it is not working it, and must
not read as in flight. Skill names ship with the `writrun-` prefix, the
same way swoop prefixes its own — the namespace collision the adoption
chapter used to push onto adopters is solved at the source.
