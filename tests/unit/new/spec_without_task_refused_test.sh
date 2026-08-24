#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
check "a spec without its task is refused" 3 "never created before its task" \
  -- bash "$NEW_SH" spec task-404 "Orphan"

finish
