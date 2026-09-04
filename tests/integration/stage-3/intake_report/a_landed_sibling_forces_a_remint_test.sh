#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The rebase alone cannot see the id race: a report merged onto the
# authority branch between the checkout and the push replays cleanly
# under its different filename, and two files claiming one id would
# land on main with no gate to refuse them — the intake pushes straight
# to the authority branch, unlike a generator-minted id that still has
# check_unique_ids.sh at its pull request's door. So after the rebase
# the tree is re-read, and an id another file now claims is dropped and
# minted again over what landed.
setup_intake

# What the checkout cannot see: report-0001 lands on origin after the
# clone, exactly as a report/ branch squash-merge would put it there.
git clone -q "$WORK/origin.git" "$WORK/racer" 2>/dev/null
(
  cd "$WORK/racer" || exit 1
  git config user.email r@example.com
  git config user.name Racer
  mkdir -p work/reports
  cat > work/reports/report-0001-landed-first.md <<'EOF'
---
id: report-0001
status: open
task_ref: []
doc_ref: null
created: 2026-09-01T00:00:00Z
triaged: null
---

# Landed first
EOF
  git add -A >/dev/null
  git commit -qm "queue: report-0001"
  git push -q origin main 2>/dev/null
)

export ISSUE_TITLE="Raced and reminted"
check "the intake yields the id and mints the next one" 0 \
  "recorded work/reports/report-0002-raced-and-reminted.md" \
  -- bash "$INTAKE" o/r 9

check "both files are on the authority branch" 0 \
  "report-0001-landed-first.md" \
  -- authority ls-tree --name-only main:work/reports
check "the reminted file too" 0 \
  "report-0002-raced-and-reminted.md" \
  -- authority ls-tree --name-only main:work/reports
forge_told "and the mirror wears the reminted id" \
  "title=[REPORT-0002] Raced and reminted"

finish
