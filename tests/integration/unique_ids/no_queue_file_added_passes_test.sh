#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Nothing is claimed, so there is nothing to ask the forge about — and a
# doc-only change must not pay a round trip to be told so.
setup
stub_forge
printf 'a rule\n' >> docs/product/chapter.md
commit_all
check "a change adding no queue file passes" 0 "adds no queue file" \
  -- bash "$CI_SCRIPTS/check_unique_ids.sh" main...HEAD o/r 7
forge_untouched "and the forge was never consulted"

finish
