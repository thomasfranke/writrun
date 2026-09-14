---
id: report-0043
status: open
task_ref: []
doc_ref: technical/selection/visibility.md#an-open-report-is-named-never-selected
created: 2026-09-13T23:40:04Z
triaged: null
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

It has happened before, and that time nothing caught it. Issue #155,
opened 2026-09-04 — a routed finding from `writrun-cli` at kit `v0.0.03`,
`take_task.sh` unable to open a draft on a commit-less branch — never
carried a `writrun:` label of any kind. It was closed `COMPLETED` by
hand. No report was ever born from it, and its evidence lives on the
issue and nowhere else; the defect reached the queue only because the
same thing was observed *locally* the same morning and recorded as
`report-0019`, whose body describes a different take on a different
task.

The intake is not broken, which is what makes this worth a file: issue
#161 the same day became `report-0021` correctly. What separates #161
from #155 is that somebody remembered, and the methodology treats "a
file nobody is prompted to open" as exactly the thing not to leave to
memory.

**Not investigated:** whether the answer is the lister reading the forge,
the intake workflow announcing itself, or something that belongs to
neither. That choice decides new behaviour, and no rule states it yet.

**Not triaged.** Left `open` deliberately. No rule states that this
project shall surface an issue awaiting intake, and `intake.md`'s
criteria say the opposite about arrival — so choosing the channel is
authoring, not a defect against anything, and the second row of
`authoring.md`'s triage table hands the pen back rather than letting an
agent decide it.
