#!/usr/bin/env bash
# No fixture repository: this case is about *this* repository's queue,
# which the migration had to move in the same change that tightened the
# check. The moment check_date requires a timestamp, a file still holding
# a bare date is malformed — so back-filling is not a courtesy, it is
# what keeps the queue passing its own contract.
. "$(dirname "${BASH_SOURCE[0]}")/../../harness.sh"

cd "$REPO_ROOT" || exit 1
check "the repository's own queue is canonical" 0 "all canonical" \
  -- bash "$REPO_ROOT/.writrun/scripts/check_front_matter.sh"

n=$(grep -hcE '^(created|completed): [0-9]{4}-[0-9]{2}-[0-9]{2}$' \
      work/tasks/*.md work/specs/*.md 2>/dev/null | paste -sd+ - | bc)
if [ "${n:-0}" -eq 0 ]; then
  echo "ok    and no file is left holding a bare date"; pass=$((pass + 1))
else
  echo "FAIL  and no file is left holding a bare date ($n found)"
  grep -lE '^(created|completed): [0-9]{4}-[0-9]{2}-[0-9]{2}$' work/tasks/*.md work/specs/*.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
