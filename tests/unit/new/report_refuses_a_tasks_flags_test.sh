#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `--origin` and `--priority` are real flags one kind over, so a person
# reaching for them has the wrong model of what a report is. Refused by
# name rather than swept into "unknown flag": the message is the cheapest
# place to correct the model (docs/product/concepts/report.md).
setup
check "--origin is refused, and says whose it is" 3 "origin: report" \
  -- bash "$NEW_SH" report "Has an origin" --origin rule
check "--priority is refused, and says why a report has none" 3 "commits to no work" \
  -- bash "$NEW_SH" report "Has a priority" --priority high
check "an unknown flag is still an unknown flag" 3 "Unknown flag" \
  -- bash "$NEW_SH" report "Invented" --severity high

if [ -z "$(ls work/reports 2>/dev/null)" ]; then
  echo "ok    a refusal writes no file"; pass=$((pass + 1))
else
  echo "FAIL  a refusal writes no file"
  ls work/reports | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
