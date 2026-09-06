#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# One parse serves every range shape the stage-2 gates accept — lifted
# from three private copies after the bare-ref bug spec-0084 fixed had
# to be found in one copy out of three (spec-0086). The shapes pinned
# here are the ones the clones between them already answered, plus the
# sentinel: a bare ref's diff compares the working tree, so its head
# end is deliberately empty.

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

# ends <range> — both ends as the helper derives them, the empty head
# shown as <worktree> so the sentinel is visible rather than blank.
ends() {
  bash -c '
    set -euo pipefail
    . "$0"
    ql_range_ends "$1"
    printf "base=%s head=%s\n" "$QL_BASE" "${QL_HEADREF:-<worktree>}"
  ' "$QUEUE_LIB" "$1"
}

setup
printf 'work\n' > f.txt
commit_all
main_sha=$(git rev-parse main)

check "three dots resolve to the merge base and the right end" 0 \
  "base=${main_sha} head=feature" -- ends main...feature
check "two dots are the two ends as written" 0 \
  "base=main head=feature" -- ends main..feature
check "a bare ref's head end is the working tree" 0 \
  "base=main head=<worktree>" -- ends main
check "an open right end is HEAD" 0 \
  "base=main head=HEAD" -- ends main..
check "an open left end is HEAD's merge base" 0 \
  "base=${main_sha} head=main" -- ends ...main
check "a merge base that cannot be computed exits 3, loudly" 3 \
  "merge-base" -- ends no-such-ref...main

finish
