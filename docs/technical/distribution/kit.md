# The kit

**What an adopting project copies, and how it is kept honest** — the kit folder, the mirror, its guards and its one exception. One chapter of [`distribution/`](README.md).

## The kit

The whole adoption kit ships as [`kit/`](../../../kit), one folder
**shaped exactly like the destination root** and wearing the kit's own
name: `.writrun/`, the five `writrun-*.yml` workflows, the report form
(`.github/ISSUE_TEMPLATE/writrun-report.yml` — shape only, never the
gate: [intake](../reporting/intake.md)), `work/` with its
three folders (`tasks/`, `specs/` and `reports/`, each carrying its own
README), the skeletons for `AGENTS.md` and `docs/`, the one-line
`CLAUDE.md` shim (`@AGENTS.md` — Claude Code reads that file, not
`AGENTS.md`), and the guide itself
as `WRITRUN.md` — a name that collides with nothing and stays behind as a
provenance pointer after adoption. **The entry point is a pointer, and
ownership is per home** ([Two homes](../../product/adoption.md#two-homes)):
the kit's claim on the project's `AGENTS.md` is the four-line WritRun
section naming `.writrun/AGENTS.md`, where the whole agent flow lives —
a file the kit owns and an update replaces entire. The project's
answers live in `writrun/`, a home an update never touches:
`settings.json` beside `gates.md` and `conventions/`, each of the
latter shipped deferring to its default under `.writrun/defaults/`
([Two homes](../../product/adoption.md#two-homes)). No folder is part
both, which is what lets an update run without merging anyone's prose
— resolution reads one first line, and no update preserves any.
**Severing the mirror is the `stage`
setting, not a deletion.** An adopter that wants no GitHub Issues lowers
the top-level `stage` below `3`, and every mirror in the kit stands down
at once: `writrun-issues.yml` and `writrun-intake.yml` are wholly
Stage 3, so is
`writrun-progress.yml`'s `reflect` job, and so are the two mirror steps
`approve` carries. Those steps are what changed the instruction — a
merged close has exactly one owner, and it has to be the workflow that
writes the queue, because a label derived from anything but the queue
after the recording commit is derived from a state the merge already
changed. Delete the two mirror workflows and leave `stage` at its
default of `3`, and `approve` goes on minting and labelling mirrors at
every merge; lower the stage, and deleting them is tidying rather than
severing. `writrun-issues.yml` and `writrun-intake.yml` are the only
ones a deletion severs
cleanly: `writrun-progress.yml` also carries Stage 2's in-flight status
recording, and `check` and `approve` stand alone. The guide names the
kit's three collision
points — an existing `AGENTS.md` gains the pointer section and nothing
else, never overwritten; existing docs are kept; an existing
`CLAUDE.md` keeps itself, and the guide instructs adding the
`@AGENTS.md` line instead — while everything else the copy lands is
WritRun-namespaced. The kit deliberately ships **no README.md**: the one
file whose blind copy would replace the adopting project's own. The mirrored parts are a
**deliberate full copy**, kept byte-identical to this repository's own
root files by a unit test (`make kit-sync` refreshes; the mirror
list is `tests/kit_mirrors.txt`, the single source of what ships).

**A script's data file ships beside the script.** The vocabulary lives
in `.writrun/scripts/stage-2-pull-requests/`, next to the check that
reads it, and not in this repository's `tests/` — the mirror carries
`.writrun` whole and carries nothing else, so a data file left outside it
reaches no adopter, and the check they run passes by knowing nothing.
That is a silence, not a pass, which is why the absent case says so.

**The mirror holds bytes; the kit's own prose is held by words.**
Everything under `kit/` that is *not* mirrored — its `AGENTS.md`,
its `WRITRUN.md`, its `docs/` and `work/` chapters — has no byte-for-byte
guard, and cannot have one: those documents differ from this
repository's on purpose. What they share is the vocabulary, so
`check_doc_shapes.sh` reads them for both halves — the front matter they
show, and the words they use. That is the structural reason the kit
shipped a retired status long after the queue stopped having it, and the
reason a second mirror was not the answer.

**That guard reads what the prose says, never what it omits**, and the
omission is the other drift: the kit shipped the report machinery while
three of its files went on describing a queue of two folders and four
skills. A check for absence is not available — a concept the prose never
mentions uses no retired word and shows no wrong shape — so the guard is
built from the side that has a signature. Two unit tests compare what
the kit **ships** against what its prose **names**: every directory under
`kit/work/` is named in its README, and every skill directory is
named where an adopter reads — matched on a word boundary, so `reports/`
never accounts for a `report/`, and reported by name when the tree the
test reads has moved rather than passing on having read nothing.

**What they hold is names, and only names.** A sentence that *counts* —
"the five `writrun-*` skills" — is still held by hand, and it is half of
what report-0012 found: three files said four. The pair is what the kit
ships against what it names; a number in prose has no shipped
counterpart to compare against, and inferring one from a word like
"five" would be reading meaning, which is the review's job and not a
test's.

**The adopter's home leaves the mirror whole: `kit/writrun/` is
a seed, not a copy.** The kit ships its `settings.json` cautious —
`stage: 1`, every conduct flag `false` — because a fresh copy of this
repository's own file would start an adopter at Stage 3 with every
workflow armed and the Issues mirror opening issues on their first pull
request, while the guide is still telling them to declare a stage.
Every other file in the seed defers: `gates.md` and each convention
ship as a `/// writrun:default` stub, so the adopter's home starts as
nothing but the project's own values and the addresses it may
override, while the texts in force live under `.writrun/defaults/` —
inside the mirror, where an update corrects them
([Two homes](../../product/adoption.md#two-homes)). This repository's
own gate answers stay in its own `writrun/gates.md`, reaching no
adopter — the failure the TODO skeleton used to guard against, now
guarded by the split itself. Neither the settings nor the stubs need a
mirror exception — `writrun/` sits
outside every mirrored path, and the seed is written once, by hand,
when its shape should change. `tests/kit_exceptions.txt` stays
as the single source of any future deliberate difference under a
mirrored path, read by the sync and by the unit test alike; today it is
empty, and the machinery it drives — stash before the mirror, restore
after, name every kept path in the output — stands ready rather than
exercised.
This repository's own CI beyond the writrun workflows — the pull-request
suite in `.github/workflows/tests.yml` and the release-readiness
pipeline on `main`, `.github/workflows/release-readiness.yml` — is not
part of the kit and stays home.

**A red `main` that a script can fix is the bot's to fix.** The
readiness pipeline separates two kinds of failure. Drift a
deterministic regeneration repairs — the kit folder out of sync with the
root it mirrors — it repairs itself: the pipeline runs the
regeneration and, when that produces a diff, commits the sync to
`main` with the same token and the same rebase-not-force pattern the
queue recording uses. Because a `GITHUB_TOKEN` push triggers no new
runs, the same job then re-runs the suite itself, so the verdict on
the healed tree lands in the run that healed it. Readiness goes red
only for what regeneration cannot repair — a genuine breakage that
needs thought. A pipeline that fails asking a person to run
`make kit-sync` is a machine demanding a human do a machine's
job, which is the failure the queue recording already refuses
everywhere else.

