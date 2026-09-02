#!/usr/bin/env bash
# The state gate reads transitions against a base, so a base that could
# not be refreshed is named rather than used in silence — and the run
# continues, because a check nobody can run offline is a check that does
# not run at all.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 backlog ""
commit_all

check "an unfetchable origin is said out loud" 0 "possibly stale base" -- bash "$PREFLIGHT"
check "and the local base is named as the fallback" 0 "the range is the local main" -- bash "$PREFLIGHT"
check "and the run still finishes" 0 "PREFLIGHT OK" -- bash "$PREFLIGHT"

# A range given by hand is honoured as given — nothing is inferred over it.
check "a named range is the one used" 0 "range main...HEAD" -- bash "$PREFLIGHT" "main...HEAD"

finish
