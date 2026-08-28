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

When tooling needs these files machine-readably — a commit-msg hook
validating types and scopes, a PR opener checking the title rule — the
pattern is the same as everywhere else in WritRun: front-matter will
carry the data, prose the reasoning. One file, two audiences, nothing
duplicated.
