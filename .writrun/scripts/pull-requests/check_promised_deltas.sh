#!/usr/bin/env bash
# check_promised_deltas.sh — runs the delta contract for every spec this
# change implements.
#
# Usage: check_promised_deltas.sh <diff-range>
#
# An authoring change has no spec to check against — it ships no behaviour
# and promised no deltas; identified by the absence of any spec the change
# moved to `implemented`. Otherwise, one check_deltas.sh call with every
# implemented spec: MISSING is judged per spec, UNDECLARED against the
# union of their promises — checking each spec alone against the whole diff
# would report every sibling spec's promise as undeclared and fail a
# legitimate multi-spec completion.

set -euo pipefail
RANGE="${1:?usage: check_promised_deltas.sh <diff-range>}"

# Resolved from this script's own location, so it works from inside the
# throwaway repositories the test suite builds.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHECK_DELTAS="$REPO_ROOT/.writrun/skills/writrun-check-spec-deltas/check_deltas.sh"

# "The specs this change implements" is read from the front matter at the
# range's two ends, never grepped out of the diff text — a spec body
# quoting `status: implemented` at column 0 is not an implementation and
# must not have its promises checked against this diff.
case "$RANGE" in
  *...*)
    left="${RANGE%%...*}"
    right="${RANGE##*...}"
    BASE=$(git merge-base "${left:-HEAD}" "${right:-HEAD}")
    ;;
  *..*) BASE="${RANGE%%..*}" ;;
  *)    BASE="$RANGE" ;;
esac
fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  '
}

implemented=""
for s in $(git diff --name-only "$RANGE" -- 'work/specs/*.md' || true); do
  [ -f "$s" ] || continue
  [ "$(fm_field status < "$s")" = "implemented" ] || continue
  [ "$(git show "${BASE}:$s" 2>/dev/null | fm_field status)" = "implemented" ] && continue
  implemented="$implemented $s"
done

if [ -z "$implemented" ]; then
  echo "No spec reached 'implemented' — authoring change, deltas not applicable."
  exit 0
fi

ids=""
for s in $implemented; do
  id=$(sed -n 's/^id: *//p' "$s" | head -n1)
  ids="${ids:+${ids},}${id}"
done
echo "Checking ${ids}"
bash "$CHECK_DELTAS" "$ids" "$RANGE"
