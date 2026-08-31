# Commits

**Squash-only means the PR title is the commit that lands**, so the shape
of a commit subject is the shape [prs.md](prs.md) describes, and which of
the two it is comes from [`settings.json`](../settings.json)'s
`stage_2.pr_title_style`. This file covers the vocabulary each style uses.

Under `conventional` — [Conventional
Commits](https://www.conventionalcommits.org/), `type(scope): imperative
summary`:

- **Types**: `docs`, `feat`, `fix`, `refactor`, `chore`.
- **Scopes** (optional — omit when a change genuinely spans the
  repository): `about`, `product`, `technical`, `tasks`, `specs`,
  `skills`, `ci`, `tests`, `agents`.
- Example: `docs(product): add the coverage-rule concept chapter`.

Under `bracketed` — the same two vocabularies, capitalised inside
brackets, then a sentence: `[Docs][Product] Add the coverage-rule concept
chapter`.

Either way the `[TASK-NNNN]` tags come first and sit **outside** whichever
grammar follows. That is deliberate and costs nothing: nothing in this
project parses a subject — not the checks, and not the release notes,
which the forge generates from pull requests. History here is read by eye
and by `git log --grep`, and neither is a strict parser.

- Trivial work is a commit, never a task (principle 6).

The one commit the machinery makes — `writrun approve` recording what a
merge decided: the specs it approved, and the `queued`/`merged` dates it
earned — has its title as a variable in `writrun-approve.yml`; edit it to
match whatever this file says. It is one commit because it records one
event.

## Who presses commit — `stage_1.auto_commit`

`true`, the default, lets an agent commit on its own as its flow requires.
`false` gates the action and never the work: the agent still composes the
**whole** message — subject, body, trailers — presents it, and commits only
after an explicit yes. Approval is per commit; several in one working
session are several asks, never one session-wide grant.

**The flag outranks the agent platform's own autonomy mode.** An agent
running auto-accept, autonomous, or any mode in which its harness would not
ask, still stops here: the platform's mode governs what the *harness* asks,
this flag governs what the *adopter* allowed. A setting that only bound an
agent already asking would control nothing.

Neither this flag nor `auto_pr` touches the machinery's own commit above,
nor any workflow-driven write — those are not an agent's actions.

## Whether the agent signs — `stage_1.credit_ai`

`true`, the default, leaves an agent's commits carrying whatever credit its
platform appends: a `Co-Authored-By:` trailer, a session link, a
generated-with line. `false` means the message carries the change alone —
no co-author trailer, no session URL, no tool mention; it reads as any
other in the history. An instruction from the agent's own platform to
append credit yields to this file, with the same precedence `auto_commit`
states.

The flag speaks only to what an agent writes. Authorship and committer
identity stay git configuration, nobody else's commits are touched, and
nothing rewrites history — it binds from the commit after the flip.
