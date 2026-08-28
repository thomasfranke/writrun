# Commits

[Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): imperative summary`.

- **Types**: `docs`, `feat`, `fix`, `refactor`, `chore`.
- **Scopes** (optional — omit when a change genuinely spans the
  repository): `about`, `product`, `technical`, `tasks`, `specs`,
  `skills`, `ci`, `tests`, `agents`.
- Example: `docs(product): add the coverage-rule concept chapter`.
- Squash-only means the PR title is the commit that lands, so an
  implementing change's subject opens with its `[TASK-NNNN]` tags and the
  `type(scope):` follows them — see [prs.md](prs.md). The prefix is
  deliberately outside Conventional Commits' grammar: this repository
  reads its history by eye and by `git log --grep`, and neither is a
  strict parser.
- Trivial work is a commit, never a task (principle 6).

The one commit the machinery makes — `writrun approve`'s recording flip —
has its title as a variable at the top of `writrun-approve.yml`; edit it
to match whatever this file says.
