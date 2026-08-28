# acceptance criteria are not judged by a model, and CI does not run the adopter's tests.

**2026-08-22**

An LLM returns a *judgement*, and what
acceptance criteria need is a *guarantee*: non-deterministic, billed per
pull request, and dependent on an API key a documentation methodology
should not require — against which "it usually gets it right" is not the
standard a merge gate is held to. Rejected on a second count too: **CI
here verifies the methodology, not the code.** An adopting project already
runs its own suite in its own pipeline when the pull request opens;
whether the code works is that pipeline's answer, and WritRun neither
duplicates it nor stands in for it. What remains unsolved is real —
nothing mechanically ties an EARS criterion to the thing that proves it.
The shape that would: each criterion carries a reference to the test that
proves it (or an explicit not-testable marker with a reason), and a check
requires every criterion to have one, requires the referenced test to
appear in the diff that introduces the criterion, and requires the
adopter's suite to report it passing. Its real gain is not the gate but
the timing — a criterion with no plausible test is caught at spec
approval, before implementation, rather than at merge. Not built: it
changes the spec schema and needs a portable way to read pass/fail across
test runners, and neither is worth designing before an adopting project
has exercised the rest of this.
