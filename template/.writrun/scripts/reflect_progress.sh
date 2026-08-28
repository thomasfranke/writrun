#!/usr/bin/env bash
# reflect_progress.sh — moves a task's mirrored Issue as its pull request
# moves: in-progress while a draft, in-review while open, closed when a
# merge completes the task, back to ready when the PR dies unmerged.
#
# Usage: reflect_progress.sh <owner/repo> <pr-number>
#   The pull request's fields arrive via the environment — never inline
#   interpolation; the head branch name in particular is a fork's to
#   choose and is only ever handled as data:
#     PR_STATE     open | closed
#     PR_DRAFT     true | false
#     PR_MERGED    true | false
#     PR_HEAD_REF  the PR's branch name, resolved to a task below
#
# Runs from a checkout of the base branch: a spec branch is resolved to
# its task through the base tree's own work/specs/ file — the same
# resolution list_tasks.sh performs, kept deliberately identical. The
# PR's code is never checked out; on the merged path its files are read
# as API patch data only.
#
# It relabels only. Nothing here reserves a task — reserving work is a
# tracker's job, not this methodology's (docs/about.md, non-goals). The
# label reports where the work is; it does not hold it for anyone.
#
# `status:in-review` is a label of its own rather than part of
# `status:in-progress` because the two ask opposite things of the
# maintainer: one means leave the worker alone, the other means the
# maintainer is the blocker.
#
# Exit codes: 0 reflected (including nothing to reflect); 3 usage error.
# An unexpected forge failure aborts non-zero via set -e.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions.

set -euo pipefail

REPO="${1:?usage: reflect_progress.sh <owner/repo> <pr-number>}"
PR="${2:?usage: reflect_progress.sh <owner/repo> <pr-number>}"
: "${PR_STATE:?PR_STATE (open|closed) must arrive via the environment}"
: "${PR_DRAFT:?PR_DRAFT (true|false) must arrive via the environment}"
: "${PR_MERGED:?PR_MERGED (true|false) must arrive via the environment}"
: "${PR_HEAD_REF:?PR_HEAD_REF (the PR head branch) must arrive via the environment}"

TAB=$(printf '\t')
branch="$PR_HEAD_REF"

if printf '' | base64 -d >/dev/null 2>&1; then B64_FLAG="-d"; else B64_FLAG="-D"; fi
b64_decode() { base64 "$B64_FLAG"; }

# queue_file <dir> <prefix> <number> — the queue file whose id is that
# number, whatever its filename subject and whatever width the number was
# written at. Identity is the id; `task-0004-file-naming.md`,
# `task-0004.md` and the historical `task-004.md` are the same task, and a
# branch naming any of them must resolve to the one file that exists.
queue_file() {
  qf_want=$(printf '%s' "$3" | sed -n 's/^0*\([0-9][0-9]*\)$/\1/p')
  [ -n "$qf_want" ] || return 0
  for qf_f in "$1"/"$2"-*.md; do
    [ -f "$qf_f" ] || continue
    qf_n=$(basename "$qf_f" .md | tr '[:upper:]' '[:lower:]' \
      | sed -n "s/^$2-0*\([0-9][0-9]*\).*/\1/p")
    [ -n "$qf_n" ] || continue
    if [ "$qf_n" -eq "$qf_want" ] 2>/dev/null; then printf '%s' "$qf_f"; return 0; fi
  done
  return 0
}

# Resolve the branch back to a task. A branch is named after the spec it
# implements, or the task when there is none — so a spec has to be
# resolved through its task_ref. The patterns are anchored to the
# branch's start (one optional path segment), like list_tasks.sh's sed —
# unanchored, a branch such as `spec/012-split-task-4` would resolve to
# task-4 instead of spec-012 and move the wrong mirror.
task_id=""
tnum=$(printf '%s' "$branch" | sed -n 's|^[a-z]*/\{0,1\}task-0*\([0-9][0-9]*\).*|\1|p')
if [ -z "$tnum" ]; then
  snum=$(printf '%s' "$branch" | sed -n 's|^[a-z]*/\{0,1\}spec-0*\([0-9][0-9]*\).*|\1|p')
  if [ -z "$snum" ]; then
    # `spec/0003-name` — the bare number form the branch convention uses.
    snum=$(printf '%s' "$branch" | sed -n 's|^spec/0*\([0-9][0-9]*\).*|\1|p')
  fi
  if [ -n "$snum" ]; then
    sf=$(queue_file work/specs spec "$snum")
    [ -n "$sf" ] && task_id=$(sed -n 's/^task_ref: *//p' "$sf" | head -n1 \
      | sed 's/[[:space:]]*$//')
  fi
  if [ -z "$task_id" ]; then
    tnum=$(printf '%s' "$branch" | sed -n 's|^task/0*\([0-9][0-9]*\).*|\1|p')
  fi
fi
if [ -z "$task_id" ] && [ -n "$tnum" ]; then
  # The task's own file is the authority on how its id is written; a task
  # this branch is adding has no file here yet, and the documented width
  # is the answer then.
  tf=$(queue_file work/tasks task "$tnum")
  if [ -n "$tf" ]; then
    task_id=$(sed -n 's/^id: *//p' "$tf" | head -n1 | sed 's/[[:space:]]*$//')
  else
    task_id=$(printf 'task-%04d' "$tnum")
  fi
fi

# The number is what identifies the task from here on. Width is spelling,
# not identity: a queue written before four digits, and its mirrors, name
# the same task as a branch that spells it wider.
task_num=$(printf '%s' "$task_id" | sed -n 's/^task-0*\([0-9][0-9]*\)$/\1/p')

if [ -z "$task_id" ]; then
  echo "Branch \"${branch}\" names no task; nothing to reflect."
  exit 0
fi
task_id=$(printf '%s' "$task_id" | tr '[:upper:]' '[:lower:]')

ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '.[] | [.number, .state, ((.labels // []) | map(.name) | join(",")), (.title | @base64), ((.body // "") | @base64)] | @tsv')

issue_num=""
issue_labels=""
while IFS="$TAB" read -r num istate labels tb bb; do
  [ -n "$num" ] || continue
  t=$(printf '%s' "$tb" | b64_decode | tr '[:upper:]' '[:lower:]')
  # A mirror's title opens with the task's id. Match on its number so a
  # mirror titled at one width is still found by a branch spelling it at
  # another — the id is the number, not how many zeroes precede it.
  tn=$(printf '%s' "$t" | sed -n 's/^task-0*\([0-9][0-9]*\) .*/\1/p')
  [ -n "$tn" ] || continue
  if [ -n "$task_num" ] && [ "$tn" -eq "$task_num" ] 2>/dev/null; then
    issue_num="$num"; issue_labels="$labels"; break
  fi
done <<EOF
$ISSUES
EOF

if [ -z "$issue_num" ]; then
  echo "No mirrored Issue for ${task_id}."
  exit 0
fi

ensure_label() {   # ensure_label <name> <color> <description>
  local out
  if ! out=$(gh api -X POST "repos/${REPO}/labels" \
      -f "name=$1" -f "color=$2" -f "description=$3" 2>&1); then
    # 422 = already exists; anything else is a real failure.
    printf '%s\n' "$out" | grep -q "HTTP 422" \
      || { printf '%s\n' "$out" >&2; exit 1; }
  fi
}

set_status() {   # set_status <status-label> — keeps every non-status label
  local kept l args
  kept=$(printf '%s\n' "$issue_labels" | tr ',' '\n' \
    | grep -v '^status:' | sed '/^$/d' || true)
  args=()
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    args+=(-f "labels[]=$l")
  done <<EOF
$kept
EOF
  args+=(-f "labels[]=$1")
  gh api -X PUT "repos/${REPO}/issues/${issue_num}/labels" "${args[@]}" >/dev/null
}

if [ "$PR_STATE" = "open" ]; then
  if [ "$PR_DRAFT" = "true" ]; then
    ensure_label "status:in-progress" "bfd4f2" "Someone is working on it; leave the worker alone"
    set_status "status:in-progress"
    echo "${task_id} → status:in-progress (draft #${PR})"
  else
    ensure_label "status:in-review" "d93f0b" "A pull request is open and waiting on review"
    set_status "status:in-review"
    echo "${task_id} → status:in-review (#${PR})"
  fi
  exit 0
fi

if [ "$PR_MERGED" != "true" ]; then
  # Closed without merging. The work is not done, and nothing reserves
  # the task — it is available again.
  ensure_label "status:ready" "0e8a16" "Ready for development: task pending, specs approved"
  set_status "status:ready"
  echo "${task_id} → status:ready (#${PR} closed unmerged)"
  exit 0
fi

# Merged. The Issue closes only if the merge actually completed the task
# — a PR can merge partial work, and closing then would hide a task that
# is still outstanding. The completion keys on an actual
# `+status: completed` line in the merged diff's patch text.
FILES=$(gh api "repos/${REPO}/pulls/${PR}/files" --paginate \
  --jq '.[] | [.status, .filename, ((.patch // "") | @base64)] | @tsv')

completed=false
while IFS="$TAB" read -r fstatus fname fpatch; do
  [ -n "$fname" ] || continue
  printf '%s' "$fname" | tr '[:upper:]' '[:lower:]' \
    | grep -qE "^work/tasks/task-0*${task_num}(-[a-z0-9-]+)?\.md$" || continue
  if printf '%s' "$fpatch" | b64_decode | grep -qxF '+status: completed'; then
    completed=true
  fi
  break
done <<EOF
$FILES
EOF

if [ "$completed" != "true" ]; then
  ensure_label "status:in-progress" "bfd4f2" "Someone is working on it; leave the worker alone"
  set_status "status:in-progress"
  echo "${task_id} merged but not completed — back to status:in-progress"
  exit 0
fi

gh api -X PATCH "repos/${REPO}/issues/${issue_num}" \
  -f state=closed -f state_reason=completed >/dev/null
echo "${task_id} completed — Issue #${issue_num} closed"
