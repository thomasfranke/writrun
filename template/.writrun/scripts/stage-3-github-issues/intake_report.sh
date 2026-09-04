#!/usr/bin/env bash
# intake_report.sh — a maintainer's label turns an issue into a report.
#
# Usage: intake_report.sh <owner/repo> <issue-number>
#   Run from the repository root, on a checkout of the authority branch
#   with full history. The issue's fields travel through env, never as
#   arguments and never interpolated into anything that executes:
#
#     ISSUE_TITLE       the issue's title, the report's title-to-be
#     ISSUE_BODY        the issue's text — a stranger's, and pure data
#     ISSUE_AUTHOR      the login that opened the issue
#     ISSUE_CREATED_AT  when it was opened (RFC 3339 UTC)
#     LABEL_NAME        the label this event applied
#     BASE_REF          the authority branch (default: main)
#
# Anyone can open an issue, so an issue's arrival writes nothing — an
# intake that minted files on arrival would hand the queue's front door
# to whoever finds the repository. The gate is the label: someone with
# triage rights applying `writrun:report` is the judgement that the
# observation deserves a file, and nothing more — the route stays
# triage's, made after the file exists
# (docs/product/stage-3-github-issues/intake.md).
#
# On that label this script mints the next report id — over the same
# three views the generator reads: the directory, the git history, and
# every open pull request — writes `work/reports/report-NNNN-<slug>.md`
# with `status: open`, the issue's title as its title and its text as
# its body, commits it to the authority branch with the same
# rebase-not-force pattern every queue recording uses, then retitles the
# issue `[REPORT-NNNN] <title>`, labels it `status:open`, and comments
# the file's path. From that moment the issue is the report's mirror,
# exactly as if the file had come first.
#
# Two arrivals it declines by design: a label that is not
# `writrun:report` (this event is not the gate), and a title already
# carrying a `[REPORT-` or `[TASK-` tag — an existing mirror is another
# workflow's, and the tag the first run wrote is what makes a re-applied
# label a no-op.
#
# **The body is data.** It reaches the report through `printf '%s'` of
# an environment variable — no eval, no interpolation into shell or
# YAML — so `$(...)`, backticks and a front-matter block of its own all
# arrive verbatim, as evidence claimed by the reporter and nothing else.
#
# Exit codes: 0 recorded, or nothing to do and it says why; 1 the forge
# refused a write after the file landed; 3 usage error or git failed.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions. See the
# standing rule in docs/technical/decisions/.

set -euo pipefail

REPO="${1:?usage: intake_report.sh <owner/repo> <issue-number>}"
ISSUE="${2:?usage: intake_report.sh <owner/repo> <issue-number>}"
BASE_REF="${BASE_REF:-main}"

TITLE="${ISSUE_TITLE:-}"
BODY="${ISSUE_BODY:-}"
AUTHOR="${ISSUE_AUTHOR:-}"
CREATED="${ISSUE_CREATED_AT:-}"
LABEL="${LABEL_NAME:-}"

if [ "$LABEL" != "writrun:report" ]; then
  echo "label '${LABEL}' is not the gate — only writrun:report mints a report."
  exit 0
fi

if [ -z "$TITLE" ]; then
  echo "the issue carries no title, and a report is named by one — nothing recorded." >&2
  exit 3
fi

case "$TITLE" in
  "[REPORT-"*|"[TASK-"*)
    echo "the title already carries a mirror tag — that issue is some file's"
    echo "mirror, and its writer is another workflow. Nothing to do."
    exit 0 ;;
esac

# --- the id, minted over the same three views the generator reads -------
#
# The forge view is all or nothing, like the generator's: a scan that
# under-reports without saying so is exactly the failure the uniqueness
# rule exists to prevent, so a failed call leaves the view local and the
# output says which view answered.
FORGE_VIEW=local
FORGE_PATHS=""
forge_scan() {
  command -v gh >/dev/null 2>&1 || return 0
  local numbers files paths n
  numbers=$(gh pr list --state open --limit 200 --json number \
    --jq '.[].number' 2>/dev/null) || return 0
  paths=""
  for n in $numbers; do
    files=$(gh api "repos/${REPO}/pulls/${n}/files" --paginate \
      --jq '.[].filename' 2>/dev/null) || return 0
    paths="${paths}${files}
"
  done
  FORGE_VIEW=forge
  FORGE_PATHS="$paths"
  return 0
}
forge_scan

next_report_id() {
  local max=0 f n
  bump() {
    n=$(basename "$1" .md | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/^report-0*([0-9]+).*/\1/')
    [[ "$n" =~ ^[0-9]+$ ]] || return 0
    (( n > max )) && max=$n
    return 0
  }
  while IFS= read -r f; do bump "$f"; done \
    < <(find work/reports -maxdepth 1 -type f -iname 'report-*.md' -print 2>/dev/null)
  # An id is never reused, including after its file was deleted — the
  # history is the second view.
  while IFS= read -r f; do
    case "$f" in work/reports/*) bump "$f" ;; esac
  done < <(git log --diff-filter=A --name-only --pretty=format: -- work/reports 2>/dev/null)
  if [ -n "$FORGE_PATHS" ]; then
    while IFS= read -r f; do
      case "$f" in work/reports/*) bump "$f" ;; esac
    done <<EOF
$FORGE_PATHS
EOF
  fi
  printf 'report-%04d' $((max + 1))
}
RID=$(next_report_id)

# The filename's subject: a short kebab echo of the title, at most three
# words — readability, never identity, exactly as the generator derives
# it when nobody chose one.
SLUG=$(printf '%s' "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-*//; s/-*$//' \
  | awk -F- '{
      n = 0
      for (i = 1; i <= NF && n < 3; i++) {
        if ($i == "") continue
        s = (n == 0 ? $i : s "-" $i)
        n++
      }
      print s
    }')
FILE="work/reports/${RID}${SLUG:+-$SLUG}.md"

# The issue's own timestamp when it is canonical; the moment of minting
# when it is not — the front-matter check accepts exactly one spelling,
# and a report refused at the door records nothing.
if ! printf '%s' "$CREATED" \
  | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'; then
  CREATED=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
fi

mkdir -p work/reports
{
  printf -- '---\n'
  printf 'id: %s\n' "$RID"
  printf 'status: open\n'
  printf 'task_ref: []\n'
  printf 'doc_ref: null\n'
  printf 'created: %s\n' "$CREATED"
  printf 'triaged: null\n'
  printf -- '---\n'
  printf '\n'
  printf '# %s\n' "$TITLE"
  printf '\n'
  printf 'Issue #%s%s.\n' "$ISSUE" "${AUTHOR:+, opened by @$AUTHOR}"
  if [ -n "$BODY" ]; then
    printf '\n'
    printf '%s\n' "$BODY"
  fi
} > "$FILE"
echo "recorded ${FILE} from issue #${ISSUE}"
if [ "$FORGE_VIEW" = forge ]; then
  echo "Minted above the queue, its history, and every open pull request."
else
  echo "Minted from this checkout and its history only — no forge answered," >&2
  echo "so an id an open pull request already claims would not have been seen." >&2
fi

# The recording, with the same identity and the same rebase-not-force
# pattern as every other commit the machinery makes: an addition to the
# branch's history, never a replacement of it.
git config user.name  "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add work/reports
git commit \
  -m "$(bash "$(dirname "$0")/../stage-2-pull-requests/commit_subject.sh" intake)" \
  -m "Issue #${ISSUE}, labelled writrun:report."
git pull --rebase origin "$BASE_REF"
git push origin "HEAD:${BASE_REF}"

# The issue becomes the mirror: the tag in the title is its identity —
# and the guard that makes a second delivery of this event a no-op —
# the label is the live state, and the comment names the file that is
# the authority from here. Values reach the forge as data through -f.
NUM=$(printf '%s' "$RID" | sed -E 's/^report-0*//')
TAG=$(printf '[REPORT-%04d]' "$NUM")
gh api -X PATCH "repos/${REPO}/issues/${ISSUE}" \
  -f "title=${TAG} ${TITLE}" >/dev/null
gh api -X POST "repos/${REPO}/labels" \
  -f name="status:open" -f color="0e8a16" \
  -f description="Recorded and awaiting triage" >/dev/null 2>&1 || true
gh api -X POST "repos/${REPO}/issues/${ISSUE}/labels" \
  -f "labels[]=status:open" >/dev/null
gh api -X POST "repos/${REPO}/issues/${ISSUE}/comments" \
  -f "body=Recorded as \`${FILE}\` — the file is the authority from here; triage closes this issue." >/dev/null
echo "issue #${ISSUE} is now ${RID}'s mirror (${TAG}, status:open)"
