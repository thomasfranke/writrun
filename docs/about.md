# About WritRun

> **What is written, runs.** A documentation methodology where docs are the
> executable source and code is the derived artefact — split by audience
> (business vs. engineering) and by nature (permanent state vs. work in
> progress), designed to be read and acted on directly — by the team's
> developers and by AI agents alike.

## Why "WritRun"

A **writ**, in its oldest sense, is simply *the written* — from Old English
*wrītan*, "to write". In law, it narrowed to something more specific: a
formal written instrument, issued by a competent authority, that compels an
act — *writ of mandamus*, *writ of habeas corpus*. In medieval common law, no
writ meant no remedy: the writ was the document that both authorized and
bounded the action that followed it.

That is the exact relationship this methodology assigns to documentation: the
doc is written by a human, and everything downstream — the task, the spec,
the code — exists only because the doc authorized and bounded it. **Run** is
the other half: the doc doesn't just sit as reference, it executes, driving
agents through the pipeline without being re-explained each session.

The project and the repository are **WritRun**. The optional command-line
client — its own repository, `writrun-cli`, never a dependency of the
methodology — ships a binary named `writ`: the short form, the same way
`kubectl` shortens Kubernetes.

What this project is, who it is for, and what it refuses to become — the
context every audience needs before the documentation forks between business
and engineering.

**This file stays short and stable.** Structural detail belongs in
[`product/`](product/README.md); implementation detail belongs in
[`technical/`](technical/README.md). If this file starts growing, something
that belongs in one of those is in the wrong place.

## Where to find what

| | |
|---|---|
| [`product/`](product/README.md) | **What the methodology does**, rule by rule, in non-technical language. The source of truth a project's adoption is checked against. |
| [`technical/`](technical/README.md) | **How it is built and distributed.** File formats, the selection algorithm, the skills and their scripts, and dated decisions. |
| [`work/tasks/`](../work/tasks/README.md) | **The queue.** What is being worked on for this project itself. |
| [`work/specs/`](../work/specs/README.md) | **The detail of one change.** Historical record — not a description of the present. |

This project dogfoods itself: its own tree follows the structure it ships —
`docs/` is the permanent half, `work/` is the queue.

## The pipeline

```
docs (human) → task (request) → spec (elaboration) → code (derived)
      ↑                                                    │
      └──────────── proposed changes, same change ─────────┘
```

Permanent documentation is written by humans, with human review. Everything
downstream is derived, with human gates: a **task** is the request — a
tracked slot in the queue with no technical detail; a **spec** is its
elaboration — the full brief for one change, belonging to exactly one task.
The task always precedes the spec. A ready task is a complete brief
whichever door it goes through — to a developer on the team, or to an AI
agent — and the pipeline never assumes which. An agent that finds work
without a task creates the task first; a spec never exists as an orphan.

The flow is a loop, not a line. A spec names every permanent doc its
finished change will touch, and the diff that completes the task must touch
all of them — so the docs it was derived from stay true to what shipped.
Drawn in full, with the human gates on it, in
[`product/tasks-and-specs/README.md`](product/tasks-and-specs/README.md).

## Vocabulary

Five things carry the whole domain, and both `product/` and `technical/` use
them without redefining them:

- **About** — the shared context every audience reads first. What the project
  *is*. Stays short; never restates product or technical detail.
- **Product doc** — what a system does, rule by rule, in non-technical
  language. Stakeholder-facing. The source of truth an implementation is
  checked against.
- **Technical doc** — how a system is built. Developer- and agent-facing.
  Never restates a product rule — links to it and explains the machinery.
- **Task** — a tracked unit of work: what to do, when, what blocks it. Holds no
  technical detail. The request that precedes its spec(s).
- **Spec** — the detail of one change: scope, steps, EARS acceptance criteria,
  edge cases, proposed deltas to the permanent docs. A support artefact with
  no order of its own; it inherits both from its task.

> Adopters will have their own domain vocabulary layered on top of these five.
> The methodology doesn't own the adopter's nouns — only the shape their docs
> take.

## Current state

Extracted from two live projects — [swoop](https://github.com/thomasfranke/swoop)
and [TOM](https://github.com/thomasfranke/tom) — after the structure had
already been designed and, in swoop's case, was about to be exercised end to
end. Nothing here is theoretical: every rule below traces back to a concrete
problem hit while building one of those two.

**Pre-extraction, partially resolved.** The structure exists today as
duplicated documentation inside swoop and (partially) TOM. This repo's
`product/` chapters — the prescriptive, checkable rules an adopting project
is judged against — are now written, extracted from swoop's mature (though
never-executed) pipeline and TOM's partial, structurally divergent
adoption. Neither swoop nor TOM has been migrated to actually consume this
repo yet — that remains the first milestone for each of them, separately.

## Why this exists

Two trends are colliding and most teams are handling the collision badly:

- **AI agents increasingly write the code.** When that's true, the bottleneck
  moves upstream — to specification. A vague prompt produces vague code;
  precise, checkable documentation produces code an agent can be trusted to
  write with less supervision.
- **"Spec-driven development" is becoming a crowded claim** (GitHub Spec Kit,
  Kiro, and others) without a shared definition of what "spec" means or how it
  relates to the rest of a project's documentation. Most implementations treat
  spec as the *only* artefact, collapsing product intent, technical design,
  and task tracking into one file that tries to serve three audiences at once.

**The gap this fills**: a documentation structure where the temporal split
(permanent state vs. work in progress) is structural — `docs/` holds what
is true, `work/` holds what is pending, and an agent never guesses which
of the two it's reading — and where the audience split (business vs.
engineering) is a rule about files: product intent and technical design
never share one. Inside `docs/`, the shape belongs to the project's
stakeholders; the methodology prescribes paths only under `work/`, and
everything under `docs/` is the input tasks are created from.

## Principles

1. **Docs are the input, not the output.** Behaviour is written down before it
   is implemented. Code is checked against documentation, not the other way
   around.
2. **Audience split is structural, not stylistic.** Product and technical
   documentation are different files, for different readers, updated on
   different triggers — never sections of the same document.
3. **Permanent and ephemeral never mix.** `docs/` describes the system as
   it is today; `work/` describes changes in flight — the split is
   structural, at the repository root. A finished spec is history, not
   documentation.
4. **Identity is never order.** An id (`task-0005`, `spec-0011`) is permanent.
   Priority, sequencing, and status live in mutable fields, so reprioritising
   never touches a filename.
5. **No drift by construction, not by discipline.** A completed unit of work
   updates the permanent docs in the same change — enforced by a checklist
   (the proposed delta), not left to whoever remembers.
6. **Trivial work stays out of the system.** A typo or a one-line fix is a
   commit, not a task. The structure exists for work that justifies tracking;
   forcing everything through it cheapens what it's for.
7. **Human gates are explicit, not implied.** The pipeline is automated by
   default, but every point where a human must approve — and there is at
   least one — is named in `AGENTS.md`, never assumed.

## Personas

- **The solo maintainer or small team adopting AI-assisted development** —
  wants agents to implement features correctly without re-explaining context
  every session, and wants documentation that stays true after the agent is
  done.
- **The developer on a team that adopted it** — receives a task whose brief
  is complete and already assented to, without having sat in the
  discussions that produced it. The task reads the same whether it was
  routed to them or to an agent.
- **The open-source maintainer building a community roadmap** — wants
  contributors to propose and pick up work from the repository itself, without
  standing up a separate paid issue tracker.
- **The AI agent** — needs a deterministic answer to "what should I work on
  next" and "what is true about this system today" that doesn't require
  reading the whole repository to find out.
- **The token contributor** — has compute and an agent, not context. A
  ready task carries a complete brief a human already assented to, and the
  checks run for any fork with no secrets — so pointing an agent at the
  queue, and paying its tokens, is a whole contribution. Their bottleneck
  is compute, never "how much of this project do I understand"; curation
  stays with the maintainer, which is the price of the gates and the point
  of them.

## Non-goals — equally important

- **Not a project management tool.** No board, no notifications, no
  assignment — GitHub Issues or any tracker can sit on top of this as a mirror,
  but the methodology doesn't compete with them.
- **Not a replacement for ADR tooling or numbered decision logs**, if a team
  already has one that works. This methodology's decisions-inline-per-subsystem
  choice is a default, not a mandate.
- **Not a spec format war.** It doesn't claim EARS or Gherkin are the only
  valid acceptance-criteria notation — they're the default because they map
  cleanly to test names, not because alternatives are wrong.
- **Not tied to one language, framework, or agent platform.** The structure
  makes no assumption about what's being built underneath it.
