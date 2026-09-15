#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A gate that reports one of four costs four round trips, and the fourth
# arrives after the reviewer has been asked to look three times. So the
# refusal is the whole list, in one run.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

## Why

## Spec

- [spec-0097](https://example.invalid/spec) — The gate on ready

## How to verify

<!-- The methodology's answer. -->

## How to test

## Notes
MD

for section in What Why "How to verify" "How to test" Notes; do
  check "${section} is named" 1 "## ${section}" \
    -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7
done

# Five named, and the one carrying a bullet left out of the list.
refute "the section holding a bullet is not among them" "## Spec" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

finish
