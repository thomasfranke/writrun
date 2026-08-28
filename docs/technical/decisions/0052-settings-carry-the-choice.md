# adoption is levelled, and settings.json carries which level.

**2026-08-28**

WritRun was all-or-nothing. Every doc assumed branches, pull requests, CI and
the Issues mirror, so a project wanting only the docs-and-queue discipline had
no stated path — and read 31K of pipeline describing machinery it would never
run. The methodology was more invasive than it needed to be.

Adoption becomes three ordered levels — `docs`, `flow`, `mirror` — each
adding to the one before. `docs` is the existing minimum bar and a complete
adoption: the audience split, the queue, the schemas and the four gates are
all satisfiable with files alone. The higher levels add *mechanical
enforcement* of what a person otherwise does deliberately.

One ordered value rather than three switches, because the levels are
cumulative: `mirror` without `flow` would ask for a projection that
pull-request events drive, with no pull requests to drive it. A shape that
cannot express the incoherent case needs no check for it.

**The four human gates stay core at every level.** A gate has always asked
for *a human decision, recorded*, never for a pull request specifically. At
`docs` a person performs each directly and names how in their `AGENTS.md`,
which Adoption already requires of every adopter. No check can verify that,
which is why the schema states it: `level: docs` is not permission to drop
them.

**Where the choice lives.** `.writrun/conventions/settings.json` — values
only, no prose, read by both the machinery and the agents. In `conventions/`
because that folder is the project's from adoption onward and `writ update`
never touches it; [0024](0024-generated-shapes-resolve-in.md) keeps it out of
the repo root. `.writrun/conventions/README.md` predicted this split —
"front-matter will carry the data, prose the reasoning" — and the split is
exactly that. The carrier is JSON instead, because the file is edited by
developers opening an unfamiliar repository, and JSON is the shape they
already know.

**JSON without a JSON parser**, by the answer
[0035](0035-canonical-front-matter-is.md) gave for YAML: not a parser, a
canonical shape that is checked. Flat object, one `"key": value` per line,
values `true`/`false`/quoted string — ordinary JSON that any editor reads,
unambiguous to `sed`. Requiring `jq` would have been this project's first
runtime dependency, against the non-goal
[0005](0005-script-backed-skills-target.md) and
[0010](0010-ci-splits-into-a.md) both invoke. Strictness is scoped: keys a
workflow parses are shape-checked, keys only an agent reads are checked for
value alone — an agent reads JSON the way it reads prose.

**This reverses [0041](0041-the-issues-mirror-is.md)**, deliberately. That
entry rejected "a config flag the workflows read at runtime" because "two
files an adopter deletes need no switch, and a switch would be a second way
to say what absence already says." Correct for the world it judged, where
deletion was the mechanism and a flag could only *describe* it. Here the
level **controls**: `level: docs` is what stops the workflows, and deletion
stops being the mechanism — one way to say it, not two.

The second key, `pr_title_style`, chooses between `conventional` and
`bracketed` for every title a project writes, authoring ones included. It is
read by agents only, since nothing parses the summary after the tag
([0046](0046-the-task-tag-leads.md)). The `[TASK-NNNN]` tag itself is in both
styles and is **not** settable: it is how `reflect_progress.sh` and
`list_tasks.sh` learn which tasks a pull request carries, and a branch name
holds one id — a title without it would reduce a multi-task pull request to
reporting one task, silently. A setting that can degrade a guarantee without
saying so is not a choice worth offering.

Rejected: independent booleans for the forge and the mirror, which allow the
incoherent pair and hide that the levels are a progression. Also rejected:
keying the file off the existing front-matter shape, which is this project's
contract but not one an arriving developer recognises. Also rejected: nested
JSON with `jq`, which reads better and costs the portability the whole
toolchain is built on.
