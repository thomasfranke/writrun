#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# report-0031's sequence, stated as a case. A report minted on a branch
# that was dropped before it merged is in no tree, no history and no open
# pull request — and its Issue is still on the forge, holding the number.
# The mirror is the only record of the id that outlived the branch, so it
# is the input that has to answer, or the number is spent twice and a
# triaged Issue is reopened for a finding it never described.
setup
mkdir -p work/reports
cat > work/reports/report-0001-the-one-that-landed.md <<'RPT'
---
id: report-0001
status: open
task_ref: []
doc_ref: null
created: 2026-09-01T00:00:00Z
triaged: null
---

# The one that landed
RPT
git add -A >/dev/null && git commit -qm "queue: report-0001"

stub_forge
forge_mirror report '[REPORT-0003] A finding whose branch never merged'

check "the mirrors are named among the views" 0 "every mirror" \
  -- bash "$NEW_SH" report "New thing"
if [ -f work/reports/report-0004-new-thing.md ]; then
  echo "ok    and the mint sits above the id only a mirror still holds"
  pass=$((pass + 1))
else
  echo "FAIL  and the mint sits above the id only a mirror still holds"
  ls work/reports | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# No open pull request answered anything here: the mirror alone decided
# the number, which is the whole point of adding it as an input. The
# listing is asked in every state, because a closed mirror is exactly
# the one this case is about.
if grep -qF -- 'issues?labels=writrun:report&state=all' "$FORGE_LOG"; then
  echo "ok    the mirror listing was asked for, in every state"
  pass=$((pass + 1))
else
  echo "FAIL  the mirror listing was asked for, in every state"
  sed 's/^/      | /' "$FORGE_LOG"
  fail=$((fail + 1))
fi

finish
