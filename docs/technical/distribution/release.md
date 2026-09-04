# Release

**The public contract, the version that measures it, and the cut that records it.** One chapter of [`distribution/`](README.md).

## The public contract and the release

**Skills are the plumbing; a CLI is welcome porcelain — in its own repo.**
Nothing above forbids a human-facing command line (`writ list`,
`writ init`, `writ doctor` — the binary is `writ`, per About); it forbids
the methodology *depending* on one. A CLI lives in a separate repository (`writrun-cli`), wraps the
same scripts and files, and everything here keeps working without it —
agents use skills, CI uses scripts, files stay the authority. What tooling
like that builds on is this file's **public contract**: the task and spec
front-matter schemas, the `docs/` + `work/` split, each script's arguments
and exit codes, and the handful of grep-level markers the machinery reads
— the `## Derived work` heading in a PR body, the two Proposed-changes
headings in a spec, a task file's `# ` title line, a `task-nnn` /
`spec-nnn` id at the start of a branch name, and the labels the machinery
owns and filters on: `writrun:task`, the `status:*` values
(`proposed`, `backlog`, `ready`, `in-progress`, `in-review`, `blocked`)
and the `origin:*` values (`rule`, `report`)
— renaming any of these means adapting the workflows. One carve-out runs the other way:
`docs/writrun-instructions.md` is process metadata, not project truth —
no task derives from it and every check ignores it. **Everything else about
commits, pull requests, and task/spec style is the adopter's convention,
not the methodology's**, and it lives in one editable folder at the
repository root — `.writrun/conventions/`: commit types and scopes, branch naming,
the PR title rule, the merge policy, task and spec taste. The one commit
the machinery makes has its title as a variable at the top of
`writrun-approve.yml`, and the PR template ships as an editable default
alongside. Versions are tags on `main`
(the first: `v0.0.01`, and the third field stays two digits) — everything merges to `main` continuously, and a
version exists when its tag does. The number measures this contract, not
the code, and it is computed, never typed: `make release` cuts one, with a
vocabulary that is deliberately WritRun's own rather than SemVer's —
`minor` bumps the third digit (the default), `major` the middle one,
`epoch` the first, reserved for historic milestones. The target derives
the next number from the latest tag, stamps it into `.writrun/VERSION` —
the kit carries the stamp, so an adopter, and the future `writ update`,
knows which tag a copy came from — syncs the template, runs the suite,
and only then commits, tags, pushes, and publishes the GitHub Release
with notes generated from the conventional commits. While the methodology
is alpha (0.x), the contract itself moves without notice; a client or an
adopter pins the tag it targets.

**The history lands in the repository, not only on the forge.** The cut
writes the release's own notes to `CHANGELOG.md` at the root, newest
first, and stages them with the two version stamps so one commit carries
the number and what earned it. The reason is the tag: a WritRun clone
holds a copy of one, and asking what changed since the tag before it
should not require leaving the checkout for the Releases page. The kit
does not carry the file: an adopter has the `.writrun/VERSION` stamp,
and still makes that trip. The entries are the conventional subjects on
`main` between the two tags, which is the material the forge's generated
notes already read; what changes is where a reader finds them.

**It is generated, and never edited by hand.** One writer — the release
script — is what keeps the file from becoming a second history that
agrees with the tags until the first time somebody forgets. An entry
that is wrong is wrong in the subject that produced it, and that is
where it is fixed, on the next tag. The file is not a permanent doc:
nothing under `docs/` changes when it is written, no spec promises it,
and `writrun-check-spec-deltas` never asks about it.


