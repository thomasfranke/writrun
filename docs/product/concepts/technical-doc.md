# Technical doc

A technical doc is **how a system is built** — architecture, subsystems,
testing, the machinery underneath a product rule. It lives in `technical/`,
developer- and agent-facing, and answers "how" for a reader who already
knows "what" from [a product doc](product-doc.md).

## The link-don't-restate rule

A technical doc never states a product rule — it links to the chapter that
owns it and explains the machinery underneath. When the two disagree, the
product chapter states the intent and the technical section is what is
wrong. This is the one rule that keeps the audience split from collapsing
back into one document trying to serve two readers: the moment a technical
section starts explaining *what* the system does instead of *how*, it has
duplicated a product rule, and duplicated rules drift independently the
first time only one copy gets updated.

## Where decisions live

Each technical subsystem carries the record of *why* it is built the way it
is: dated, append-only entries stating the choice and the alternative
rejected. A decision that changes gets a new entry below the old one, never
an edit to the original — the record of what was once true is as valuable
as what is true now.

A project may organize this per-subsystem (one `decisions.md` file per
technical section), as a single chronological log across the whole
project, or as **one file per decision** — numbered in the order taken,
with an index carrying the chronology. All three are legitimate, and the
third earns its extra files only once a log grows past what anyone
re-reads: it makes appending an entry a new file rather than an edit to a
file every other change also appends to. Whichever shape, the number or
filename is identity — never reused, never renumbered, and a superseded
decision keeps its place while the entry replacing it names it.
[Adoption](../adoption.md) covers when the choice needs to be written
down as a decision itself.

## Normative sections

A project may designate specific technical sections as **normative** —
binding on every change, not just descriptive of the current one (typical
candidates: architecture, testing). Deviating from a normative section
requires a dated decision entry stating why, in the same change that
deviates — never a silent exception. A technical section that is not
normative is free to describe current practice without that requirement;
a project states, in its own `technical/README.md` or equivalent, which
sections it holds to the higher bar.

## Who reads it

Whoever builds on the system or extends it: a developer, an agent about to
implement a task's spec, a contributor evaluating whether to adopt the
project's architecture elsewhere. Not a stakeholder deciding product
direction — that reader belongs in `product/` instead.

## When it changes

Like a product doc, a technical doc describes the system **as it is
today**, and changes in the same two directions
[Pipeline](../stage-1-tasks-and-specs/authoring.md#two-ways-a-permanent-doc-changes) names: it is
**authored** when a decision is taken before anything implements it, and it
**closes the loop** when a completed [task](task.md) whose [spec](spec.md)
listed the change in its **Proposed technical changes** section updates the
relevant section in the same change that ships the machinery.

One asymmetry with a product doc: the [decision
record](#where-decisions-live) is append-only, so a decision is authored by
adding the next entry, never by editing an earlier one to match what was
later chosen. A superseded decision stays where it is.
