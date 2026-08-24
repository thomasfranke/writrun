#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
check "an unknown spec id exits 3" 3 "" -- bash "$CHECK_DELTAS" spec-404 main...HEAD

finish
