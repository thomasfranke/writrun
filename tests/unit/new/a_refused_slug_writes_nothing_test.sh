#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A slug that would produce a filename check_front_matter.sh then rejects
# is refused where it is typed, not written and discovered at the merge.
setup

check "an out-of-contract slug is refused" 3 "outside the filename contract" \
  -- bash "$NEW_SH" task "Mine" --origin rule --slug Bad_Slug
check "and so is a leading hyphen" 3 "outside the filename contract" \
  -- bash "$NEW_SH" task "Mine" --origin rule --slug -leading
check "and a trailing one" 3 "outside the filename contract" \
  -- bash "$NEW_SH" task "Mine" --origin rule --slug trailing-

# `task-0004-2-of-3.md` reads as id 4 to every prefix resolver here.
check "a slug that reads as the id is refused, and says why" 3 \
  "reads as a continuation of the id" \
  -- bash "$NEW_SH" task "Mine" --origin rule --slug 2-of-3

# Empty is refused, not treated as absent: it was typed, so it was meant.
check "an empty slug is refused, not treated as absent" 3 \
  "omit the flag to derive one" \
  -- bash "$NEW_SH" task "Mine" --origin rule --slug ""

# The spec subcommand refuses on the same terms, before its task is even
# resolved.
check "a spec's slug is refused the same way" 3 "outside the filename contract" \
  -- bash "$NEW_SH" spec task-0001 "Mine" --slug Bad_Slug

left=$(find work/tasks work/specs -type f)
if [ -z "$left" ]; then
  echo "ok    every refusal left the queue untouched"; pass=$((pass + 1))
else
  echo "FAIL  every refusal left the queue untouched"
  printf '%s\n' "$left" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish
