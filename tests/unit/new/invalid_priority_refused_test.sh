#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
check "an invalid --priority is refused" 3 "Invalid --priority" \
  -- bash "$NEW_SH" task "Bad" --priority urgent

finish
