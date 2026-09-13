---
id: report-0041
status: tracked
task_ref: [task-0066]
doc_ref: technical/schemas/task.md#task-schema
created: 2026-09-13T23:23:53Z
triaged: 2026-09-13T23:40:57Z
---

# Documentation is not a file format, but doc_ref and promises accept only .md

**References:** [task-0066](../tasks/task-0066-documents-not-markdown.md)

Issue #252, opened by @thomasfranke.

### What was observed

The queue schema and the doc-delta contract both require documentation
to be markdown, so any document that is not a `.md` file cannot be
referenced by a task or promised by a spec.

Documentation is not a file format. A drawing that states what a screen
must render — Excalidraw, Penpot, a Figma export, plain SVG — is
documentation. So is a `.json` file that states the shape of a payload a
push sends, or a fixture a rule is written against. Each is read by a
person, states what the implementation must satisfy, and is touched by
the diff that changes it — which is everything the contract asks of a
document except its extension.

Two places refuse them.

**A task's `doc_ref`.** `check_front_matter.sh`:

```
MALFORMED: work/tasks/task-0035-first-run-screen.md: doc_ref
'product/screens/first-run.excalidraw' is not null or a .md path
(optionally with #anchor)
```

**A spec's Proposed-changes promise.** `check_promise_paths.sh` judges a
promise by shape, and the shape is `/` or `.md`:

```bash
*/|*.md) ;;
*) fault resolution "${id} promises \`${p}\` … — a promise names a document"
```

Such a file is a document a diff touches, and in this consuming project
it is the document the implementation is checked against: the
drawings under `docs/product/screens/` state what each screen must
render — its layout, its keys, its wording — and the code is held to
them. A task derived from one cannot name it, and a change that must
update one cannot promise it.

The workaround available today is promising the containing folder,
which the shape rule accepts. It defeats the contract's purpose: in a
folder holding five drawings, promising the folder promises nothing
about which of them changes.

### Evidence

Observed while deriving three tasks and eight specs from sixteen
drawings in `thomasfranke/writrun-cli`, on
[PR #129](https://github.com/thomasfranke/writrun-cli/pull/129).

- `doc_ref` refusal: `check_front_matter.sh`, on three tasks, until each
  was repointed at the folder's `README.md` — losing the anchor to the
  file that actually derived the work.
- Promise shape: `.writrun/scripts/stage-2-pull-requests/check_promise_paths.sh`,
  the resolution case that accepts `*/` and `*.md` and faults everything
  else as "not a document".
- The consuming project's own rule, which the schema cannot express:
  `docs/product/screens/README.md` — *"A drawing states the design,
  whole… where the binary does not match a drawing, the gap is a task."*

Recorded locally as
[report-0038](https://github.com/thomasfranke/writrun-cli/blob/main/work/reports/report-0038-docref-markdown-only.md).

### Version consumed

v0.0.07


**Triage:** tracked → task-0066. A defect against a rule already
written: `schemas/task.md` annotates `doc_ref` as *"any path under
`docs/`"*, and `check_front_matter.sh:357` refuses everything but `.md`.
The two stage-2 gates disagree with each other as well — a non-Markdown
file under `docs/` is `UNDECLARED` at the completion gate
(`check_deltas.sh:131` reads `docs/*` whole) and unpromisable at spec
entry (`check_promise_paths.sh:238` accepts only `*/` and `*.md`), so it
can be neither touched nor declared. Nothing here needs a new rule; the
kit already states the one being broken — `kit/docs/product/README.md`:
*"everything under `docs/` counts as permanent input."*
