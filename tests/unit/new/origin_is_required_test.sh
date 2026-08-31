#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# No default, deliberately: a default would record one of the two
# silently for whichever kind of change happened not to say, and a wrong
# fact nobody typed is the failure the field exists to prevent. So an
# unstated origin refuses, naming the flag.
setup
check "an unstated origin refuses, naming the flag" 3 "origin is required" \
  -- bash "$NEW_SH" task "No origin"
check "and a third value refuses too" 3 "expected rule or report" \
  -- bash "$NEW_SH" task "Bad origin" --origin invented

if [ -z "$(ls work/tasks 2>/dev/null)" ]; then
  echo "ok    a refusal writes no file"; pass=$((pass + 1))
else
  echo "FAIL  a refusal writes no file"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
