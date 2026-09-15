#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The body this change's own pull request carries, as it carried it. A
# check whose first duty was to its own change is one the change had to
# be able to satisfy, and a real filled body is the only fixture that
# proves the whole reading at once: prose, nested bullets, fenced
# commands, inline `## ` spans in the middle of a sentence, and the two
# `writrun:` markers sitting between sections.
#
# A copy, deliberately, and not a mirror of the live pull request — the
# forge is not available to a test case, and a fixture that reached for
# it would be asserting the network. It ages into what it always was: one
# real body that passes.
setup
stub_forge
forge_pr_body 266 <<'MD'
## What

A new gate, `check_body_answers.sh`, refuses a pull request that is no
longer a draft when a section its body carries stands over nothing.
`writrun-check.yml` gains the job and `ready_for_review` — the event the
rule names, and the one type its trigger list did not hold.

One definition does the whole job: a section is **unanswered** when what
sits under its `## ` heading, with HTML comments and whitespace removed,
is empty. That is the seeded template comment and the bare heading at
once. What the body carries is read off the body, never from a list of
required headings, so deleting a section a change has no use for is the
honest way through. Every unanswered section is named in one run.

Both `AGENTS.md` texts — this repository's and the kit's, which are
deliberately different documents — gain the body as a step of
*Completing a task*, before "mark the pull request ready".

## Why

[#261](https://github.com/thomasfranke/writrun/pull/261) and
[#262](https://github.com/thomasfranke/writrun/pull/262) were marked
ready here with `## What`, `## Why` and `## How to test` holding nothing
but the comments the template seeded, and every completion gate ran green
over them. `take_task.sh` writes those headings at the taking — before
the work exists, so before any of them could be answered — and a unit
test confirms it writes them. Nothing ever asked whether they were
filled.

The rule was already written:
[`body.md#a-section-the-body-carries-is-a-section-it-answered`](https://github.com/thomasfranke/writrun/blob/main/docs/product/stage-2-pull-requests/body.md#a-section-the-body-carries-is-a-section-it-answered).
This change is the guard and the instruction, not the rule.

<!-- writrun:begin -->

## Spec

- [spec-0097](https://github.com/thomasfranke/writrun/blob/main/work/specs/spec-0097-ready-body-answered.md) — The gate on ready, and the step that names the body

## How to verify

`preflight.sh` exits 0 and `writrun-check-spec-deltas` reports the diff
matching spec-0097's promise: `technical/distribution/checks.md`,
`technical/decisions/pull-requests/0077-unanswered-has-a-signature.md`
and `technical/decisions/README.md`, and nothing permanent besides.

**Five divergences, all recorded in the spec's Outcome.** Two are worth
a reviewer's eyes:

1. **The unedited template refuses five of its sections, not all eight.**
   `## Derived work`, `## Spec` and `## Report` ship a placeholder bullet
   under them, and a bullet is visible text. Telling a placeholder from a
   real answer means reading the prose, which the spec's Scope rules out
   in the same breath it asks for this case. The definition was kept and
   `the_unedited_template_is_refused_test.sh` asserts the five the
   template really leaves empty — `## What`, `## Why`, `## How to
   verify`, `## How to test` and `## Notes`, which are the sections #261
   and #262 left standing.
2. **`checks.md` lost a number.** Its opening sentence said "five rules
   about *how* they are called"; this change adds two of them.

The other three: a draft state that is neither `true` nor `false` exits 3
rather than being guessed at; `tests/pipeline_lib.sh` gained a `gh pr
view` seam and now exports `FAKE_GH_LOG`, the name `harness.sh`'s
`forge_told` helpers read and which this fixture never paid; and the
branch merged `origin/main` mid-flight, so decision `0077` follows `0076`
in the index rather than `0075`.

## How to test

The new cases, and the neighbours the fixture change touches:

```bash
for f in tests/integration/stage-2/body_answers/*_test.sh; do bash "$f"; done
bash tests/run.sh
```

Expect every line `ok`, and the whole suite `503 case files passed, 0
failed` — 492 before this change, plus the eleven new cases. Budget the
usual six or seven minutes: `tests/e2e/release` runs `make release` for
real, and that runs the whole suite a second time inside itself.

Against the real forge, which is what CI will do. This pull request is
still a draft, so the first run proves the draft arm and the second
proves the reading half against a merged pull request whose body is
filled:

```bash
bash .writrun/scripts/stage-2-pull-requests/check_body_answers.sh thomasfranke/writrun 266
bash .writrun/scripts/stage-2-pull-requests/check_body_answers.sh thomasfranke/writrun 261
```

Expect `#266 is a draft — its body is not judged.` and `Every one of
#261's 6 sections is answered.`, both exit 0. Run over the last 40 pull
requests of this repository, the check refuses none of them — no body
this project has actually merged is judged wrong by it.

To watch it refuse, hand it the body this pull request had before this
commit — the template as `take_task.sh` seeds it:

```bash
bash tests/integration/stage-2/body_answers/the_unedited_template_is_refused_test.sh
```

Expect `## What`, `## Why`, `## How to verify`, `## How to test` and
`## Notes` each named, exit 1.

<!-- writrun:end -->

## Notes

The pull request template is deliberately unchanged. Its instructional
comments are what the check reads as the unanswered signature; tidying
them away would delete both the signal and the only instructions an
author meets at the moment they are writing. Decision
[0077](https://github.com/thomasfranke/writrun/blob/main/docs/technical/decisions/pull-requests/0077-unanswered-has-a-signature.md)
records that, why the headings are read off the body, and why the gate
binds at `ready` rather than at the taking.

This body is the rule it implements: every section it carries is
answered, every link absolute and on `main`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_011JcQXJ78Q6cKEzgKPaF6a1
MD

check "a body that answers every section it carries passes" 0 "6 sections" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 266

# The `## ` spans quoted inside its prose and inside its fences opened no
# section: six is What, Why, Spec, How to verify, How to test and Notes,
# and a seventh would mean the check had read a quotation as a heading.
refute "and nothing in it is reported as standing over nothing" "stand over" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 266

finish
