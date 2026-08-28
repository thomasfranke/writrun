#!/usr/bin/env bash
# mirror_issues.sh — reconciles the GitHub Issues mirror with a pull
# request's task files.
#
# Usage: mirror_issues.sh <owner/repo> <pr-number>
#   The pull request's fields arrive via the environment — never inline
#   interpolation, the same rule check_derived_work.sh follows for the PR
#   body, since a fork controls some of them:
#     PR_STATE               open | closed
#     PR_DRAFT               true | false
#     PR_MERGED              true | false
#     PR_AUTHOR_ASSOCIATION  OWNER | MEMBER | COLLABORATOR | ...
#     PR_HTML_URL            the PR's URL, linked from every mirror body
#
# The file under work/tasks/ is the authority; the Issue is a projection
# of it, one direction only. This is a reconciliation, not a handler per
# event type: the desired mirror set is a function of the PR's state and
# the task files its diff adds, and every trigger re-syncs to it. That is
# what keeps the late cases honest — a task added in a later push gains
# its mirror on that push, a task a rederivation dropped loses its
# mirror, a reopened PR gets its mirrors back, and a merge creates any
# mirror still missing rather than assuming the open event already did.
#
# The PR's files are read out of the API's own patch text and parsed as
# data — the PR's code is never checked out and never executed. `gh` must
# be on PATH and authenticated (GH_TOKEN in CI; a stub in the test suite).
#
# Exit codes: 0 reconciled (including nothing to do); 3 usage error. An
# unexpected forge failure aborts non-zero via set -e.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions, no associative
# arrays. See the standing rule in docs/technical/decisions/.

set -euo pipefail

REPO="${1:?usage: mirror_issues.sh <owner/repo> <pr-number>}"
PR="${2:?usage: mirror_issues.sh <owner/repo> <pr-number>}"
: "${PR_STATE:?PR_STATE (open|closed) must arrive via the environment}"
: "${PR_DRAFT:?PR_DRAFT (true|false) must arrive via the environment}"
: "${PR_MERGED:?PR_MERGED (true|false) must arrive via the environment}"
: "${PR_AUTHOR_ASSOCIATION:?PR_AUTHOR_ASSOCIATION must arrive via the environment}"
: "${PR_HTML_URL:?PR_HTML_URL must arrive via the environment}"

TAB=$(printf '\t')

# macOS's stock base64 spells decode -D on older releases; feature-detect
# once rather than assume either spelling.
if printf '' | base64 -d >/dev/null 2>&1; then B64_FLAG="-d"; else B64_FLAG="-D"; fi
b64_decode() { base64 "$B64_FLAG"; }

# A draft is not in the queue yet. Only while open, though — a PR that had
# real mirrors and was later drafted-then-closed still needs its cleanup
# pass below.
if [ "$PR_STATE" = "open" ] && [ "$PR_DRAFT" = "true" ]; then
  echo "Draft PR — the mirror waits for ready_for_review."
  exit 0
fi

# The diff, as the API tells it: one row per file — status, path, patch.
# The jq only reshapes; every filter lives below, where the tests run.
# The patch travels base64-encoded so an attacker-controlled patch line
# can never masquerade as a row of this stream.
FILES=$(gh api "repos/${REPO}/pulls/${PR}/files" --paginate \
  --jq '.[] | [.status, .filename, ((.patch // "") | @base64)] | @tsv')

# Front-matter and title, read out of the patch. Every line of an added
# file's patch is a '+' line, so stripping that column reconstructs the
# file without fetching across repositories — which a fork PR would
# otherwise require.
fm_field() {   # fm_field <body> <name>
  printf '%s\n' "$1" | sed -n "s/^$2: *//p" | head -n1 | sed 's/[[:space:]]*$//'
}
first_heading() {
  printf '%s\n' "$1" | sed -n 's/^# //p' | head -n1 | sed 's/[[:space:]]*$//'
}

# A mirror's title names its task, and that is how a mirror is found —
# there is no stored number anywhere. The rule now spells the name as the
# tag a pull request title carries, `[TASK-NNNN] <task title>`
# (docs/product/pipeline.md#flows-and-statuses), so one search for the tag
# finds the task in the queue, in the PR, and in the mirror at once.
#
# Every lookup below still reads the `task-NNNN — ` prefix that predates
# the rule. A mirror minted before it must be *found*, because a lookup
# that only knows the new shape does not report a miss — it mints a
# second mirror for a task that already has one.

# id_of_title <title> — the task id a mirror's title names, lowercased and
# at whatever width the title spells it; nothing for a title that names no
# task, which is every foreign Issue the `writrun:task` filter let through.
id_of_title() {
  printf '%s' "$1" | sed -n \
    -e 's/^\[\([Tt][Aa][Ss][Kk]-[0-9][0-9]*\)\].*/\1/p' \
    -e 's/^\([Tt][Aa][Ss][Kk]-[0-9][0-9]*\)[[:space:]].*/\1/p' \
    | head -n1 | tr '[:upper:]' '[:lower:]'
}

# num_of_id <task-id> — the number in `task-0006`, leading zeros dropped.
# Comparisons are on the number, never the text: the id is the number, not
# how many zeroes precede it, so a mirror titled at one width is still
# found by an id spelled at another.
num_of_id() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -n 's/^task-0*\([0-9][0-9]*\)$/\1/p'
}

# tag_of_id <task-id> — the title's prefix: the id uppercased in brackets,
# character for character the tag its pull request title carries. The id's
# own width is kept rather than padded to four — `task-004` is that task's
# id, and a mirror is a projection of the file, never a correction of it.
tag_of_id() {
  printf '[%s]' "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
}

# Pass 1 — the spec statuses the diff itself carries, "id status" lines.
# "Ready for development" is derived, never stored: pending task, every
# spec approved. The mirror's label must derive it the same way — a spec
# the diff carries still `draft` (a fork merged past the convenience
# flip, an admin merge) means the task is not ready, whatever the merge
# implies. A spec the diff does not carry is already on main, where the
# check gate vouched for it.
SPEC_STATUSES=""
while IFS="$TAB" read -r fstatus fname fpatch; do
  [ "$fstatus" = "added" ] || continue
  printf '%s' "$fname" | tr '[:upper:]' '[:lower:]' \
    | grep -qE '^work/specs/spec-[0-9]+(-[a-z0-9-]+)?\.md$' || continue
  body=$(printf '%s' "$fpatch" | b64_decode | sed -n 's/^+//p')
  sid=$(fm_field "$body" id)
  [ -n "$sid" ] || continue
  SPEC_STATUSES="${SPEC_STATUSES}${sid} $(fm_field "$body" status)"$'\n'
done <<EOF
$FILES
EOF

spec_status_of() {
  printf '%s\n' "$SPEC_STATUSES" | awk -v id="$1" '$1 == id { print $2; exit }'
}
is_ready() {   # is_ready <spec-ref>... — every ref approved?
  local r s
  for r in "$@"; do
    [ -n "$r" ] || continue
    s=$(spec_status_of "$r")
    [ -n "$s" ] || s=approved
    [ "$s" = "approved" ] || return 1
  done
  return 0
}

# Pass 2 — the task files the diff adds, one tab-separated record each:
# id, filename, priority, milestone, spec refs (space-separated), title.
TASKS=""
while IFS="$TAB" read -r fstatus fname fpatch; do
  [ "$fstatus" = "added" ] || continue
  printf '%s' "$fname" | tr '[:upper:]' '[:lower:]' \
    | grep -qE '^work/tasks/task-[0-9]+(-[a-z0-9-]+)?\.md$' || continue
  body=$(printf '%s' "$fpatch" | b64_decode | sed -n 's/^+//p')
  tid=$(fm_field "$body" id)
  ttitle=$(first_heading "$body")
  if [ -z "$tid" ] || [ -z "$ttitle" ]; then
    echo "WARNING: Could not parse ${fname}; skipping."
    continue
  fi
  refs=$(fm_field "$body" spec_ref | tr -d '[]' | tr ',' ' ' | tr -s ' ' \
    | sed 's/^ *//; s/ *$//')
  # Tab is IFS whitespace, so an empty middle field would collapse on
  # read — an empty ref list travels as "-" instead.
  [ -n "$refs" ] || refs="-"
  TASKS="${TASKS}${tid}${TAB}${fname}${TAB}$(fm_field "$body" priority)${TAB}$(fm_field "$body" milestone)${TAB}${refs}${TAB}${ttitle}"$'\n'
done <<EOF
$FILES
EOF

# One list, fetched once, two lookups on it. Identity — the id prefix in
# the title, never a stored number — decides whether a mirror exists at
# all. Ownership — the "Introduced by" line this script writes into every
# body — decides whether this PR may reopen or retire it: an id collision
# with another PR's mirror is named in the log, never adopted.
ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '.[] | [.number, .state, ((.labels // []) | map(.name) | join(",")), (.title | @base64), ((.body // "") | @base64)] | @tsv')

issue_row_of() {   # issue_row_of <task-id> — "number<TAB>state<TAB>body-b64"
  local num state labels tb bb t tn want
  want=$(num_of_id "$1")
  [ -n "$want" ] || return 0
  while IFS="$TAB" read -r num state labels tb bb; do
    [ -n "$num" ] || continue
    t=$(printf '%s' "$tb" | b64_decode)
    tn=$(num_of_id "$(id_of_title "$t")")
    [ -n "$tn" ] || continue
    if [ "$tn" -eq "$want" ] 2>/dev/null; then
      printf '%s\t%s\t%s\n' "$num" "$state" "$bb"; return 0
    fi
  done <<EOF
$ISSUES
EOF
  return 0
}

OWN_LINE="| Introduced by | #${PR} |"
is_mine() {   # is_mine <body-b64>
  printf '%s' "$1" | b64_decode | grep -qF "$OWN_LINE"
}

# clear_status <issue> <labels-csv> — a retired mirror keeps every label
# except its place in the pipeline, for the same reason a completed one
# does (docs/product/pipeline.md#flows-and-statuses): the close and its
# reason are the terminal state, and a `status:` label left on top of them
# contradicts it.
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
    gh api -X DELETE "repos/${REPO}/issues/${1}/labels" >/dev/null
    return 0
  fi
  gh api -X PUT "repos/${REPO}/issues/${1}/labels" "${args[@]}" >/dev/null
}

ensure_label() {   # ensure_label <name> <color> <description>
  local out
  if ! out=$(gh api -X POST "repos/${REPO}/labels" \
      -f "name=$1" -f "color=$2" -f "description=$3" 2>&1); then
    # 422 = already exists; anything else is a real failure.
    printf '%s\n' "$out" | grep -q "HTTP 422" \
      || { printf '%s\n' "$out" >&2; exit 1; }
  fi
}

open=false;   [ "$PR_STATE" = "open" ]  && open=true
merged=false; [ "$PR_MERGED" = "true" ] && merged=true

# Mirrors are created at open only for an author the forge recognizes —
# the same trio every other authority check in this repository uses.
# Anyone else's tasks get their mirror at merge, when the queue really
# gains them: deferred, never denied — and a drive-by PR cannot spray
# Issues.
authorized=false
case "$PR_AUTHOR_ASSOCIATION" in
  OWNER|MEMBER|COLLABORATOR) authorized=true ;;
esac

if [ "$open" = "true" ]; then
  ensure_label "writrun:task" "1d76db" "Mirrors a work/tasks/ entry"
  ensure_label "status:proposed" "ededed" "A pull request proposes this task; it is not in the queue yet"
  ensure_label "status:pending" "fbca04" "In the queue, with a spec it references not yet approved"
  ensure_label "status:ready" "0e8a16" "Ready for development: task pending, specs approved"
fi

# Every task the diff adds gets a mirror in the right state.
LIVE_NUMS=""
while IFS="$TAB" read -r tid fname priority milestone refs ttitle; do
  [ -n "$tid" ] || continue
  [ "$refs" = "-" ] && refs=""
  LIVE_NUMS="${LIVE_NUMS} $(num_of_id "$tid")"

  row=$(issue_row_of "$tid")

  if [ -z "$row" ]; then
    # Closed unmerged: the queue never gained this task, so no mirror is
    # owed. Open or merged: create it — on merge this is the catch-up for
    # a task whose earlier events were missed, and it is born ready.
    if [ "$open" != "true" ] && [ "$merged" != "true" ]; then continue; fi
    if [ "$open" = "true" ] && [ "$authorized" != "true" ]; then
      echo "${tid}: author lacks authority — mirror deferred to merge."
      continue
    fi
    # Three states, not two. An open pull request only *proposes* the
    # task — it may still close unmerged, and the mirror retires with it,
    # so the queue does not hold it yet. A merged one puts it in the
    # queue, ready or not (docs/product/pipeline.md#flows-and-statuses).
    if [ "$open" = "true" ]; then
      lbl=status:proposed
    elif is_ready $refs; then
      lbl=status:ready
    else
      lbl=status:pending
    fi
    body=$(printf '%s\n' \
      "Mirrors [\`${fname}\`](${PR_HTML_URL}/files), which is the authority." \
      "Edits made here are **not** written back to the file." \
      "" \
      "| | |" \
      "|---|---|" \
      "| Priority | \`${priority}\` |" \
      "| Milestone | \`${milestone}\` |" \
      "${OWN_LINE}" \
      "" \
      "Becomes ready for development when #${PR} merges and every" \
      "spec in its \`spec_ref\` is \`approved\`.")
    gh api -X POST "repos/${REPO}/issues" \
      -f "title=$(tag_of_id "$tid") ${ttitle}" \
      -f "labels[]=writrun:task" \
      -f "labels[]=${lbl}" \
      -f "body=${body}" >/dev/null
    if [ "$merged" = "true" ]; then
      echo "Created issue for ${tid} (ready)"
    else
      echo "Created issue for ${tid}"
    fi
    continue
  fi

  num=$(printf '%s' "$row" | cut -f1)
  istate=$(printf '%s' "$row" | cut -f2)
  ibody=$(printf '%s' "$row" | cut -f3)

  if ! is_mine "$ibody"; then
    echo "WARNING: ${tid} is already mirrored by a different PR — id collision; not touching it."
    continue
  fi

  if [ "$open" = "true" ]; then
    # A reopened PR finds its mirrors closed as orphans; they are not
    # orphans any more.
    if [ "$istate" = "closed" ]; then
      # Reopened means open, and open means proposed — the task is back
      # to being offered, not back in the queue.
      gh api -X PATCH "repos/${REPO}/issues/${num}" -f state=open >/dev/null
      gh api -X PUT "repos/${REPO}/issues/${num}/labels" \
        -f "labels[]=writrun:task" -f "labels[]=status:proposed" >/dev/null
      echo "${tid} reopened with #${PR}"
    else
      echo "${tid} already mirrored; nothing to do."
    fi
    continue
  fi

  if [ "$merged" = "true" ]; then
    if is_ready $refs; then
      gh api -X PUT "repos/${REPO}/issues/${num}/labels" \
        -f "labels[]=writrun:task" -f "labels[]=status:ready" >/dev/null
      echo "${tid} is ready for development"
    else
      gh api -X PUT "repos/${REPO}/issues/${num}/labels" \
        -f "labels[]=writrun:task" -f "labels[]=status:pending" >/dev/null
      echo "${tid} merged with a spec still draft — kept pending"
    fi
  fi
done <<EOF
$TASKS
EOF

# Orphans: a mirror this PR introduced whose task is no longer in the
# diff (a rederivation dropped the file), and every mirror of a PR closed
# without merging.
closed_unmerged=false
[ "$open" != "true" ] && [ "$merged" != "true" ] && closed_unmerged=true

while IFS="$TAB" read -r num istate labels tb bb; do
  [ -n "$num" ] || continue
  [ "$istate" = "open" ] || continue
  is_mine "$bb" || continue
  oid=$(id_of_title "$(printf '%s' "$tb" | b64_decode)")
  [ -n "$oid" ] || continue
  if [ "$closed_unmerged" != "true" ]; then
    case " $LIVE_NUMS " in *" $(num_of_id "$oid") "*) continue ;; esac
  fi
  clear_status "$num" "$labels"
  gh api -X PATCH "repos/${REPO}/issues/${num}" \
    -f state=closed -f state_reason=not_planned >/dev/null
  if [ "$closed_unmerged" = "true" ]; then
    echo "${oid} closed — #${PR} was not merged"
  else
    echo "${oid} closed — its task left the diff"
  fi
done <<EOF
$ISSUES
EOF

exit 0
