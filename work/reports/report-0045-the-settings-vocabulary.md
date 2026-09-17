---
id: report-0045
status: open
task_ref: []
doc_ref: null
created: 2026-09-17T12:15:28Z
triaged: null
---

# The settings vocabulary is not readable, so a porcelain can write a value but never offer the choices

Issue #268, opened by @thomasfranke.

Observed in [`writrun-cli`](https://github.com/thomasfranke/writrun-cli), against the kit tagged `v0.0.08` in `.writrun/VERSION`.

The settings schema lives in `kit/.writrun/scripts/stage-2-pull-requests/check_settings.sh` as bash variables. `HOMES` (`:93`) names every documented key and the section that owns it, and the allowed values sit beside it (`:76-80`):

```bash
TITLE_STYLES="conventional bracketed"
SPEC_REQUIRED="always when-warranted"
DECISIONS_STYLES="per-subsystem chronological"
PRODUCT_LAYOUTS="by-concept by-feature"
```

`read_setting.sh` reads *a value* — `read_setting.sh stage_2.pr_title_style`. Nothing reads the vocabulary.

An adopter porcelain can therefore only write and be judged: change the file, run the checker, keep the write on exit 0. That much works and is the right shape — the kit stays the one authority, and nothing in Go decides what a key or a value is. What it cannot do is **offer** the choices before the write.

A config screen cannot show `1 · 2 · 3` or `conventional | bracketed`, because to show them it would have to hold them, and a copy in Go is a second authority that drifts on the next `writrun update`. So the reader picks blind and learns the vocabulary from a refusal:

```
pr_title_style 'x' is outside its vocabulary: conventional bracketed
```

which is a good sentence arriving one step too late.

Observed while building this client's config screen. Its own drawing carries a note naming this as the thing to route upstream, so the gap was known before it was hit.

What would settle it is the schema being readable — a script beside `read_setting.sh` that prints a key's allowed values, or the checker gaining a mode that lists them. Any shape works as long as the vocabulary has exactly one home and it is the kit's. Reading it out of `check_settings.sh` by grep from the adopter's side would be a second parser of the kit's internals, which is the thing this client's own rules refuse.

