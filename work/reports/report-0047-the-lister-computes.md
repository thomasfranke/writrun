---
id: report-0047
status: authored
task_ref: []
doc_ref: technical/selection/visibility.md#a-row-carries-what-the-lister-read-to-place-it
created: 2026-09-17T19:32:28Z
triaged: 2026-09-17T19:53:21Z
---

# The lister computes each task's spec and its status to decide ready, and prints neither

Issue #270, opened by @thomasfranke.

Observed in [`writrun-cli`](https://github.com/thomasfranke/writrun-cli), against the kit tagged `v0.0.08` in `.writrun/VERSION`.

`list_tasks.sh` already resolves, for every task it considers, the specs in its `spec_ref` and each of those specs' status — it has to, because `ready` *is* "every `spec_ref` approved or implemented" (`:9`, and the loops at `:408-412` and `:492-496`).

Then it drops both at the printf. An available row is three fields:

```bash
printf '  %-10s %-7s %s\n' "$id" "$pr" "$tt"     # id, priority, title
```

So a porcelain reading the lister can say the id, the priority and the section a task sits under — and cannot say which spec a task references, or whether that spec is approved, even though the lister computed exactly that one line earlier.

### Why this client ran into it

Its screens are drawn before they are built, and two drawings explain a selected task with those facts:

- `take.excalidraw` — `task-0002 — available, spec-0002 approved, priority medium`
- `list.excalidraw` — `task-0024 — available, priority low, no spec`

The binary cannot render either. The alternative from this side is for the command and the screen wiring to take a filesystem port and read `spec_ref` off the task and `status` off the spec — a second read of the queue, per row, of something the kit has already read. This client's own rules refuse that: *"the kit is read from the kit; Go names only what the binary calls"* (its decision 0013, derived from `coupling.md`). So the two panes were left unbuilt and the frames are asserted by their rows and their keys instead.

### What would settle it

The row carrying what the lister already knows. Shape is upstream's to pick — a fourth and fifth field, or a `--format` the porcelain can ask for, or a machine-readable mode beside the human one. The only thing that matters from here is that the vocabulary has one home and it is the kit's: a porcelain parsing front matter itself is a second authority that drifts on the next update, which is the same objection `read_setting.sh` exists to answer for settings.

Related, and the same shape one level down: [#268](https://github.com/thomasfranke/writrun/issues/268) — the settings vocabulary is computed by the kit and not readable by a porcelain either.

**Triage:** authored. No rule stated what a lister row carries — the
selection chapters define the sections and the exit code, and the row's
three fields exist only in the script's printf — so adding fields was
deciding new behaviour, and the report itself left the shape upstream.
That is the second row of `authoring.md`'s triage table. The rule is
written in `visibility.md#a-row-carries-what-the-lister-read-to-place-it`:
one token, the specs and their statuses the lister already resolved,
before the row's free text. task-0073 derives from it.
