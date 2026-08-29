#!/usr/bin/env bash
# stamp_task_dates.sh — writes the machinery's two dates onto the task
# files a merge just moved.
#
# Usage: stamp_task_dates.sh <diff-range> <timestamp>
#   The timestamp is the merge commit's own, never today's — the caller
#   reads it with
#   `TZ=UTC0 git show -s --format=%cd --date=format:%Y-%m-%dT%H:%M:%SZ`.
#
# A task carries four dates and **who writes each is part of the
# contract** (docs/product/pipeline.md#flows-and-statuses). `created` and
# `completed` are a person's, written on the branch. `queued` and
# `merged` are these: a hand-written date cannot honestly record a merge,
# because it would have to be typed before the event it describes and
# would be wrong by however long review takes.
#
#   queued  — the range **adds** the task file. The merge is what put it
#             in the queue.
#   merged  — the range moves the task **to `completed`**. The merge is
#             what took its work.
#
# The transition is read from the front matter at the range's two ends,
# never from the diff text — the rule check_state.sh and
# flip_approved_specs.sh already follow, because a task body may quote a
# `status:` line at column 0 and this repository's own docs do.
#
# **Only a `null` field is written.** A date already recorded is history,
# and a second merge touching the same file must not restate it.
#
# Mutates the working tree only and prints one "stamped" line per field
# written; committing is the caller's job. Always exits 0, except 3 for a
# usage error — a merge that moved no task is the ordinary case, not a
# failure.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions, no associative
# arrays. See the standing rule in docs/technical/decisions/.

set -euo pipefail

RANGE="${1:?usage: stamp_task_dates.sh <diff-range> <timestamp>}"
STAMP="${2:?usage: stamp_task_dates.sh <diff-range> <timestamp>}"

printf '%s' "$STAMP" \
  | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' \
  || { echo "'$STAMP' is not an RFC 3339 UTC timestamp spelled with Z" >&2; exit 3; }

# The left end of the range, which is what the file is measured against —
# `A...B`, `A..B`, and a bare ref all name it differently.
case "$RANGE" in
  *...*)
    left="${RANGE%%...*}"
    right="${RANGE##*...}"
    BASE=$(git merge-base "${left:-HEAD}" "${right:-HEAD}")
    ;;
  *..*) BASE="${RANGE%%..*}" ;;
  *)    BASE="$RANGE" ;;
esac

# fm_field <field> — stdin is a task file; prints the field's value from
# the front-matter block alone, so a body line spelling `status:` at
# column 0 is not read as one.
fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  '
}

# stamp <file> <field> — writes STAMP into <field> when it holds null.
stamp() {
  local f="$1" field="$2" cur
  cur=$(fm_field "$field" < "$f")
  if [ -z "$cur" ]; then
    echo "SKIPPED: ${f} has no '${field}' field — the canonical check will name it" >&2
    return 0
  fi
  [ "$cur" = "null" ] || return 0
  awk -v field="$field" -v stamp="$STAMP" '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && /^---$/        { infm = 0; print; next }
    infm && index($0, field ":") == 1 { print field ": " stamp; next }
    { print }
  ' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
  echo "stamped ${field} on ${f}"
}

# A task added by the range entered the queue at this merge — and if it
# arrived already completed (tracked work shipped with its own change),
# the same merge took its work too.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  [ -f "$f" ] || continue
  stamp "$f" queued
  if [ "$(fm_field status < "$f")" = "completed" ]; then stamp "$f" merged; fi
done <<EOF
$(git diff --name-only --diff-filter=A "$RANGE" -- 'work/tasks/*.md' || true)
EOF

# A task the range modified is stamped only for the transition it
# actually made: already completed at the base is not a completion here.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  [ -f "$f" ] || continue
  [ "$(fm_field status < "$f")" = "completed" ] || continue
  was=$(git show "${BASE}:${f}" 2>/dev/null | fm_field status || true)
  if [ "$was" = "completed" ]; then continue; fi
  stamp "$f" merged
done <<EOF
$(git diff --name-only --diff-filter=M "$RANGE" -- 'work/tasks/*.md' || true)
EOF

exit 0
