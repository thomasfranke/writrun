#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
printf 'edit\n' >> docs/product/chapter.md
commit_all
check "clean change passes" 0 "OK" -- bash "$CHECK_STATE" main...HEAD

finish
