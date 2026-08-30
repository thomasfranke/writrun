#!/usr/bin/env bash
# reflect_progress.sh — moves the mirrored Issue of every task a pull
# request carries as that pull request moves: in-progress while a draft,
# in-review while open, closed when a merge completes the task, back to
# ready when the PR dies unmerged.
#
# Usage: reflect_progress.sh <owner/repo> <pr-number>
#   The pull request's fields arrive via the environment — never inline
#   interpolation; the title and head branch in particular are a fork's to
#   choose and are only ever handled as data:
#     PR_STATE     open | closed
#     PR_DRAFT     true | false
#     PR_MERGED    true | false
#     PR_HEAD_REF  the PR's branch name, the fallback resolution
#     PR_TITLE     the PR's title, whose leading [TASK-NNNN] tags are the
#                  task set when present (optional; empty falls back)
#
# **The title is the authority on which tasks a PR carries**, because a
# branch name holds one id and a pull request may carry several
# (.writrun/conventions/prs.md). The branch marker remains the fallback,
# for a PR opened before the convention and for one whose title carries
# no tag.
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
PR_TITLE="${PR_TITLE:-}"

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

# tags_from_title — the numbers of the [TASK-NNNN] tags **leading** the
# title, in order, deduplicated. Only the leading run counts: a
# tag-shaped string later in a title is prose, and reading it as a tag
# would move a mirror the author never named.
tags_from_title() {
  tt_rest="$1"
  tt_nums=""
  while :; do
    tt_rest=$(printf '%s' "$tt_rest" | sed 's/^[[:space:]]*//')
    tt_n=$(printf '%s' "$tt_rest" \
      | sed -n 's/^\[[Tt][Aa][Ss][Kk]-0*\([0-9][0-9]*\)\].*/\1/p')
    [ -n "$tt_n" ] || break
    case " $tt_nums " in *" $tt_n "*) ;; *) tt_nums="$tt_nums $tt_n" ;; esac
    tt_rest=$(printf '%s' "$tt_rest" | sed 's/^\[[Tt][Aa][Ss][Kk]-[0-9][0-9]*\]//')
  done
  printf '%s' "${tt_nums# }"
}

# num_from_branch — the fallback: a branch is named after the task being
# worked, or historically after the spec, which resolves through its
# task_ref. The patterns are anchored to the branch's start (one optional
# path segment), like list_tasks.sh's sed — unanchored, a branch such as
# `spec/012-split-task-4` would resolve to task-4 instead of spec-012 and
# move the wrong mirror.
# Prints "<number>" or "<number> <id-as-the-queue-writes-it>". Two values
# on one line because a command substitution runs in a subshell, where a
# global assignment would be discarded.
num_from_branch() {
  nb_t=$(printf '%s' "$1" | sed -n 's|^[a-z]*/\{0,1\}task-0*\([0-9][0-9]*\).*|\1|p')
  if [ -n "$nb_t" ]; then printf '%s' "$nb_t"; return 0; fi
  nb_s=$(printf '%s' "$1" | sed -n 's|^[a-z]*/\{0,1\}spec-0*\([0-9][0-9]*\).*|\1|p')
  if [ -z "$nb_s" ]; then
    # `spec/0003-name` — the bare number form the branch convention used.
    nb_s=$(printf '%s' "$1" | sed -n 's|^spec/0*\([0-9][0-9]*\).*|\1|p')
  fi
  if [ -n "$nb_s" ]; then
    nb_f=$(queue_file work/specs spec "$nb_s")
    if [ -n "$nb_f" ]; then
      nb_ref=$(sed -n 's/^task_ref: *//p' "$nb_f" | head -n1 | sed 's/[[:space:]]*$//')
      nb_t=$(printf '%s' "$nb_ref" | sed -n 's/^task-0*\([0-9][0-9]*\)$/\1/p')
      if [ -n "$nb_t" ]; then
        # The spec's own `task_ref` is how this queue writes that id, and
        # is the authority when the task's file is not here to say.
        printf '%s %s' "$nb_t" "$nb_ref"; return 0
      fi
    fi
  fi
  printf '%s' "$(printf '%s' "$1" | sed -n 's|^task/0*\([0-9][0-9]*\).*|\1|p')"
}

ID_HINT=""
TASK_NUMS=$(tags_from_title "$PR_TITLE")
tag_sourced=true
if [ -z "$TASK_NUMS" ]; then
  tag_sourced=false
  nb_out=$(num_from_branch "$branch")
  TASK_NUMS=$(printf '%s' "$nb_out" | cut -d' ' -f1)
  ID_HINT=$(printf '%s ' "$nb_out" | cut -d' ' -f2)
fi

if [ -z "$TASK_NUMS" ]; then
  echo "Neither the title nor branch \"${branch}\" names a task; nothing to reflect."
  exit 0
fi

ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '.[] | [.number, .state, ((.labels // []) | map(.name) | join(",")), (.title | @base64), ((.body // "") | @base64)] | @tsv')

FILES=""
if [ "$PR_STATE" != "open" ] && [ "$PR_MERGED" = "true" ]; then
  FILES=$(gh api "repos/${REPO}/pulls/${PR}/files" --paginate \
    --jq '.[] | [.status, .filename, ((.patch // "") | @base64)] | @tsv')
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

# clear_status <issue> <labels-csv> — the mirror keeps everything except
# its place in the pipeline.
#
# **A closed mirror carries no `status:` label**
# (docs/product/stage-3-github-issues/labels.md). Every label in that table
# names a place *inside* the pipeline, so any of them on a closed issue is
# a leftover from the step before last — and a leftover is not merely
# useless, it is false: an issue closed as completed reading
# `status:in-review` says the maintainer is still the blocker. The close
# and its reason are the terminal state, and the forge records those
# rather than anyone having to remember to write them.
clear_status() {
  local kept l args
  kept=$(printf '%s\n' "$2" | tr ',' '\n' | grep -v '^status:' | sed '/^$/d' || true)
  args=()
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    args+=(-f "labels[]=$l")
  done <<EOF
$kept
EOF
  if [ "${#args[@]}" -eq 0 ]; then
    # PUT needs a list to set; DELETE is how the forge spells "none".
    gh api -X DELETE "repos/${REPO}/issues/${1}/labels" >/dev/null
    return 0
  fi
  gh api -X PUT "repos/${REPO}/issues/${1}/labels" "${args[@]}" >/dev/null
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

# reflect_one <task-number> — the whole per-task move, exactly as it was
# when a pull request could only carry one.
reflect_one() {
  local num="$1" task_id tf issue_num issue_labels n istate labels tb bb t tn
  local fstatus fname fpatch completed

  tf=$(queue_file work/tasks task "$num")
  if [ -n "$tf" ]; then
    task_id=$(sed -n 's/^id: *//p' "$tf" | head -n1 | sed 's/[[:space:]]*$//')
  elif [ -n "$ID_HINT" ]; then
    # No task file here — a spec's `task_ref` recorded how this queue
    # writes that id, and it outranks a guess.
    task_id="$ID_HINT"
  else
    # A task this pull request is adding has no file on the base branch
    # yet, and the documented width is the answer then.
    task_id=$(printf 'task-%04d' "$num")
  fi
  task_id=$(printf '%s' "$task_id" | tr '[:upper:]' '[:lower:]')

  issue_num=""
  issue_labels=""
  while IFS="$TAB" read -r n istate labels tb bb; do
    [ -n "$n" ] || continue
    t=$(printf '%s' "$tb" | b64_decode | tr '[:upper:]' '[:lower:]')
    # A mirror's title opens with the task's tag, `[TASK-NNNN]` — and
    # with the bare `task-NNNN ` prefix on any mirror minted before that
    # rule, which must still be found rather than reported missing.
    # Match on the number so a mirror titled at one width is still found
    # by a tag spelling it at another — the id is the number, not how
    # many zeroes precede it. `$t` is already lowercased above.
    tn=$(printf '%s' "$t" | sed -n \
      -e 's/^\[task-0*\([0-9][0-9]*\)\].*/\1/p' \
      -e 's/^task-0*\([0-9][0-9]*\)[[:space:]].*/\1/p' \
      | head -n1)
    [ -n "$tn" ] || continue
    if [ "$tn" -eq "$num" ] 2>/dev/null; then
      issue_num="$n"; issue_labels="$labels"; break
    fi
  done <<EOF
$ISSUES
EOF

  if [ -z "$issue_num" ]; then
    echo "No mirrored Issue for ${task_id}."
    return 0
  fi

  if [ "$PR_STATE" = "open" ]; then
    if [ "$PR_DRAFT" = "true" ]; then
      ensure_label "status:in-progress" "bfd4f2" "Someone is working on it; leave the worker alone"
      set_status "$issue_num" "$issue_labels" "status:in-progress"
      echo "${task_id} → status:in-progress (draft #${PR})"
    else
      ensure_label "status:in-review" "d93f0b" "A pull request is open and waiting on review"
      set_status "$issue_num" "$issue_labels" "status:in-review"
      echo "${task_id} → status:in-review (#${PR})"
    fi
    return 0
  fi

  if [ "$PR_MERGED" != "true" ]; then
    # Closed without merging. The work is not done, and nothing reserves
    # the task — it is available again.
    ensure_label "status:ready" "0e8a16" "Ready for development — waiting for someone to take it"
    set_status "$issue_num" "$issue_labels" "status:ready"
    echo "${task_id} → status:ready (#${PR} closed unmerged)"
    return 0
  fi

  # Merged. The Issue closes only if the merge actually completed *this*
  # task — a PR can merge partial work, or complete one carried task and
  # not another, and closing then would hide a task still outstanding.
  # The completion keys on the worker's declaration in the merged diff's
  # patch text for this task's own file: a `+completed:` line writing a
  # real date. The status flip itself is the machinery's, after the
  # merge — the diff never carries it (statuses.md).
  completed=false
  while IFS="$TAB" read -r fstatus fname fpatch; do
    [ -n "$fname" ] || continue
    printf '%s' "$fname" | tr '[:upper:]' '[:lower:]' \
      | grep -qE "^work/tasks/task-0*${num}(-[a-z0-9-]+)?\.md$" || continue
    if printf '%s' "$fpatch" | b64_decode \
      | grep -qE '^\+completed: [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'; then
      completed=true
    fi
    break
  done <<EOF
$FILES
EOF

  if [ "$completed" != "true" ]; then
    ensure_label "status:in-progress" "bfd4f2" "Someone is working on it; leave the worker alone"
    set_status "$issue_num" "$issue_labels" "status:in-progress"
    echo "${task_id} merged but not completed — back to status:in-progress"
    return 0
  fi

  # Stripped as part of closing, never afterwards: a mirror already closed
  # is not reopened to correct its labels.
  clear_status "$issue_num" "$issue_labels"
  gh api -X PATCH "repos/${REPO}/issues/${issue_num}" \
    -f state=closed -f state_reason=completed >/dev/null
  echo "${task_id} completed — Issue #${issue_num} closed"
}

if [ "$tag_sourced" = "true" ]; then
  echo "Title tags name: $(printf '%s' "$TASK_NUMS" | tr ' ' ',')"
fi
for tnum in $TASK_NUMS; do
  reflect_one "$tnum"
done
