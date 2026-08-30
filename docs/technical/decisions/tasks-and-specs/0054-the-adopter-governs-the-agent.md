# the adopter's settings govern the agent's git conduct.

**2026-08-30**

Whether an agent commits on its own, opens pull requests on its own, and
signs its commits with its platform's credit were decisions nobody in the
adopting project ever made: they arrived as defaults of whatever agent
platform the session happened to run in, and changed when the platform
did. For a methodology whose whole claim is that the project's files are
what an agent obeys, the agent's own git conduct was the one behaviour no
file spoke to.

Three booleans in `.writrun/settings.json` now speak to it: `auto_commit`
and `credit_ai` in `stage_1` (commits exist for every adopter), `auto_pr`
in `stage_2` (pull requests begin there). All three default `true` — the
behaviour from before the keys existed, which is what a documented
default is.

**`false` gates the action, never the work.** The agent still composes
the full commit message, or the pull request's complete title and body —
then presents it and acts only on an explicit yes, one approval per
action. A flag that made the agent stop *working* would just move the
composition cost onto the human it was asking; the point is a hand on the
lever, not a slower agent. `credit_ai: false` is the same shape applied
to attribution, and it covers everything the agent writes — commits and
pull request bodies alike: the change alone, no co-author trailer, no
session link, no tool mention. Half-covering (a clean commit under an
advertising pull request) would strip the record while keeping the
billboard.

**The flags outrank the platform's own autonomy mode.** An agent in
auto-accept still stops at `auto_commit: false`; a platform instructed to
append its credit trailer still omits it at `credit_ai: false`. The
platform's mode governs what the *harness* asks; these flags govern what
the *adopter* allowed — a setting that only bound an agent already asking
would control nothing, and 0052's rule stands: a setting controls, it
never merely describes.

The keys are read by agents only, so strictness stays scoped as 0052 set
it: value-checked, never shape-parsed, and the conduct itself is prose
the conventions carry (`commits.md`, `prs.md`) — not machine-judged, per
[0028](0028-acceptance-criteria-are-not.md). The machinery's own commit
and the workflows' pushes are outside all three flags: they are not the
agent's actions, and a flag that could switch off the queue recording
would be a switch on something Adoption lists as core.

Rejected: one `autonomy` enum covering both actions, which forces the
adopter who wants auto-commit but gated PRs to pick a lie. Rejected: an
`ai` section outside the stage split, which would make the newest keys
the first exception to the shape [0053](0053-settings-at-the-root.md)
just bought. Rejected: defaulting to `false` as the safer posture — it
would flip every existing adopter's pipeline to asking, and the reader's
defaults exist precisely to keep a project without the key behaving as
it did.
