#!/usr/bin/env bash
# check_state.sh — verifies the task/spec lifecycle transitions a diff makes.
#
# Usage:
#   check_state.sh [<diff-range>]      # default: main...HEAD
#
# Four rules, all derivable from the range alone:
#
#   A. A change may not move a spec draft -> approved. That transition is a
#      human gate (docs/product/pipeline/gates.md); a pull request
#      approving its own spec is the exact thing the gate exists to stop.
#   B. A spec may not reach `implemented` from `draft`. Work is authorized
#      by approval, so an implemented spec was approved at some point first.
#   C. A task may not reach `completed` while any spec in its spec_ref is
#      not `implemented`.
#   D. A spec may not enter the tree already `implemented`. No legitimate
#      path produces a spec born past both gates.
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

      # C — a completed task has no unimplemented spec left behind. The
      # trigger is the task *reaching* completed in this range; one that
      # was already completed at the base is history, not a transition.
      new=$(fm_now "$f" status)
      old=$(fm_base "$f" status)
      if [ "$new" = "completed" ] && [ "$old" != "completed" ]; then
        refs=$(fm_now "$f" spec_ref | tr -d '[]' | tr ',' ' ')
        for ref in $refs; do
          [ -n "$ref" ] || continue
          # <id>.md or <id>-<subject>.md — the subject slug is not identity.
          spec=$(find work/specs \
            \( -iname "${ref}.md" -o -iname "${ref}-*.md" \) 2>/dev/null | head -n1)
          if [ -z "$spec" ]; then
            echo "BROKEN: ${f} lists ${ref} in spec_ref, which resolves to no file." >&2
            status=1
            continue
          fi
          spec_status=$(fm_now "$spec" status)
          if [ "$spec_status" != "implemented" ]; then
            echo "INCONSISTENT: ${f} is completed but ${ref} is '${spec_status}'." >&2
            echo "  Fill the spec's Outcome and set it to implemented in this change." >&2
            status=1
          fi
        done
      fi
      ;;
  esac
done

if [ "$status" -eq 0 ]; then
  echo "OK — no forbidden lifecycle transition in ${DIFF_RANGE}"
fi

exit "$status"
