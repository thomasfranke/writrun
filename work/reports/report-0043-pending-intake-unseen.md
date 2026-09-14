---
id: report-0043
status: authored
task_ref: []
doc_ref: product/stage-3-github-issues/intake.md#submitted-and-not-yet-a-report
created: 2026-09-13T23:40:04Z
triaged: 2026-09-14T00:32:19Z
---

# Nothing names an issue awaiting intake, so a routed finding is visible to no one

**References:** [technical/selection/visibility.md#an-open-report-is-named-never-selected](../../docs/technical/selection/visibility.md#an-open-report-is-named-never-selected)

An issue awaiting the `writrun:report` label appears in no list this
methodology prints. `list_tasks.sh` reads files and only files — line
361 iterates `"$REPORT_DIR"/*.md` — so a report that has no file yet is
outside everything: the lister's five sections, the exit code, and the
`Open reports` section that exists precisely to carry an unanswered ask
to whoever is picking work.

`visibility.md` gives that section its reason: *"the session picking work
is the reader most likely to act"*, against the failure named in
`concepts/report.md` — *"a file nobody is prompted to open is a file that
rots."* An un-intaken issue is that same file, one step earlier and with
nothing at all watching it. The only channel is a GitHub notification to
whoever happens to hold triage rights.

`intake.md` is not silent about this by accident: *"the machinery shall
write nothing into `work/` on that event alone"*, because an intake that
minted files on arrival would hand the queue's front door to whoever
finds the repository. The gap is not that rule. It is that nothing
anywhere says the pending label is owed, or to whom.

## Evidence

Measured on issue #252 of this repository, both sides of the label.

Before — the issue had been open for sixteen minutes, carrying a defect
against two gates:

```
$ bash .writrun/skills/writrun-select-next-task/list_tasks.sh
Nothing is available.
```

After the same command, once the label had minted the file:

```
Open reports — waiting to be triaged, never selected:
  report-0041  Documentation is not a file format, but doc_ref and promises accept only .md
```

The ask the section exists to raise was raised by a person reading a URL,
which is the channel `visibility.md` was written to replace.

**Not investigated:** whether the answer is the lister reading the forge,
the intake workflow announcing itself, or something that belongs to
neither. That choice decides new behaviour, and no rule states it yet.

**Triage:** authored. No rule stated that this project shall surface an
issue awaiting intake, and `intake.md`'s criteria said the opposite
about arrival — so this was never a defect against anything, and the
second row of `authoring.md`'s triage table handed the pen back. The
rule was written rather than the behaviour guessed:
`intake.md#submitted-and-not-yet-a-report` names the state between
arrival and the label, and `visibility.md#a-submission-is-named-before-it-is-a-report`
names where it is read. The gate did not move — `writrun:report` is
still the only label that mints anything.

Four channels were weighed. The marker is applied by whoever submits,
never inferred by the machinery from an issue's contents, because the
alternative is guessing which strangers meant to file a report — which
is how the front door gets handed away, the thing *Arrival creates
nothing* was written to prevent.
