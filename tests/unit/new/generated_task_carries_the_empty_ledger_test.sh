#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A generated task is born with an empty ledger, and the empty ledger is
# written inline. Not omitted, for the reason every null field is present:
# a reader sees the whole contract without knowing which fields a
# generator felt like writing. A project that declares no ledger carries
# this line and nothing else, forever, and satisfies every check
# (docs/product/concepts/provenance.md#the-adopter-decides-whether-to-keep-it).
setup
bash "$NEW_SH" task "Record what the work cost" --origin rule --slug record-cost >/dev/null 2>&1
f=work/tasks/task-0001-record-cost.md

if grep -qx 'provenance: \[\]' "$f"; then
  echo "ok    born with the empty ledger, inline"; pass=$((pass + 1))
else
  echo "FAIL  born with the empty ledger, inline"
  sed -n '1,18p' "$f" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# Last in the front matter, where the schema puts it: the field grows
# downward as entries arrive, so anything after it would be pushed around
# by work happening (docs/technical/README.md#task-schema).
last=$(awk '
  NR == 1 && $0 == "---" { infm = 1; next }
  infm && /^---$/ { exit }
  infm { line = $0 }
  END { sub(/:.*/, "", line); print line }
' "$f")
if [ "$last" = "provenance" ]; then
  echo "ok    and last in the front matter"; pass=$((pass + 1))
else
  echo "FAIL  and last in the front matter"
  echo "      | got: $last"
  fail=$((fail + 1))
fi

check "and the result is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish
