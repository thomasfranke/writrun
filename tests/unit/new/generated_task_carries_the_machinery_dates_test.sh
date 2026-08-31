#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A generated task carries all four dates, and the machinery's two are
# born null: they record merges, and nothing has merged yet.
setup
bash "$NEW_SH" task "Stamp the queue dates" --origin rule --slug stamp-queue-dates >/dev/null 2>&1
f=work/tasks/task-0001-stamp-queue-dates.md

for want in "queued: null" "merged: null"; do
  if grep -qx "$want" "$f"; then
    echo "ok    generated with '${want}'"; pass=$((pass + 1))
  else
    echo "FAIL  generated with '${want}'"
    sed -n '1,16p' "$f" | sed 's/^/      | /'
    fail=$((fail + 1))
  fi
done

# The documented order, which is the order the schema shows: a person's
# date, then the merge that followed it, twice.
order=$(awk '
  NR == 1 && $0 == "---" { infm = 1; next }
  infm && /^---$/ { exit }
  infm && /^(created|queued|completed|merged):/ { sub(/:.*/, ""); printf "%s ", $0 }
' "$f")
if [ "$order" = "created queued completed merged " ]; then
  echo "ok    in the documented order"; pass=$((pass + 1))
else
  echo "FAIL  in the documented order"
  echo "      | got: $order"
  fail=$((fail + 1))
fi

check "and the result is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
