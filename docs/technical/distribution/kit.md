# The kit

**What an adopting project copies, and how it is kept honest** — the template, the mirror, its guards and its one exception. One chapter of [`distribution/`](README.md).

## The kit

The whole adoption kit ships as [`template/`](../../../template), one folder
**shaped exactly like the destination root** — that is what a template
is: `.writrun/`, the four `writrun-*.yml` workflows, `work/` with its
three folders (`tasks/`, `specs/` and `reports/`, each carrying its own
README), the skeletons for `AGENTS.md` and `docs/`, and the guide itself
as `WRITRUN.md` — a name that collides with nothing and stays behind as a
provenance pointer after adoption. **Severing the mirror is the `stage`
setting, not a deletion.** An adopter that wants no GitHub Issues lowers
the top-level `stage` below `3`, and every mirror in the kit stands down
at once: `writrun-issues.yml` is wholly Stage 3, so is
`writrun-progress.yml`'s `reflect` job, and so are the two mirror steps
`approve` carries. Those steps are what changed the instruction — a
merged close has exactly one owner, and it has to be the workflow that
writes the queue, because a label derived from anything but the queue
after the recording commit is derived from a state the merge already
changed. Delete the two mirror workflows and leave `stage` at its
default of `3`, and `approve` goes on minting and labelling mirrors at
every merge; lower the stage, and deleting them is tidying rather than
severing. `writrun-issues.yml` is the only one a deletion severs
cleanly: `writrun-progress.yml` also carries Stage 2's in-flight status
recording, and `check` and `approve` stand alone. The guide names the
kit's two collision
points — an existing `AGENTS.md` is grafted, never overwritten; existing
docs are kept — while everything else the copy lands is
WritRun-namespaced. The kit deliberately ships **no README.md**: the one
file whose blind copy would replace the adopting project's own. The mirrored parts are a
**deliberate full copy**, kept byte-identical to this repository's own
root files by a unit test (`make template-sync` refreshes; the mirror
list is `tests/template_mirrors.txt`, the single source of what ships).

**A script's data file ships beside the script.** The vocabulary lives
in `.writrun/scripts/stage-2-pull-requests/`, next to the check that
reads it, and not in this repository's `tests/` — the mirror carries
`.writrun` whole and carries nothing else, so a data file left outside it
reaches no adopter, and the check they run passes by knowing nothing.
That is a silence, not a pass, which is why the absent case says so.

**The mirror holds bytes; the kit's own prose is held by words.**
Everything under `template/` that is *not* mirrored — its `AGENTS.md`,
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
`template/work/` is named in its README, and every skill directory is
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

**One file leaves the mirror on purpose: `.writrun/settings.json`.** The
kit ships it cautious — `stage: 1`, every conduct flag `false` — because
a fresh copy of this repository's own file would start an adopter at
Stage 3 with every workflow armed and the Issues mirror opening issues on
their first pull request, while the guide is still telling them to
declare a stage. `tests/template_exceptions.txt` is the single source of
what differs, read by the sync and by the unit test alike. The sync
stashes each listed path before the mirror runs and restores it after —
not merely declining to overwrite it, because the mirror list names
`.writrun`, a directory, and a directory is refreshed by removing it and
copying it back; every path it keeps is named in the output. The test
drops the same paths from both sides before comparing, by path and never
by name, so `.writrun/conventions/settings.json` — the legacy address the
reader still honours — stays compared.
This repository's own CI beyond the writrun workflows — the pull-request
suite in `.github/workflows/tests.yml` and the release-readiness
pipeline on `main`, `.github/workflows/release-readiness.yml` — is not
part of the kit and stays home.

**A red `main` that a script can fix is the bot's to fix.** The
readiness pipeline separates two kinds of failure. Drift a
deterministic regeneration repairs — the template out of sync with the
root it mirrors — it repairs itself: the pipeline runs the
regeneration and, when that produces a diff, commits the sync to
`main` with the same token and the same rebase-not-force pattern the
queue recording uses. Because a `GITHUB_TOKEN` push triggers no new
runs, the same job then re-runs the suite itself, so the verdict on
the healed tree lands in the run that healed it. Readiness goes red
only for what regeneration cannot repair — a genuine breakage that
needs thought. A pipeline that fails asking a person to run
`make template-sync` is a machine demanding a human do a machine's
job, which is the failure the queue recording already refuses
everywhere else.

