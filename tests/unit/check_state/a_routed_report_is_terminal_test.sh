#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `routed` is the fifth end and behaves as the other four do under rule
# J: triage ran once, and the judgement that sent the work upstream is
# not rewritten here. It also keeps rule K's exemption — routing adds
# nothing to this queue (the work went to the repository that owns the
# defect), so the flip rides any change, exactly as fixed and declined
# do (docs/product/concepts/report.md#routing-upstream).

setup
report_file report-0001 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 routed "" 2026-08-23T00:00:00Z
commit_all
check "open -> routed rides — the queue gains nothing from it" 0 \
  "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 routed "" 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 open
commit_all
check "a routed report never returns to open" 1 "returns routed -> open" \
  -- bash "$CHECK_STATE" main...HEAD

setup
report_file report-0001 routed "" 2026-08-23T00:00:00Z
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
report_file report-0001 tracked task-0001 2026-08-23T00:00:00Z
commit_all
check "and never moves to another end — upstream has the work" 1 \
  "one end to another" \
  -- bash "$CHECK_STATE" main...HEAD

finish
