#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# report-0031's repair, stated as a case. A queue filename is an id plus a
# slug, so renumbering a file changes its path and git pairs it as a
# rename — which `--diff-filter=A` cannot see. The check therefore read
# the new file as a claim and the base's old file as the holder, and
# refused a change for colliding with a file that same change had moved
# out of the way. The repair had to be split across two pull requests;
# reading the rename is what makes it one.
setup
stub_forge
mkdir -p work/reports

queue_report() {   # <filename> <heading>
  cat > "work/reports/$1" <<RPT
---
id: ${1%%.md}
status: open
task_ref: []
doc_ref: null
created: 2026-08-22T00:00:00Z
triaged: null
---

# $2
RPT
}

queue_report report-0001-take-task.md "Take needs a commit"
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature

git mv work/reports/report-0001-take-task.md work/reports/report-0002-take-task.md
queue_report report-0001-new-thing.md "Something else entirely"
commit_all

check "a renumber and the claim it frees are one change" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish
