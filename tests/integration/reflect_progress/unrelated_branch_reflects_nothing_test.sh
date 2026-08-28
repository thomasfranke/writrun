#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A branch that names no task has no mirror to move — and the forge is
# not even consulted.
setup_forge
export PR_HEAD_REF="fix/typo"
check "an unrelated branch reflects nothing" 0 \
  'Neither the title nor branch "fix/typo" names a task' \
  -- bash "$REFLECT_PROGRESS" o/r 7
forge_untouched "the forge is not consulted at all"

finish
