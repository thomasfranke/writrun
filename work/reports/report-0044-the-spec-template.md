---
id: report-0044
status: open
task_ref: []
doc_ref: null
created: 2026-09-17T12:15:08Z
triaged: null
---

# The spec template calls the technical section machinery, and the promise gate only accepts a document under docs/

Issue #267, opened by @thomasfranke.

Observed in [`writrun-cli`](https://github.com/thomasfranke/writrun-cli), against the kit tagged `v0.0.07` in `.writrun/VERSION`, and re-checked against `v0.0.08` — still present there.

`kit/.writrun/templates/spec.md:35-37` seeds the section with

```markdown
## Proposed technical changes

- none — no machinery change
```

and `kit/.writrun/scripts/stage-2-pull-requests/check_promise_paths.sh` refuses any entry in it that does not resolve under `docs/`:

```
REJECTED: spec-0036 promises `internal/palette`, read as
docs/internal/palette — `internal` is a repository-root entry and
docs/internal does not exist, so no diff can ever touch it.
```

That is condition one, at `:228-231` in v0.0.07 and `:240` in v0.0.08. The word the template uses is *machinery*, which is the code; the path the checker requires is a chapter under `docs/technical/`, which the closing advice names outright — "Write it as the schema reads it — `technical/…`, `product/…`". Two shipped files say two things about the same section, and the schema that ought to settle it repeats both in one code block: `docs/technical/schemas/spec.md:38-41` shows `technical/engine/adapter.md` beside `(or: "none — no machinery change")`.

`kit/.writrun/skills/writrun-create-task-and-spec/SKILL.md:90-99` does not settle it either. It asks for "**both Proposed-changes sections with real entries**" and gives `path/to/doc.md#anchor` as the only example, without saying the paths are read relative to `docs/`, or that the technical section means `docs/technical/` rather than the machinery it is named for.

Observed while drafting eight specs against this kit: five named Go packages, and the pipeline refused the branch.

**v0.0.08 does not fix it, and moves part of it later.** #261 / TASK-0066 rewrote condition two and left condition one byte-for-byte, as its own comment says at `:258`. The template and the skill are not in the `v0.0.07..v0.0.08` diff at all. But the old condition two refused *every* non-Markdown promise at spec entry; the new one fires only when `docs/<path>` is an existing directory. A code path whose first segment has no repository-root counterpart — `pkg/thing.go` in a project with no root `pkg/` — now passes this gate, is read as `docs/pkg/thing.go`, and fails at `writrun-check-spec-deltas` instead, under a finished branch. That is the expensive failure this script's own header (`:54-59`) exists to prevent, and the template's word is what invites it.

**A second finding, downstream of the first.** The adopter's answer to the refusal was to rewrite the entries as a markdown link around the path:

```markdown
- [`product/queue/status.md`](../../docs/product/queue/status.md) — the row and what it answers.
```

Both gates take a bullet only when a backtick follows it immediately — `promised_written` in `check_promise_paths.sh` and `extract_paths` in `check_deltas.sh` carry the same awk line — so every such entry is read as **no entry at all**. `check_promise_paths.sh` then answers *"No spec this change adds or modifies promises a path — nothing to judge"*, which is a pass and reads as one, while `check_deltas.sh` will later judge every permanent doc the completing diff touches as UNDECLARED against an empty set. Seven specs sat in that state until it was found by accident.

That one is arguably the adopter's own mistake, and it was fixed there. It is included because the two are the same shape: the form the gates accept is stated in one place and not where an author meets it, and a plausible wrong form fails silently rather than loudly.

The fix to the first is a wording decision rather than a code one: either the template and the schema stop calling the section *machinery*, or its meaning is stated where an author meets it — the template's own fallback line and the skill's example are the two places that currently teach the wrong reading.

