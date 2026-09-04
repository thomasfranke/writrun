#!/usr/bin/env bash
# apply_pr_event.sh — turns one pull-request forge event into the status
# writes it implies, via flip_task_status.sh. The workflow wires events to
# this; the edge table lives in the flip script and in
# product/stage-2-pull-requests/statuses.md.
#
# Usage: apply_pr_event.sh <event>
#   <event>: opened | reopened | ready_for_review | converted_to_draft |
#            review_requested | changes_requested | closed
#
# Context arrives in env, never argv interpolation — a head branch name,
# a title and a login are a fork's to write, and all three are data here:
#   PR_HEAD_REF   the head branch (task/NNNN-* names one task)
#   PR_TITLE      the title, whose every [TASK-NNNN] tag names another
#   PR_AUTHOR     the pull request author's login (forge-authenticated)
#   PR_DRAFT      true|false
#   PR_MERGED     true|false (closed only)
#   GH_REPO       owner/repo, for the survivor query
#   GH_TOKEN      lets `gh` ask the forge about surviving pull requests
#
# **The event reaches every task the pull request carries.** A branch
# name holds one id and a title holds as many as the work carries, so
# the carried set comes from ql_carried_of — the same helper the merge
# half and the mirror projection already ask, never a second parser
# beside them (technical/settings/titles.md#pr_title_style). A pull
# request carrying none by either route exits without writing.
#
# On close-without-merge, the forge is asked whether another open pull
# request still works the task: with a survivor, the newest one's author
# and draftness are re-recorded instead of landing the task — never a
# silent skip, or taken_by strands on the closed PR's author. The
# question is per task, because a survivor for one carried task says
# nothing about another. When the forge cannot answer, the task lands: a
# queue that briefly forgets a survivor heals at that survivor's next
# event, while a task stranded in-flight with no PR heals never.
#
# Exits 0 in every no-op case (nothing carried, no legal edge, merged
# close); 3 only for usage errors. Mutates the working tree; the caller
# commits, so one event's writes land as one commit.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

EVENT="${1:?usage: apply_pr_event.sh <event>}"

HERE="$(dirname "$0")"
FLIP="$HERE/flip_task_status.sh"
. "$HERE/queue_lib.sh"

# The carried set — validated as data by the helper, which keeps only
# digits from either source.
CARRIED=$(ql_carried_from_env)
if [ -z "$CARRIED" ]; then
  echo "head '${PR_HEAD_REF:-}' and title '${PR_TITLE:-}' carry no task — nothing to record"
  exit 0
fi

draftness() {   # $1: true|false -> draft|ready
  [ "$1" = "true" ] && printf 'draft' || printf 'ready'
}

# flip_one <task> <mode> [args...] — one task's write, and one task's
# answer never abandons the tasks after it. The flip already exits 0 for
# an id resolving to no file and for an event no edge applies to; a
# louder exit is still one task's, so it is reported and the loop goes on.
flip_one() {
  local task="$1" mode="$2"
  shift 2
  bash "$FLIP" "$mode" "$task" "$@" \
    || echo "flip ${mode} ${task} exited $? — the tasks after it still move" >&2
}

# flip_all <mode> [args...] — the same write, once per carried task.
flip_all() {
  local mode="$1" task
  shift
  for task in $CARRIED; do
    flip_one "$task" "$mode" "$@"
  done
}

case "$EVENT" in
  opened|reopened)
    flip_all take "${PR_AUTHOR:?}" "$(draftness "${PR_DRAFT:-true}")"
    ;;
  ready_for_review)
    flip_all review
    ;;
  converted_to_draft|changes_requested)
    flip_all rework
    ;;
  review_requested)
    # GitHub fires this on drafts too (CODEOWNERS auto-requests); a
    # draft's task is being worked, not reviewed.
    if [ "${PR_DRAFT:-true}" = "true" ]; then
      echo "review requested on a draft — not an in-review signal"
      exit 0
    fi
    flip_all review
    ;;
  closed)
    if [ "${PR_MERGED:-false}" = "true" ]; then
      echo "closed by merging — the merge recording owns this move"
      exit 0
    fi
    for TASK in $CARRIED; do
      # A surviving open PR on the same task supersedes the landing. The
      # match is by number, zero-padding stripped — every id reader in
      # this machine normalizes, and a survivor spelling `task/019-` must
      # not be invisible to a close on `task/0019-`.
      num=$(printf '%s' "$TASK" | sed 's/^task-0*//')
      survivor=""
      if [ -n "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
        survivor=$(gh pr list --repo "${GH_REPO:?}" --state open \
          --json number,headRefName,author,isDraft \
          --jq "[.[] | select(.headRefName | test(\"^task/0*${num}-\"))] | sort_by(.number) | last | if . == null then \"\" else \"\(.author.login) \(.isDraft)\" end" \
          2>/dev/null || printf '')
      fi
      if [ -n "$survivor" ]; then
        s_login=${survivor%% *}
        s_draft=${survivor##* }
        echo "a surviving pull request still works ${TASK} — recording it instead"
        flip_one "$TASK" take "$s_login" "$(draftness "$s_draft")"
      else
        flip_one "$TASK" land
      fi
    done
    ;;
  *)
    echo "usage: apply_pr_event.sh <opened|reopened|ready_for_review|converted_to_draft|review_requested|changes_requested|closed>" >&2
    exit 3
    ;;
esac

exit 0
