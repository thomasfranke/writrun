#!/usr/bin/env bash
# record_task_status.sh — the merge's half of the transition machine:
# moves every task the merge affected to where the queue now says it
# belongs, on the working tree, in the same recording commit as the spec
# flips and date stamps (product/stage-1-tasks-and-specs/statuses.md).
#
# Usage: record_task_status.sh <diff-range> [carried-task-id...]
#   The carried ids are the tasks whose work this merge took — the head
#   branch's own (task/NNNN-*) and every [TASK-NNNN] tag leading the
#   merged title — so a merge whose diff never touched a task file
#   still lands it.
#
# Per task in scope — added or modified by the range, referenced by a
# spec the range touched, or carried — one of three moves, in this
# order:
#
#   done    its `completed` date is written: the worker declared
#           finishing and the merge took the work. `taken_by` stays —
#           the record of who completed it.
#   land    carried, in flight, no declaration: one spec of several is
#           work taken, not finished — to ready, or backlog if any of
#           its specs is draft, derived now, never assumed. taken_by
#           cleared. **Only a carried task lands**: a merge that merely
#           touches an in-flight task's spec — an amendment landing
#           while the work rides another, still-open pull request —
#           says nothing about that work, and a task it pulled back to
#           ready would read as free while somebody's PR is open. The
#           in-flight state belongs to the task's own pull request's
#           events, and to no other merge.
#   settle  it rests in backlog or ready: re-derived from its specs as
#           they now stand — the approval this merge recorded, or the
#           amendment it landed, may have moved the answer. An empty
#           spec_ref settles to ready: no approval event exists for it,
#           and backlog must not be a trap.
#
# blocked and dropped are a person's and are never touched. A task
# already where it belongs writes nothing. Always exits 0, except 3 when
# git cannot read the range — an unreadable range is not an empty one.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions. See the
# standing rule in docs/technical/decisions/.

set -euo pipefail

RANGE="${1:?usage: record_task_status.sh <diff-range> [carried-task-id...]}"
shift
CARRIED_IDS="$*"

err=$(mktemp "${TMPDIR:-/tmp}/writrun-git.XXXXXX")
if ! CHANGED=$(git diff --name-only "$RANGE" 2>"$err"); then
  echo "git diff --name-only ${RANGE} failed:" >&2
  head -n 2 "$err" >&2
  rm -f "$err"
  exit 3
fi
rm -f "$err"

fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  ' "$2"
}

set_field() {   # set_field <file> <field> <value> — front matter only
  awk -v field="$2" -v value="$3" '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && /^---$/        { infm = 0; print; next }
    infm && index($0, field ":") == 1 { print field ": " value; next }
    { print }
  ' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

resting() {   # ready, or backlog if any referenced spec is draft
  local refs ref spec st
  refs=$(fm_field spec_ref "$1" | tr -d '[]' | tr ',' ' ')
  for ref in $refs; do
    [ -n "$ref" ] || continue
    spec=$(find work/specs \( -iname "${ref}.md" -o -iname "${ref}-*.md" \) 2>/dev/null | head -n1)
    [ -n "$spec" ] || continue
    st=$(fm_field status "$spec")
    [ "$st" = "draft" ] && { printf 'backlog'; return 0; }
  done
  printf 'ready'
}

# The scope: task files the range touched, tasks of specs it touched,
# and the head branch's own.
SCOPE=""
add_scope() {
  case " $SCOPE " in *" $1 "*) ;; *) SCOPE="$SCOPE $1" ;; esac
}
while IFS= read -r f; do
  case "$f" in
    work/tasks/task-*.md) [ -f "$f" ] && add_scope "$f" ;;
    work/specs/spec-*.md)
      [ -f "$f" ] || continue
      tref=$(fm_field task_ref "$f")
      [ -n "$tref" ] || continue
      tf=$(find work/tasks \( -iname "${tref}.md" -o -iname "${tref}-*.md" \) 2>/dev/null | head -n1)
      [ -n "$tf" ] && add_scope "$tf"
      ;;
  esac
done <<EOF
$CHANGED
EOF
CARRIED_FILES=""
for cid in $CARRIED_IDS; do
  num=$(printf '%s' "$cid" | sed -E 's/^task-0*//; s/[^0-9].*$//')
  [ -n "$num" ] || continue
  tf=$(find work/tasks \( -iname "task-*${num}.md" -o -iname "task-*${num}-*.md" \) 2>/dev/null \
    | while IFS= read -r c; do
        cid2=$(basename "$c" .md | sed -E 's/^task-0*//; s/[^0-9].*$//')
        [ "$cid2" = "$num" ] && printf '%s\n' "$c"
      done | head -n1)
  [ -n "$tf" ] || continue
  add_scope "$tf"
  CARRIED_FILES="$CARRIED_FILES $tf"
done

is_carried() {
  case " $CARRIED_FILES " in *" $1 "*) return 0 ;; esac
  return 1
}

for f in $SCOPE; do
  st=$(fm_field status "$f")
  case "$st" in
    blocked|dropped) continue ;;   # a person's, never the machinery's
  esac

  cdate=$(fm_field completed "$f")
  if [ -n "$cdate" ] && [ "$cdate" != "null" ]; then
    [ "$st" = "done" ] || { set_field "$f" status done; echo "moved ${f}: ${st} -> done"; }
    continue
  fi

  case "$st" in
    in-progress|in-review)
      # Only the merge that carried this task's work lands it; any
      # other merge leaves the in-flight state to the task's own pull
      # request's events.
      if is_carried "$f"; then
        dest=$(resting "$f")
        set_field "$f" status "$dest"
        set_field "$f" taken_by null
        echo "moved ${f}: ${st} -> ${dest}"
      fi
      ;;
    backlog|ready)
      dest=$(resting "$f")
      if [ "$dest" != "$st" ]; then
        set_field "$f" status "$dest"
        echo "moved ${f}: ${st} -> ${dest}"
      fi
      ;;
  esac
done

exit 0
