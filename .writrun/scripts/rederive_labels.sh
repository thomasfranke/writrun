#!/usr/bin/env bash
# rederive_labels.sh — after a merge records an approval, label the tasks
# it affected from the queue as it then stands.
#
# Usage: rederive_labels.sh <owner/repo> <spec-file>...
#   Run from a checkout of the authority branch, *after* the flip has been
#   committed to it — the whole point is to read the queue's new state.
#   `gh` must be on PATH and authenticated (GH_TOKEN in CI; a stub in the
#   test suite). With no spec files, it does nothing and says so.
#
# Why this exists: `status:ready` was unreachable. The mirror derived it
# from the spec statuses in the merged pull request's *diff*, where they
# are still `draft` — because that same merge is what approves them. So
# every task merged this way sat on `status:pending` with its specs
# approved, and no later event ever corrected it.
#
# **Reading the diff is right for what the merge carried; it is wrong for
# what the merge caused** (docs/product/pipeline.md#flows-and-statuses).
# So this reads neither a diff nor a patch: it reads the files, which is
# the only source that reflects the flip the merge just triggered.
#
# The question it answers — "what label does this task deserve now" — is
# the same one mirror_issues.sh asks of a pull request's diff. Same
# question, different input, which is why it is a script of its own rather
# than a branch inside either caller.
#
# Exit codes: 0 done (including nothing to do); 3 usage error.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions, no associative
# arrays. See the standing rule in docs/technical/decisions/.

set -euo pipefail

REPO="${1:?usage: rederive_labels.sh <owner/repo> <spec-file>...}"
shift

TAB=$(printf '\t')

if printf '' | base64 -d >/dev/null 2>&1; then B64_FLAG="-d"; else B64_FLAG="-D"; fi
b64_decode() { base64 "$B64_FLAG"; }

fm() {   # fm <file> <field>
  awk -v f="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  ' "$1"
}

# queue_file <dir> <prefix> <id> — the file whose id is <id>, whatever its
# subject slug and whatever width its number was written at.
queue_file() {
  local dir="$1" prefix="$2" want f n
  want=$(printf '%s' "$3" | tr '[:upper:]' '[:lower:]' \
    | sed -E "s/^${prefix}-0*([0-9]+)$/\1/")
  [ -n "$want" ] || return 0
  case "$want" in *[!0-9]*) return 0 ;; esac
  for f in "$dir"/"$prefix"-*.md; do
    [ -f "$f" ] || continue
    n=$(basename "$f" .md | tr '[:upper:]' '[:lower:]' \
      | sed -E "s/^${prefix}-0*([0-9]+).*/\1/")
    case "$n" in ''|*[!0-9]*) continue ;; esac
    if [ "$n" -eq "$want" ]; then printf '%s' "$f"; return 0; fi
  done
  return 0
}

# label_for <task-file> — the label this task deserves from the queue on
# disk, or nothing when the machinery should not touch it.
#
# Only a `pending` task is re-derived. `in-progress` and the states that
# follow it belong to reflect_progress.sh, which knows something the queue
# does not: whether a pull request is open. Overwriting those from here
# would tell a worker's mirror it is available again, on the strength of
# an approval that changed nothing about who is working it.
label_for() {
  local tf status refs r sf ss
  status=$(fm "$1" status)
  [ "$status" = "pending" ] || return 0
  refs=$(fm "$1" spec_ref | sed 's/^\[//; s/\]$//; s/,/ /g')
  for r in $refs; do
    [ -n "$r" ] || continue
    sf=$(queue_file work/specs spec "$r")
    # A ref that resolves to nothing is not an approval. Say pending
    # rather than guessing; the canonical check owns the broken ref.
    [ -n "$sf" ] || { printf 'status:pending'; return 0; }
    ss=$(fm "$sf" status)
    case "$ss" in
      approved|implemented) ;;
      *) printf 'status:pending'; return 0 ;;
    esac
  done
  # No refs at all is approved by construction — nothing is holding it.
  printf 'status:ready'
}

if [ "$#" -eq 0 ]; then
  echo "No approval was recorded by this merge — no label to re-derive."
  exit 0
fi

# The mirrors, fetched once. Identity is the tag in the title, the same
# way every other lookup here resolves it. The row shape is the one every
# reader of this list requests — body included and unused here — because
# one shape across all three readers is worth more than one saved field.
ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '.[] | [.number, .state, ((.labels // []) | map(.name) | join(",")), (.title | @base64), ((.body // "") | @base64)] | @tsv')

id_of_title() {
  printf '%s' "$1" | sed -n \
    -e 's/^\[\([Tt][Aa][Ss][Kk]-[0-9][0-9]*\)\].*/\1/p' \
    -e 's/^\([Tt][Aa][Ss][Kk]-[0-9][0-9]*\)[[:space:]].*/\1/p' \
    | head -n1 | tr '[:upper:]' '[:lower:]'
}
num_of_id() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -n 's/^task-0*\([0-9][0-9]*\)$/\1/p'
}

set_status() {   # set_status <issue> <labels-csv> <status-label>
  local kept l args
  kept=$(printf '%s\n' "$2" | tr ',' '\n' | grep -v '^status:' | sed '/^$/d' || true)
  args=()
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    args+=(-f "labels[]=$l")
  done <<EOF
$kept
EOF
  args+=(-f "labels[]=$3")
  gh api -X PUT "repos/${REPO}/issues/${1}/labels" "${args[@]}" >/dev/null
}

ensure_label() {   # ensure_label <name> <color> <description>
  local out
  if ! out=$(gh api -X POST "repos/${REPO}/labels" \
      -f "name=$1" -f "color=$2" -f "description=$3" 2>&1); then
    printf '%s\n' "$out" | grep -q "HTTP 422" \
      || { printf '%s\n' "$out" >&2; exit 1; }
  fi
}

seen=""
for sf in "$@"; do
  [ -f "$sf" ] || continue
  tref=$(fm "$sf" task_ref)
  [ -n "$tref" ] || continue
  tnum=$(num_of_id "$tref")
  [ -n "$tnum" ] || continue
  # A pull request may approve several specs of one task; label it once.
  case " $seen " in *" $tnum "*) continue ;; esac
  seen="$seen $tnum"

  tf=$(queue_file work/tasks task "$tref")
  if [ -z "$tf" ]; then
    echo "${tref}: no task file on this branch — nothing to derive from."
    continue
  fi

  want=$(label_for "$tf")
  if [ -z "$want" ]; then
    echo "${tref} is $(fm "$tf" status) — its label is not this step's to write."
    continue
  fi

  found=""
  while IFS="$TAB" read -r n istate labels tb bb; do
    [ -n "$n" ] || continue
    t=$(printf '%s' "$tb" | b64_decode)
    tn=$(num_of_id "$(id_of_title "$t")")
    [ -n "$tn" ] || continue
    if [ "$tn" -eq "$tnum" ] 2>/dev/null; then
      found="${n}${TAB}${istate}${TAB}${labels}"; break
    fi
  done <<EOF
$ISSUES
EOF

  if [ -z "$found" ]; then
    echo "${tref}: no mirrored Issue."
    continue
  fi

  num=$(printf '%s' "$found" | cut -f1)
  istate=$(printf '%s' "$found" | cut -f2)
  labels=$(printf '%s' "$found" | cut -f3)

  # Closing wins. A mirror closed by the same merge is out of the
  # pipeline, and every label names a place inside it.
  if [ "$istate" != "open" ]; then
    echo "${tref}: mirror #${num} is closed — no label is written."
    continue
  fi

  case "$want" in
    status:ready)
      ensure_label "status:ready" "0e8a16" "Ready for development: task pending, specs approved" ;;
    status:pending)
      ensure_label "status:pending" "fbca04" "In the queue, with a spec it references not yet approved" ;;
  esac
  set_status "$num" "$labels" "$want"
  echo "${tref} → ${want} (re-derived from the queue)"
done
