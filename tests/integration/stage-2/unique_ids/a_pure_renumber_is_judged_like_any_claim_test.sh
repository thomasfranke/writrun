#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Reading a rename is not exempting it. A renumber lands on an id like an
# addition does, and where the base still holds that id in a file this
# change did not move, it collides — the release cancels the id it freed
# and nothing else. Before this, `--diff-filter=A` returned nothing at
# all for a pure renumber and the check announced that the change claimed
# no id, which is the same blindness read the other way round.
setup
stub_forge
report_file report-0001 open
report_file report-0005 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature

git mv work/reports/report-0001.md work/reports/report-0005-collides.md
commit_all

check "a renumber onto an id the base still holds is refused" 1 \
  "report-0005-collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
