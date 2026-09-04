#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The intake mints over the same three views the generator reads — the
# directory, the git history, and every open pull request — because an
# id is unique across all three, and the view that is easiest to skip
# (the forge's) holds exactly the numbers no checkout can see
# (docs/technical/schemas/report.md#report-schema).
setup_intake

# View one: the directory holds report-0002. View two: the history once
# held report-0005, since deleted — invisible to the scan, recoverable
# from the log. View three: an open pull request claims report-0007.
cat > work/reports/report-0002-already-here.md <<'EOF'
---
id: report-0002
status: open
task_ref: []
doc_ref: null
created: 2026-08-22T00:00:00Z
triaged: null
---

# Already here
EOF
git add -A >/dev/null && git commit -qm "queue: report-0002"
printf 'gone\n' > work/reports/report-0005-since-deleted.md
git add -A >/dev/null && git commit -qm "queue: report-0005"
git rm -q work/reports/report-0005-since-deleted.md
git commit -qm "queue: drop report-0005"
git push -q origin main 2>/dev/null
echo 41 > "$FAKE_GH_DIR/pr_numbers"
printf 'work/reports/report-0007-claimed-in-flight.md\n' > "$FAKE_GH_DIR/pr_41_files"

export ISSUE_TITLE="The generator reuses ids"
check "the id clears all three views" 0 \
  "recorded work/reports/report-0008-the-generator-reuses.md" \
  -- bash "$INTAKE" o/r 9

# The recording is on the authority branch, not merely in the clone —
# and its subject is the machinery's constant, never a session's prose.
check "the file landed on origin's main" 0 "report-0008" \
  -- authority ls-tree --name-only main:work/reports
check "under the intake's constant subject" 0 \
  "chore(queue): record what the label let in" \
  -- authority log -1 --format=%s main

# The issue becomes the mirror: retitled with the tag, labelled open,
# and told where the authority now lives.
forge_told "the issue is retitled with the minted tag" \
  "title=[REPORT-0008] The generator reuses ids"
forge_told "and labelled as recorded, awaiting triage" \
  "labels[]=status:open"
forge_told "and the comment names the file that is the authority" \
  "work/reports/report-0008-the-generator-reuses.md"

finish
