#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A body quoting a template shows `## ` at line start — this repository's
# own bodies do it. Split naively, the quotation becomes a heading and
# the check invents an empty section out of text that is answering the
# section above it.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

The template the take seeds:

```markdown
## Why

## How to test
```

Nothing under those two headings is filled by the taking.

## Notes

None.
MD

check "a fenced heading does not open a section" 0 "2 sections" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

refute "so the fenced one is never named as unanswered" "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# The section *after* the fence is read normally — a fence that failed to
# close would swallow the rest of the body, and an unanswered section
# hiding behind one is the failure that matters.
forge_pr_body 7 <<'MD'
## What

```sh
bash tests/run.sh
```

## How to test
MD

check "and the section after it is still judged" 1 "## How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# An HTML comment inside a fence is shown, not interpreted: one that
# never closes must not swallow every section after it.
forge_pr_body 7 <<'MD'
## What

```html
<!-- an unclosed comment, quoted
```

Text after the fence.

## Notes

None.
MD

check "a fenced comment opener swallows nothing" 0 "2 sections" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
