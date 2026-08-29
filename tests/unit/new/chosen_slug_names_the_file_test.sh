#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Whoever creates the file chooses its subject — the derivation is what
# runs when nobody did, not the outcome to aim for.
setup
check "a chosen slug is taken verbatim" 0 "task-0001-stamp-queue-dates.md" \
  -- bash "$NEW_SH" task "Stamp queued and merged on the task" --slug stamp-queue-dates
check "and a spec's slug is its own" 0 "spec-0001-utc-timestamps.md" \
  -- bash "$NEW_SH" spec task-0001 "Record the two dates as timestamps" --slug utc-timestamps

# Absent, the derivation runs exactly as it did — first three words.
check "no --slug still derives from the title" 0 "task-0002-second-thing-entirely.md" \
  -- bash "$NEW_SH" task "Second thing entirely, and then some"

# Identity is the id, so two files may carry the same subject.
check "a slug another id already carries is allowed" 0 "task-0003-stamp-queue-dates.md" \
  -- bash "$NEW_SH" task "A different task about the same area" --slug stamp-queue-dates

# The convention asks for two or three words; the check enforces shape,
# not taste.
check "a long slug is shape, not taste" 0 \
  "task-0004-one-two-three-four-five-six.md" \
  -- bash "$NEW_SH" task "Long" --slug one-two-three-four-five-six

finish
