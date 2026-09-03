---
id: report-0012
status: tracked
task_ref: [task-0039]
doc_ref: technical/distribution.md#distribution
created: 2026-09-03T03:27:37Z
triaged: 2026-09-03T03:31:20Z
---

# The adoption kit's prose predates the report concept

**References:** [technical/distribution.md#distribution](../../docs/technical/distribution.md#distribution) · [task-0039](../tasks/task-0039-kit-carries-reports.md)

The half of `template/` that no sync regenerates still describes a
methodology without reports. Five files, and the report concept appears
in none of them beyond one stale clause.

`template/work/README.md` maps the queue as `tasks/` and `specs/` and
stops there; the root's own `work/README.md` carries a third row for
`reports/` and a paragraph on why reports sit outside the pipeline.
`template/AGENTS.md` — the agent entry point an adopter grafts — never
says the word: not that a finding is recorded, not that recording rides
any change, not that the `tracked` route needs a branch of its own, not
that triage to `fixed` or `declined` is the agent's. `template/WRITRUN.md`
says work discovered mid-flight "enters as a `report/` PR adding only
task + spec", which is the flow as it stood before a report was a file
with four ends.

`.writrun/README.md` — mirrored, so the root's copy and the kit's are the
same file — calls `skills/` "the four `writrun-*` skills" against five
directories, and `templates/` "shipped default body shapes for task and
spec" against a folder that also holds `report.md`. The root `README.md`
names the same four skills in its own table.

Observed while installing the kit by hand into `writrun-cli` at v0.0.02,
reading what the copy told the adopting project.

`work/reports/` being absent from `template/work/` is **not** part of
this: `product/adoption.md#stage-1--the-minimum-bar` rules the folder out
of the adoption minimum, and `technical/distribution.md#running-the-checks`
states that a missing report directory is zero reports and still exit 0.
The directory is deliberate; the silence around it is what this reports.

What lets it drift: `tests/template_mirrors.txt` mirrors `.writrun` and
the four workflows, and a unit test holds those byte for byte. Everything
else under `template/` — `AGENTS.md`, `WRITRUN.md`, `work/`, the two docs
skeletons — is hand-maintained. A check does read it:
`check_doc_shapes.sh` takes `template` among its roots and judges the
words it uses and the front matter it shows, which
`technical/distribution.md` names as the guard over the kit's prose. That
guard cannot see this, and the reason is structural — a concept the kit
never mentions uses no retired word and shows no wrong shape. Silence has
no signature. The `.writrun/README.md` counts drifted on the mirrored
side for the neighbouring reason: the mirror test compares the two copies
and never a copy against the folder it describes.

Not investigated: whether the kit should ship `work/reports/README.md`
and create the folder at adoption, or name `reports/` in
`template/work/README.md` as the folder the first report creates.
