# Product doc

A product doc is **what a system does, rule by rule, in non-technical
language** — the source of truth an implementation is checked against, not
a description of the implementation itself. It lives in `product/`, one
chapter per concern, and is meant to be read in order, like a book: later
chapters use the nouns earlier ones establish and never redefine them. The
five `concepts/*.md` chapters — [About](about.md), this one, [Technical
doc](technical-doc.md), [Task](task.md), [Spec](spec.md) — come first for
exactly that reason, listed in reading order in
[`product/README.md`](../README.md#chapters).

## Who reads it

Anyone deciding **whether and how** a system should behave: a maintainer, a
tech lead, a stakeholder, an agent about to implement a task that touches
this behaviour. Not a reader who needs a schema, a file format, or an
algorithm to follow along — that reader is in [a technical doc](technical-doc.md)
instead.

## What earns a chapter

A rule that changes what the system does for someone using it. A choice
that only changes how the system is built internally, with no observable
difference in behaviour, is a technical decision, not a product rule —
it never gets a product chapter of its own.

## How a chapter is written

Prose first, criteria last:

- The body explains what a capability does and why, in the vocabulary the
  concept chapters already established — never repeating a neighbouring
  chapter, only referencing it.
- A chapter that asserts an observable, testable system behaviour closes
  with a `## Criteria` section: the same rules restated in EARS form
  (`When <trigger>, the system shall <response>`), so each one maps to at
  least one test.
- A chapter that is purely definitional, or that only narrates and defers
  the testable claim to a neighbouring chapter, has no `## Criteria` section
  at all. Forcing one onto a chapter with nothing testable to state produces
  a criterion nobody can fail, which is worse than no criterion.

The criteria, where they exist, are a checkable summary of the chapter —
never a substitute for it. A rule that appears only in the criteria list,
unexplained in the prose above it, is a rule nobody understands well enough
to implement correctly.

## Each rule is checkable

A reviewer — human or agent — reading any product chapter can answer "does
this repository comply, yes or no," without needing to interpret intent.
That is what separates a product doc from a pitch: [About](about.md)
explains why the project exists; a product chapter states what must be true
for it to be doing what it claims.

## When it changes

A product doc describes the system **as it is today** — never a plan, never
history. It changes in the two directions
[Pipeline](../pipeline/authoring.md#two-ways-a-permanent-doc-changes) names, and the
present tense holds in both:

- **Authoring** — a rule is decided and written down before anything
  implements it. No task precedes the change; the tasks derive from it, and
  they are named in the change that authors the rule. The chapter still
  states the rule as a rule: what records that the system has not caught up
  is the [task queue](task.md), never a hedge in the prose.
- **Loop closure** — a completed [task](task.md) whose [spec](spec.md)
  promised the change updates the relevant chapter in the same change that
  ships the behaviour, listed in that spec's **Proposed product changes**
  section. A product chapter never drifts from what the spec promised
  without the divergence being recorded in that spec's Outcome.

A chapter is written the same way either way. Nothing in its wording should
let a reader tell which direction it arrived from.
