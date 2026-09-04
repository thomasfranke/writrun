#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A report's status is the route triage took, not a lifecycle: one
# non-terminal value and the five ends triage can reach
# (docs/product/concepts/report.md#statuses--the-route-not-a-lifecycle).
# `resolved` is the tempting extra and it is exactly the one that must be
# named — whether the underlying work is done is the task's status, one
# hop away, and a second copy of it would need a second writer.
setup

report_file report-0001 open
check "open, awaiting triage, is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# Each end carries what names its outcome, so the four are shown with
# both: the status word is what this case is about, and a report missing
# the field its end requires is refused for that instead
# (report_ends_name_their_outcome).
mkdir -p docs/product
: > docs/product/rule.md
for st in tracked authored fixed declined; do
  report_file report-0001 "$st" task-0001 2026-08-23T00:00:00Z product/rule.md
  check "'${st}' is one of the five ends" 0 "all canonical" \
    -- bash "$CHECK_FRONT_MATTER"
done

# The fifth end sent the work upstream, so what names its outcome — the
# issue it became — lives in the body, and task_ref stays empty
# (report_ends_name_their_outcome covers the pairing).
report_file report-0001 routed "" 2026-08-23T00:00:00Z
check "'routed' is one of the five ends" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 routed "" null
check "and pairs with its triaged date like every end" 1 \
  "triaged is null" \
  -- bash "$CHECK_FRONT_MATTER"

report_file report-0001 resolved task-0001 2026-08-23T00:00:00Z
check "a status outside the vocabulary is named, and the file with it" 1 \
  "is not a report status" \
  -- bash "$CHECK_FRONT_MATTER"

finish
