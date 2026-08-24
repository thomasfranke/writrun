#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
check "a bad diff range exits 3" 3 "" -- bash "$CHECK_STATE" not-a-ref...HEAD

finish
