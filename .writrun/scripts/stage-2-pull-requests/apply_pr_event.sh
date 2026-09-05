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
# **What that widens, said plainly.** This runs on pull_request_target,
# so a fork's pull request reaches it, and the title is the fork's to
# write. Before the carried set, such a pull request could claim the one
# task its head branch spelled; it can now claim every task its title
# lists, and each claim is a status write pushed to the default branch.
# The kind of exposure is unchanged — both routes were always the fork's
# to choose — and the amount is bounded: above QL_CARRIED_MAX distinct
# tasks the helper answers with its over-ceiling sentinel, and this
# script writes nothing and exits non-zero, naming the count, the
# ceiling, and the heal — closing and reopening the pull request
# re-fires the event once the title claims what the work carries
# (report-0028; spec-0069).
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
# close); 1 when a carried task's write failed, after the rest have been
# attempted, and when the claim is over the ceiling — refused whole,
# nothing written; 3 only for usage errors. Mutates the working tree;
# the caller commits, so one event's writes land as one commit — and a
# non-zero exit is what stops a half-applied one from being pushed under
# a green run.
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
case "$CARRIED" in
  over-ceiling:*)
    # The whole set is refused, never the first eight of it: a partial
    # write riding a green run is the failure this script's own exit
    # contract exists to prevent. The run goes red on the author's own
    # pull request, and the heal is theirs.
    echo "the head branch and title claim ${CARRIED#over-ceiling:} distinct tasks — the ceiling is ${QL_CARRIED_MAX}." >&2
    echo "Nothing was recorded. Retitle the pull request to what the work carries," >&2
    echo "then close and reopen it: the reopened event re-fires the recording." >&2
    exit 1
    ;;
esac

draftness() {   # $1: true|false -> draft|ready
  [ "$1" = "true" ] && printf 'draft' || printf 'ready'
}

# flip_one <task> <mode> [args...] — one task's write, and one task's
# answer never abandons the tasks after it. The flip already exits 0 for
# an id resolving to no file and for an event no edge applies to; a
# louder exit is still one task's, so it is reported and the loop goes on.
#
# **Going on is not the same as passing.** The exit is remembered and
# this script ends on it: the caller commits whatever the tree holds, so
# a swallowed failure would push a half-applied event under a green run,
# and the task that did not move stays `ready` with its work in flight —
# a state no later event of this pull request heals, because `ready` has
# no edge to `in-review`. Loud, then, exactly as the run that cannot push
# is loud rather than shrugged at.
FAILED=0
flip_one() {
  local task="$1" mode="$2" code=0
  shift 2
  bash "$FLIP" "$mode" "$task" "$@" || code=$?
  if [ "$code" -ne 0 ]; then
    echo "flip ${mode} ${task} exited ${code} — the tasks after it still move" >&2
    FAILED=1
  fi
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
    # **One listing answers every carried task.** Asking the question per
    # task must not make the call per task: a pull request carrying six
    # tags would fetch the same list six times, and no two of those
    # answers could differ. The filter moves to the reader instead.
    #
    # `--limit` is given because `gh`'s default is 30 and the filter is
    # client-side: a survivor sitting below that line comes back invisible,
    # and an invisible survivor lands a task whose work is still open —
    # the exact failure this query exists to prevent, produced by the
    # query itself.
    OPEN_PRS=""
    if [ -n "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
      OPEN_PRS=$(gh pr list --repo "${GH_REPO:?}" --state open --limit 200 \
        --json number,headRefName,author,isDraft \
        --jq '.[] | "\(.number) \(.headRefName) \(.author.login) \(.isDraft)"' \
        2>/dev/null || printf '')
    fi
    for TASK in $CARRIED; do
      # A surviving open PR on the same task supersedes the landing. The
      # match is by number, zero-padding stripped — every id reader in
      # this machine normalizes, and a survivor spelling `task/019-` must
      # not be invisible to a close on `task/0019-`. The newest wins, so
      # the highest number is kept rather than the last line read.
      num=$(printf '%s' "$TASK" | sed 's/^task-0*//')
      survivor=$(printf '%s\n' "$OPEN_PRS" | awk -v n="$num" '
        $2 ~ ("^task/0*" n "-") {
          if ($1 + 0 > best) { best = $1 + 0; out = $3 " " $4 }
        }
        END { if (out != "") print out }')
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

exit "$FAILED"
