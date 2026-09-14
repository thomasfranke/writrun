---
id: spec-0097
task_ref: task-0069
status: draft
created: 2026-09-14T01:11:53Z
---

# spec-0097 — The gate on ready, and the step that names the body

**References:** [task-0069](../tasks/task-0069-ready-body-answered.md)

- **Goal:** A pull request cannot be marked ready over a section nobody
  answered, and the instruction an executor reads says the body is owed.

## Scope

- A new check, `.writrun/scripts/stage-2-pull-requests/check_body_answers.sh`,
  taking `<owner/repo> <pr-number>` like the other forge-reading gates.
- `.github/workflows/writrun-check.yml` — the job, and
  `ready_for_review` added to the `pull_request` types it listens for.
  Today it hears `opened, synchronize, reopened, edited`, so the one
  event the rule names is the one it misses.
- `AGENTS.md` and `.writrun/AGENTS.md` — *Completing a task* gains the
  body as a step, before "mark the PR ready".
- `kit/` follows from `make kit-sync`; `.writrun/` and the workflow are
  both carried by `tests/kit_mirrors.txt`. `AGENTS.md` at the repository
  root is **not** mirrored — the kit's is its own document — so that one
  is edited directly and the two texts differ on purpose.

**Out of scope.** The template is not changed: its comments are what the
check reads as the unanswered signature, so removing them would remove
the signal. Nothing reads the prose for quality — an answer of one word
passes, and that is correct, because the alternative is a gate
performing review.

## Steps

1. Read the body, split it into sections at `^## ` headings, and ignore
   everything outside them — the `<!-- writrun:begin -->` markers and any
   preamble.
2. A section is **unanswered** when what sits under its heading, with
   HTML comments and whitespace removed, is empty. That covers both
   shapes at once: the seeded comment is an HTML comment, and a heading
   over nothing is empty already.
3. Refuse with every unanswered section named at once, never the first
   one — a gate that reports one of four costs four round trips.
4. Pass on a draft without reading anything, and say that is why.
5. Add the step to both `AGENTS.md` texts.
6. `make kit-sync`.

## Acceptance criteria (EARS)

- When a pull request is not a draft and a section its body carries holds
  only comments or whitespace, the check shall refuse and name every such
  section.
- When a pull request is a draft, the check shall pass without judging
  its body.
- When a body carries a section whose answer is a single line, the check
  shall pass — content is the test, never length or quality.
- When a body omits a section the template ships, the check shall require
  nothing of it.
- When a body carries a section holding both the seeded comment and an
  answer beside it, the check shall pass: the comment is not the
  question, the emptiness is.
- When a pull request is marked ready for review, the workflow shall run
  this check on that event.

## Edge cases

- **A section whose answer is legitimately "none".** `## How to test`
  saying "nothing runnable ships here" passes, because it is text. This
  is the same reasoning that makes an authoring change write "none" under
  Derived work rather than leave it blank.
- **A fenced code block containing `## ` at line start.** Splitting on
  `^## ` would read it as a heading and invent an empty section. Fences
  are tracked, and a `## ` inside one is content.
- **An HTML comment carrying the answer.** Refused as unanswered, and
  correctly — a comment is invisible on the rendered page, so an answer
  written in one was never read by a reviewer.
- **A body with no `## ` headings at all** — someone replaced the
  template wholesale. Nothing is carried, so nothing is owed; the check
  passes and says it found no sections rather than passing silently.
- **The forge read failing.** It exits non-zero and says it could not
  look. A gate that reports "every section answered" without having read
  the body is the lie, not the exit code — the reasoning
  `check_queue_impact.sh` already states for itself.

## Tests required

- `tests/integration/stage-2/body_answers/` — one case per criterion
  above, using the existing seam for supplying a body rather than a live
  forge call.
- A case proving the refusal names **all** unanswered sections, not the
  first.
- A case with the repository's own template as the body, unedited, which
  must refuse every section it seeds — the regression closest to what
  happened on #261 and #262.
- A case with this pull request's own body, which must pass.
- The kit mirror unit test must pass with no new exception.

## Definition of Done

- [ ] A non-draft pull request with an unanswered section is refused, by
      the check and by CI on `ready_for_review`.
- [ ] Drafts pass unread.
- [ ] Both `AGENTS.md` texts name the body before "mark the PR ready".
- [ ] `make kit-sync` leaves the kit byte-identical, no new entry in
      `tests/kit_exceptions.txt`.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — the rule is already written.
  `body.md#a-section-the-body-carries-is-a-section-it-answered` and its
  two new criteria were authored by the change this task derives from.

## Proposed technical changes

- `technical/distribution/checks.md` — the new gate joins the list of
  what runs where; a check that runs in CI and is named in no chapter is
  one nobody can find when it refuses them.
- `technical/decisions/pull-requests/0077-unanswered-has-a-signature.md`
  — the record: why the headings are read off the body instead of a
  required list, why the template's comments are load bearing and must
  not be tidied away, and why the gate binds at `ready` rather than at
  the taking.
- `technical/decisions/README.md` — the index gains the record's line.

## Outcome

_(fill after execution)_
