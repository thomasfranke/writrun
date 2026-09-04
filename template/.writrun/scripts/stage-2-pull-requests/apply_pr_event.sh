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
#   PR_NUMBER     this pull request's own number, so the survivor query
#                 can drop its own row from a listing that lags
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
# to choose — but the amount is not, and no ceiling is imposed here.
# Recorded as report-0028 rather than capped on a number picked in
# passing.
#
# On close-without-merge, the forge is asked whether another open pull
# request still works the task — by every route the reader counts: each
# open pull request's head branch and leading title tags pass through
# ql_carried_of, the same helper that derived this event's own carried
# set, so the question reaches exactly as far as the reader does. With a
# survivor, the newest one's author and draftness are re-recorded
# instead of landing the task — never a silent skip, or taken_by strands
# on the closed PR's author. The question is per task, because a
# survivor for one carried task says nothing about another; the closing
# pull request's own row answers for none of them, wherever the
# listing's lag still shows it — the event in hand is better evidence
# than the cache. When the forge cannot answer, the task lands: a queue
# that briefly forgets a survivor heals at that survivor's next event,
# while a task stranded in-flight with no PR heals never.
#
# Exits 0 in every no-op case (nothing carried, no legal edge, merged
# close); 1 when a carried task's write failed, after the rest have been
# attempted; 3 only for usage errors. Mutates the working tree; the
# caller commits, so one event's writes land as one commit — and a
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
    #
    # `@tsv`, because the title is a field now: it has spaces in it and
    # may carry a newline, and a space-joined row would hand title text
    # to whichever field reads next. @tsv escapes both, so one pull
    # request is one line and a tab is the only separator.
    OPEN_PRS=""
    if [ -n "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
      OPEN_PRS=$(gh pr list --repo "${GH_REPO:?}" --state open --limit 200 \
        --json number,headRefName,author,isDraft,title \
        --jq '.[] | [.number, .headRefName, .author.login, .isDraft, .title] | @tsv' \
        2>/dev/null || printf '')
    fi
    # **The survivor index, built once.** One line per open pull request
    # — number, login, draftness, and the carried set ql_carried_of
    # answers for its head branch and title — computed before the loop
    # over carried tasks, so a close carrying six tags still costs the
    # helper one pass. Two kinds of row never reach the helper. The
    # closing pull request's own, dropped by number: the event in hand
    # proves it closed, wherever the listing's lag still shows it, and a
    # closed pull request must answer for nothing. And any row that
    # cannot carry a task — a head branch not under task/ and a title not
    # opening with `[` — dropped by one cheap test first, because the
    # helper forks subshells and a 200-row listing would otherwise buy
    # several hundred forks for rows that answer nothing.
    TAB=$(printf '\t')
    INDEX=""
    while IFS="$TAB" read -r o_num o_head o_login o_draft o_title; do
      [ -n "$o_num" ] || continue
      [ "$o_num" = "${PR_NUMBER:-}" ] && continue
      case "$o_head" in
        task/*) ;;
        *) case "$o_title" in '['*) ;; *) continue ;; esac ;;
      esac
      o_carried=$(ql_carried_of "$o_head" "$o_title")
      [ -n "$o_carried" ] || continue
      INDEX="${INDEX}${o_num}${TAB}${o_login}${TAB}${o_draft}${TAB}${o_carried}
"
    done <<EOT
$OPEN_PRS
EOT
    for TASK in $CARRIED; do
      # A surviving open PR on the same task supersedes the landing. The
      # match is membership in the row's carried set — field-wise, never
      # a substring of the line, so a login or a number that spells a
      # task id stays a login or a number. Both sides arrive normalized
      # through ql_task_num, which is why nothing is stripped here. The
      # newest wins, so the highest number is kept rather than the last
      # line read.
      survivor=$(printf '%s\n' "$INDEX" | awk -F'\t' -v t="$TASK" '
        {
          n = split($4, c, " ")
          for (i = 1; i <= n; i++)
            if (c[i] == t) {
              if ($1 + 0 > best) { best = $1 + 0; out = $2 " " $3 }
              break
            }
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
