# Commits

**Squash-only means the PR title is the commit that lands**, so the shape
of a commit subject is the shape [prs.md](prs.md) describes, and which of
the two it is comes from [`settings.json`](settings.json)'s
`pr_title_style`. This file covers the vocabulary each style uses.

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
