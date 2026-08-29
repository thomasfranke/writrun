# Conventions

The adopter-editable layer: how this project writes commits, branches,
pull requests, tasks, and specs.

**Every file here is the project's to edit.** WritRun ships them as
defaults and its machinery reads none of them — mechanics depend only on
the grep-level markers listed in WritRun's
[public contract](https://github.com/thomasfranke/writrun/blob/main/docs/technical/README.md#distribution).
Agents read these before writing; tooling (a commit-msg hook, a PR
opener) validates against whatever they say.

| | |
|---|---|
| [Commits](commits.md) | Conventional Commits — types, scopes, examples |
| [Branches](branches.md) | Naming per flow, and the id marker the machinery reads |
| [Pull requests](prs.md) | Title rule, template, merge policy |
| [Tasks](tasks.md) | Title, body, priority and milestone taste |
| [Specs](specs.md) | Title, criteria, scope and Outcome taste |

One rule spans them all in this repository: **English everywhere** —
code, comments, commits, documentation.

Tooling needs these choices machine-readably — the scripts already act on
some of them — so the data lives in [`settings.json`](settings.json) and
these `.md` files carry the reasoning: what the options are and why a
project would pick one. **Nothing is stated in both.** A value here that
also sits in the settings file is a value that will eventually disagree
with itself; if you find one, the settings file wins and the prose is the
bug.

That split was always the plan; the file is JSON rather than the
front-matter this once predicted, because it is edited by people who have
not read WritRun's front-matter contract and JSON is the shape they
already know. See
[`decisions/0052`](../../docs/technical/decisions/0052-settings-carry-the-choice.md).
