#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The slug is not identity: a rename that rewords it releases and claims
# the same id, and the two cancel. This is the case a subtraction done on
# paths would get wrong — the path is exactly what changed — which is why
# the release is subtracted by id.
setup
stub_forge
report_file report-0031 open
mv work/reports/report-0031.md work/reports/report-0031-old-words.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature

git mv work/reports/report-0031-old-words.md work/reports/report-0031-new-words.md
commit_all

check "rewording a slug is not a claim on a new id" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
