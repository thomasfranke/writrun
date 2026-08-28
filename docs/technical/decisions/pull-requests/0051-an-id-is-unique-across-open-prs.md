# an id is unique across open pull requests, not just across a branch.

**2026-08-28**

`new.sh` mints the next id from the filesystem plus *this branch's* git
history. Two authoring branches cut from the same `main` therefore both
see the same highest id and both claim the next one, and neither can
tell. It happened the day the rule was written: two branches minted
`task-0009` within minutes, and the collision was caught by hand rather
than by anything in the machinery.

The hazard was already anticipated — in the wrong place.
`mirror_issues.sh` carries an id-collision guard with a test behind it
("already mirrored by a different PR — id collision; not touching it"),
so the *mirror* refuses to adopt a stranger's id while the *generator*
that hands one out never asks.

The answer follows the split [0010](0010-ci-splits-into-a.md) already
drew between a best-effort convenience and a mandatory guarantee.
Prevention is best-effort: `new.sh` consults open pull requests when a
forge is reachable and mints above what they claim, degrading to today's
behaviour — and saying so — when it is not. That is the same posture
`list_tasks.sh` already takes to report work in flight, so it adds a
pattern the project has rather than a dependency it lacks. Detection is
mandatory: `writrun check` rejects a change that adds a queue id the base
branch or another open pull request already claims. Prevention makes the
collision rare; detection makes it impossible to merge.

This needed one clarification to an existing rule, now in the schema: a
number claimed by an unmerged branch **is not yet an id**, so renumbering
it breaks nothing. Identity begins at the merge that puts the file on the
authority branch — "never renumbered" binds from there, not from the
moment a generator printed a number.

Rejected: reserving an id by pushing to `main` before starting, which
contradicts everything reaching the authority branch through a pull
request. Also rejected: ids that cannot collide — a timestamp, a hash, a
random suffix — which buy uniqueness by destroying the readability that
made four sequential digits worth having.
