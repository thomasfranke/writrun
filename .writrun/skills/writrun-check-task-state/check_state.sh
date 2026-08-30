#!/usr/bin/env bash
# check_state.sh — verifies the task/spec lifecycle transitions a diff makes.
#
# Usage:
#   check_state.sh [<diff-range>]      # default: main...HEAD
#
# The rules, all derivable from the range alone:
#
#   A. A change may not move a spec draft -> approved. That transition is a
#      human gate (docs/product/stage-1-tasks-and-specs/gates.md); a pull request
#      approving its own spec is the exact thing the gate exists to stop.
#   B. A spec may not reach `implemented` from `draft`. Work is authorized
#      by approval, so an implemented spec was approved at some point first.
#   C. A task's `completed` date may not be written while any spec in its
#      spec_ref is not `implemented` — and the diff that implements a
#      task's last spec writes the date, or the task can never reach done.
#   D. A spec may not enter the tree already `implemented`. No legitimate
#      path produces a spec born past both gates.
#   E. (Stage 2+) A branch may not move a task between the machinery's
#      five working states — backlog, ready, in-progress, in-review,
#      done. That line has one writer, and it is not a branch
#      (docs/product/stage-1-tasks-and-specs/statuses.md).
#   F. (Stage 2+) A branch may not edit `taken_by` — same single writer.
#   G. A hand move touching `blocked` is legal only between `blocked`
#      and `backlog` or `ready`; an in-flight task cannot be blocked.
#   H. `dropped` is terminal: reachable by hand from any non-terminal
#      state, left by nothing.
#
# A transition is read from the front matter at the two ends of the range
# — the file as the base knew it against the file as it is now — never
# grepped out of the diff text. A spec in this methodology's own
# repository legitimately quotes `status: draft` at column 0 in its body
# (the docs' own examples do), and a quoted line must never read as a
# transition.
#
# Rules B, C and D are what stop a contributor from routing around rule A
# by skipping intermediate states entirely. One case is deliberately not
# judged here: a spec added as `approved`. Locally, the legitimate flip
# (recorded after a maintainer approved the PR) and self-approval look
# identical — only the forge knows whether the review exists, so CI's
# `writrun check` settles that one against the PR's actual reviews, and
# locally it passes.
#
# Exit codes: 0 clean; 1 a rule was violated; 3 usage error or git failed.
#
# Portable awk/sed only — no gawk extensions. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

DIFF_RANGE="${1:-main...HEAD}"

err_tmp=$(mktemp "${TMPDIR:-/tmp}/check_state.XXXXXX")
if ! CHANGED=$(git diff --name-only "$DIFF_RANGE" 2>"$err_tmp"); then
  echo "git diff --name-only ${DIFF_RANGE} failed:" >&2
  head -n 2 "$err_tmp" >&2
  rm -f "$err_tmp"
  exit 3
fi
rm -f "$err_tmp"

# **A range that selects no commits is not a change that moved nothing.**
# Without branches — which is every project at level `tasks-and-specs` —
# `main...HEAD` is empty by construction, so this check would print OK
# having read nothing and vouched for it. Only the range forms are
# tested: a bare ref means "against the working tree", where "no commits
# selected" says nothing (spec-0013).
RANGE_COMMITS=""
case "$DIFF_RANGE" in
  *..*) RANGE_COMMITS=$(git rev-list --count "$DIFF_RANGE" 2>/dev/null || true) ;;
esac

# The base side of the range — what `git diff` itself compares against:
# the merge base for the three-dot form, the left rev for two-dot, the
# rev itself when the diff is against the working tree.
case "$DIFF_RANGE" in
  *...*)
    left="${DIFF_RANGE%%...*}"
    right="${DIFF_RANGE##*...}"
    BASE=$(git merge-base "${left:-HEAD}" "${right:-HEAD}")
    ;;
  *..*) BASE="${DIFF_RANGE%%..*}" ;;
  *)    BASE="$DIFF_RANGE" ;;
esac

status=0

# The stage gates rules E and F: below Stage 2 no machinery exists to own
# the status line, so hand moves are the contract, not a violation. The
# reader resolves next to this script (the settings file it reads is the
# working directory's); absent either, the documented default applies.
READ_SETTING="$(cd "$(dirname "$0")" && pwd)/../../scripts/stage-2-pull-requests/read_setting.sh"
STAGE=$(bash "$READ_SETTING" stage 2>/dev/null || printf '3')
case "$STAGE" in 1|2|3) ;; *) STAGE=3 ;; esac

ADDED=$(git diff --name-only --diff-filter=A "$DIFF_RANGE" 2>/dev/null || true)

# is_added <file> — was the file created by this diff?
is_added() { printf '%s\n' "$ADDED" | grep -qxF "$1"; }

# fm_field <field> — reads a file on stdin, returns the field from the
# front-matter block only: a quoted `status:` line in a body never counts.
fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  '
}

# fm_now / fm_base — the field in the working tree, and at the base end
# of the range (empty when the file did not exist there — a failing
# `git show` is that case, not an error).
fm_now()  { fm_field "$2" < "$1"; }
fm_base() { git show "${BASE}:$1" 2>/dev/null | fm_field "$2" || true; }

for f in $CHANGED; do
  case "$f" in
    work/specs/*.md)
      [ -f "$f" ] || continue
      new=$(fm_now "$f" status)
      old=$(fm_base "$f" status)

      # D — a spec never enters the tree already implemented. Born
      # `approved` is deliberately not judged here: only the forge can
      # tell the recorded flip from self-approval, and CI does.
      if is_added "$f" && [ "$new" = "implemented" ]; then
        echo "FORBIDDEN: ${f} enters the tree already 'implemented'." >&2
        echo "  Work is authorized by approval and recorded after it; a spec" >&2
        echo "  born implemented skipped both gates. Add it as draft." >&2
        status=1
      fi

      # A — draft -> approved is never a contributor's to make.
      if [ "$old" = "draft" ] && [ "$new" = "approved" ]; then
        echo "FORBIDDEN: ${f} moves draft -> approved." >&2
        echo "  That transition is a human gate. Leave the spec in draft;" >&2
        echo "  approval is recorded when the change is approved." >&2
        status=1
      fi

      # B — implemented is only reachable from approved.
      if [ "$old" = "draft" ] && [ "$new" = "implemented" ]; then
        echo "FORBIDDEN: ${f} moves draft -> implemented, skipping approval." >&2
        echo "  A spec is authorized to be implemented only once approved." >&2
        status=1
      fi
      ;;

    work/tasks/*.md)
      [ -f "$f" ] || continue

      new=$(fm_now "$f" status)
      old=$(fm_base "$f" status)

      # A task the diff creates is not exempt from the single writer:
      # born in flight, born done, or born with a holder would be a
      # branch writing the machinery's line by arriving instead of by
      # editing. It enters as backlog (or blocked, with its reason);
      # the recording moves it from there.
      if [ "$STAGE" -ge 2 ] && is_added "$f"; then
        case "$new" in
          backlog|blocked) ;;
          *)
            echo "FORBIDDEN: ${f} enters the tree already '${new}'." >&2
            echo "  A task is born backlog (or blocked, with its reason); every" >&2
            echo "  other state is the machinery's to write after the merge." >&2
            status=1
            ;;
        esac
        tb_new=$(fm_now "$f" taken_by)
        if [ -n "$tb_new" ] && [ "$tb_new" != "null" ]; then
          echo "FORBIDDEN: ${f} enters the tree with taken_by '${tb_new}'." >&2
          echo "  Who has a task is the forge's record, machinery-written." >&2
          status=1
        fi
      fi

      # E — the five working states have one writer, and it is the
      # machinery on the authority branch, never a branch. Only from
      # Stage 2 up: with no forge there is no machinery, and statuses
      # stay hand-moved.
      if [ "$STAGE" -ge 2 ] && [ -n "$old" ] && [ "$new" != "$old" ]; then
        case "$old" in backlog|ready|in-progress|in-review|done)
          case "$new" in backlog|ready|in-progress|in-review|done)
            echo "FORBIDDEN: ${f} moves ${old} -> ${new} on a branch." >&2
            echo "  The working states are the machinery's, written on the" >&2
            echo "  authority branch from forge events — a branch never edits" >&2
            echo "  the status line (statuses.md). Leave it; the forge writes it." >&2
            status=1
            ;;
          esac ;;
        esac
      fi

      # F — taken_by is the same single writer's.
      if [ "$STAGE" -ge 2 ] && ! is_added "$f"; then
        tb_new=$(fm_now "$f" taken_by)
        tb_old=$(fm_base "$f" taken_by)
        if [ -n "$tb_old" ] && [ "$tb_new" != "$tb_old" ]; then
          echo "FORBIDDEN: ${f} edits taken_by ('${tb_old}' -> '${tb_new}') on a branch." >&2
          echo "  Who has a task is the forge's record, machinery-written." >&2
          status=1
        fi
      fi

      # G — blocked pairs with backlog/ready only. An in-flight task has
      # an open pull request; what stalls it is visible there, and the
      # status table draws no such edge.
      if [ "$new" = "blocked" ] && [ -n "$old" ] && [ "$old" != "blocked" ]; then
        case "$old" in
          backlog|ready) ;;
          *)
            echo "FORBIDDEN: ${f} moves ${old} -> blocked." >&2
            echo "  blocked is reachable from backlog or ready only (statuses.md)." >&2
            status=1
            ;;
        esac
      fi
      if [ "$old" = "blocked" ] && [ "$new" != "blocked" ] && [ -n "$new" ]; then
        case "$new" in
          backlog|ready) ;;
          *)
            echo "FORBIDDEN: ${f} moves blocked -> ${new}." >&2
            echo "  A released task returns to backlog or ready (statuses.md)." >&2
            status=1
            ;;
        esac
      fi

      # H — dropped is terminal.
      if [ "$old" = "dropped" ] && [ "$new" != "dropped" ] && [ -n "$new" ]; then
        echo "FORBIDDEN: ${f} moves dropped -> ${new} — dropped is terminal." >&2
        echo "  A dropped task stays dropped; new work is a new task." >&2
        status=1
      fi

      # C — the completed date is the worker's declaration of finishing,
      # and it may only be written once every referenced spec is
      # implemented. The reverse binds too: the diff that implements a
      # task's last spec writes the date, or no merge can ever move the
      # task to done.
      cd_new=$(fm_now "$f" completed)
      cd_old=$(fm_base "$f" completed)
      refs=$(fm_now "$f" spec_ref | tr -d '[]' | tr ',' ' ')
      all_implemented=true
      for ref in $refs; do
        [ -n "$ref" ] || continue
        # <id>.md or <id>-<subject>.md — the subject slug is not identity.
        spec=$(find work/specs \
          \( -iname "${ref}.md" -o -iname "${ref}-*.md" \) 2>/dev/null | head -n1)
        if [ -z "$spec" ]; then
          echo "BROKEN: ${f} lists ${ref} in spec_ref, which resolves to no file." >&2
          status=1
          all_implemented=false
          continue
        fi
        spec_status=$(fm_now "$spec" status)
        if [ "$spec_status" != "implemented" ]; then
          all_implemented=false
          # An added file's base read is empty — the same "no date yet"
          # as null, or a task born with its date would bypass this.
          if [ "$cd_new" != "null" ] && [ -n "$cd_new" ] \
            && { [ "$cd_old" = "null" ] || [ -z "$cd_old" ]; }; then
            echo "INCONSISTENT: ${f} writes its completed date but ${ref} is '${spec_status}'." >&2
            echo "  Fill the spec's Outcome and set it to implemented in this change." >&2
            status=1
          fi
        fi
      done
      ;;
  esac
done

# The other half of rule C, keyed on the specs rather than the task: the
# diff that implements a task's *last* unimplemented spec writes the
# task's completed date, or no merge can ever move the task to done. The
# task file itself may be untouched by the diff, so this pass starts
# from the changed specs.
checked_tasks=""
for f in $CHANGED; do
  case "$f" in work/specs/*.md) ;; *) continue ;; esac
  [ -f "$f" ] || continue
  [ "$(fm_now "$f" status)" = "implemented" ] || continue
  [ "$(fm_base "$f" status)" != "implemented" ] || continue
  tref=$(fm_now "$f" task_ref)
  [ -n "$tref" ] || continue
  case " $checked_tasks " in *" $tref "*) continue ;; esac
  checked_tasks="$checked_tasks $tref"
  tf=$(find work/tasks \
    \( -iname "${tref}.md" -o -iname "${tref}-*.md" \) 2>/dev/null | head -n1)
  [ -n "$tf" ] || continue
  cd_now=$(fm_now "$tf" completed)
  [ "$cd_now" = "null" ] || [ -z "$cd_now" ] || continue
  all_done=true
  for ref in $(fm_now "$tf" spec_ref | tr -d '[]' | tr ',' ' '); do
    [ -n "$ref" ] || continue
    sp=$(find work/specs \
      \( -iname "${ref}.md" -o -iname "${ref}-*.md" \) 2>/dev/null | head -n1)
    [ -n "$sp" ] || { all_done=false; break; }
    [ "$(fm_now "$sp" status)" = "implemented" ] || { all_done=false; break; }
  done
  if [ "$all_done" = "true" ]; then
    echo "INCONSISTENT: this diff implements ${tf}'s last spec but leaves its completed date null." >&2
    echo "  The date is the declaration the merge turns into done — write it." >&2
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  if [ "$RANGE_COMMITS" = "0" ]; then
    echo "The range ${DIFF_RANGE} selects no commits — nothing was checked." >&2
    echo "That is not a pass. A check that read nothing has vouched for" >&2
    echo "nothing, and reporting it as clean is the failure this refusal" >&2
    echo "exists to prevent. Name the range the change actually spans." >&2
    exit 3
  fi
  echo "OK — no forbidden lifecycle transition in ${DIFF_RANGE}"
fi

exit "$status"
