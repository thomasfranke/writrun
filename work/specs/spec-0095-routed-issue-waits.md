---
id: spec-0095
task_ref: task-0067
status: implemented
created: 2026-09-13T23:42:57Z
---

# spec-0095 — The kit's routing instruction names the label it waits on

**References:** [task-0067](../tasks/task-0067-routed-issue-waits.md)

- **Goal:** An agent routing a defect upstream learns, from the kit
  alone, that the issue it opened waits for a maintainer's label — so
  `routed` stops reading as arrival.

## Scope

One section of one shipped document: *When the defect is WritRun's* in
`.writrun/AGENTS.md`, which `tests/kit_mirrors.txt` carries whole, so
`make kit-sync` produces the kit copy and it is not edited by hand.

What the section is missing is two facts, both already decided and
neither shipped:

- the upstream issue writes nothing into the upstream `work/` on arrival
  — a maintainer applying `writrun:report` is the gate, and until then
  the observation is an issue and not a report;
- `routed` therefore records a **submission**, not an entry in the
  upstream queue, and the local report is complete at that meaning and no
  other.

**Out of scope.** Shipping `concepts/report.md` or `intake.md` into
`kit/docs/` is a larger question about what the kit teaches versus what
it references, and it is not answered here: the fix is the two sentences
where the agent already reads, and the pointer to the full chapter it
can follow.

Nothing about the upstream behaviour changes. The intake works; it was
observed working, minting `report-0041` within twelve seconds of the
label.

## Steps

1. Add the two facts to *When the defect is WritRun's*, after the
   sentence that ends the local report `routed`, and point at
   `concepts/report.md#routing-upstream` for the whole of it.
2. Say what follows from them for the reader who has just routed
   something: the ask is now the maintainer's, nothing local is owed, and
   a second report is how a routed finding that goes unanswered is
   raised again — never reopening the first.
3. Run `make kit-sync`.
4. Record the addition in `technical/distribution/kit.md`, in the passage
   that already names this exact failure mode.

## Acceptance criteria (EARS)

- When an agent reads the kit's instruction for routing a defect
  upstream, it shall find stated that the issue becomes a report only on
  a maintainer applying `writrun:report`.
- When that instruction states the local report ends `routed`, it shall
  also state that `routed` records a submission and not an entry in the
  upstream queue.
- When the instruction is followed to its end, it shall leave no step
  owed locally — the reader shall not be told to wait, poll, or follow
  up, because none of those is this project's to ask of an adopter.
- When `make kit-sync` runs, the kit copy shall be byte-identical with no
  new entry in `tests/kit_exceptions.txt`.

## Edge cases

- **The word count in the section is not the point, and shortening the
  rest to pay for the addition is refused.** The section is already the
  only place an adopter reads about routing; trimming what is there to
  make room would trade one omission for another.
- **This must not read as an instruction to chase the maintainer.**
  Naming the label is so the agent stops at the right place, not so it
  starts checking back — an instruction to poll would put a loop in
  every adopting project against a queue it cannot see.
- **The guard cannot catch a regression here.** `kit.md` already states
  it: *"a check for absence is not available — a concept the prose never
  mentions uses no retired word and shows no wrong shape."* The two
  ship-versus-names unit tests hold directory and skill names, and a
  missing sentence has no shipped counterpart. This spec adds no test
  that pretends otherwise, and says so in the record instead.

## Tests required

None that can be written honestly. The change is prose in a mirrored
file; the mirror unit test already holds the bytes, and the absence this
fixes is the documented blind spot above. Claiming a test here would be
the blindness `check_doc_shapes.sh` was built to end, one layer up.

## Definition of Done

- [ ] The section states both facts and points at the chapter.
- [ ] The kit copy is byte-identical after `make kit-sync`, with no new
      exception.
- [ ] `kit.md`'s omission-drift passage names this as the second instance
      of the failure it describes.
- [ ] `preflight.sh` exits 0.

## Proposed product changes

- none — `concepts/report.md#routing-upstream` already states the rule
  correctly. This change carries it across the mirror boundary; it does
  not decide anything new.

## Proposed technical changes

- `technical/distribution/kit.md` — extend the passage on what the
  ship-versus-names guard cannot see with this instance: the routing
  instruction shipped without the label it waits on, found only because a
  routed finding sat unread. The passage already argues that a check for
  absence is unavailable; what it gains is the second case, which is what
  makes the argument a pattern rather than an anecdote.

## Outcome

Done as planned. *When the defect is WritRun's* in `.writrun/AGENTS.md`
gains two paragraphs after the one that ends the local report `routed`:
the first says the issue writes nothing into the upstream `work/` until
a maintainer applies `writrun:report`, so `routed` records a submission
and not an entry in the upstream queue, and points at
`concepts/report.md#routing-upstream` for the whole of it; the second
says nothing is owed locally — no waiting, polling or following up — and
that a routed finding that goes unanswered is raised again by a second
report, never by reopening the first. `make kit-sync` produced
`kit/.writrun/AGENTS.md` byte-identical, with no new entry in
`tests/kit_exceptions.txt`. `technical/distribution/kit.md` gains the
second instance in the omission-drift passage, which is what turns its
argument into a pattern.

**The pointer is a URL, not a relative link.** The spec says to point at
`concepts/report.md#routing-upstream`, and the kit ships no such file —
`kit/docs/` carries only the two README skeletons and
`writrun-instructions.md`, so a relative path would resolve to nothing
in an adopting project. It is written as a link to the chapter in this
repository, the form `conventions/prose.md` already uses for the same
reason.

**No test was added,** as the spec required: the mirror unit test holds
the bytes, and the absence this change fixes is the blind spot `kit.md`
now documents twice.

