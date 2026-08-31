#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Two values, and there is no third: `rule` for a task derived from an
# authored rule, `report` for one born from a report of work an existing
# rule already authorizes. A value outside those reads as a fact nobody
# can act on.
setup
task_file task-001 ready "" "" "" inherited
check "a value outside the pair is named" 1 "origin 'inherited' is not rule or report" \
  -- bash "$CHECK_FRONT_MATTER"

finish
