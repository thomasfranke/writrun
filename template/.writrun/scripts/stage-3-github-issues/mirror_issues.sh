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
# **Which mirrors exist is this script's question; what they are labelled
# is not** — past the open event, where `status:proposed` is the one
# state no file can hold. From the merge on, the queue holds the task and
# the label is projected from it by rederive_labels.sh, sequentially in
# the same workflow that writes the queue. Both answers used to be
# derived here, from the pull request's own patch, and the second one was
# wrong every time a merge approved the specs it carried
# (docs/technical/decisions/github-issues/, 0048 and 0060).
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
# (docs/product/stage-3-github-issues/README.md), so one search for the tag
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

# **This script derives no `status:` label past the open event.** It once
# read "ready" out of the spec statuses in this pull request's own patch,
# where the merge has not yet flipped them — right for what a merge
# carried, wrong for what it caused, and it overwrote the correct write
# seconds after the approve workflow made it. The merged close now has
# one owner, and the label is the queue's to project
# (rederive_labels.sh; docs/product/stage-3-github-issues/labels.md).
# What is left here is the half only the diff can answer: which tasks the
# pull request puts in the queue, and therefore which mirrors must exist.
#
# The task files the diff adds, one tab-separated record each: id,
# filename, priority, milestone, origin, title.
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
  # Tab is IFS whitespace, so an empty middle field would collapse on
  # read — a missing `origin` travels as "-" instead. The schema requires
  # that field and the front-matter check refuses a task without it; this
  # runs after the merge, though, and a repository that does not gate on
  # the check can land one anyway. Read it as absent rather than trip
  # over it.
  torigin=$(fm_field "$body" origin)
  [ -n "$torigin" ] || torigin="-"
  TASKS="${TASKS}${tid}${TAB}${fname}${TAB}$(fm_field "$body" priority)${TAB}$(fm_field "$body" milestone)${TAB}${torigin}${TAB}${ttitle}"$'\n'
done <<EOF
$FILES
EOF

# One list, fetched once, two lookups on it. Identity — the id prefix in
# the title, never a stored number — decides whether a mirror exists at
# all. Ownership — the "Introduced by" line this script writes into every
# body — decides whether this PR may reopen or retire it, and the line is
# only worth as much as the pull request it names: a mirror another *open*
# pull request owns is named in the log and never touched, while one whose
# owner is gone is adopted (docs/product/stage-3-github-issues/README.md —
# the file is the authority and the mirror is a projection of it, so a
# task with a file and no reachable mirror is the one state this
# reconciliation may not leave behind).
ISSUES=$(gh api "repos/${REPO}/issues?labels=writrun:task&state=all&per_page=100" \
  --paginate \
  --jq '.[] | [.number, .state, ((.labels // []) | map(.name) | join(",")), (.title | @base64), ((.body // "") | @base64)] | @tsv')

issue_row_of() {   # issue_row_of <task-id> — "number<TAB>state<TAB>labels<TAB>body-b64"
  local num state labels tb bb t tn want
  want=$(num_of_id "$1")
  [ -n "$want" ] || return 0
  while IFS="$TAB" read -r num state labels tb bb; do
    [ -n "$num" ] || continue
    t=$(printf '%s' "$tb" | b64_decode)
    tn=$(num_of_id "$(id_of_title "$t")")
    [ -n "$tn" ] || continue
    if [ "$tn" -eq "$want" ] 2>/dev/null; then
      # Labels travel with the row because one of them must survive every
      # rewrite below: `origin:` is a fact about the task's birth, so a
      # relabelling pass re-states it rather than dropping it
      # (docs/product/stage-3-github-issues/labels.md).
      printf '%s\t%s\t%s\t%s\n' "$num" "$state" "$labels" "$bb"; return 0
    fi
  done <<EOF
$ISSUES
EOF
  return 0
}

OWN_LINE="| Introduced by | #${PR} |"
# `|` is literal in a basic regex, so the line matches as written.
OWN_RE='^| Introduced by | #[0-9][0-9]* |'
is_mine() {   # is_mine <body-b64>
  printf '%s' "$1" | b64_decode | grep -qF "$OWN_LINE"
}

# owner_of <body-b64> — the pull request number the mirror's ownership
# line names. Nothing when the body carries no such line, which is the
# same answer as "nobody": a line this script did not write is a line
# nobody is working behind.
owner_of() {
  printf '%s' "$1" | b64_decode \
    | sed -n 's/^| Introduced by | #\([0-9][0-9]*\) |.*/\1/p' | head -n1
}

# pr_is_open <number> — does the forge still call that pull request open?
# **This is the whole ownership question.** A mirror belongs to the pull
# request that introduced it only while that pull request is live; once it
# is closed or merged, nobody is working behind the line it left, and a
# refusal to touch the mirror only means the task never gets one. A number
# the forge does not know answers the same way, for the same reason.
pr_is_open() {
  local st
  st=$(gh api "repos/${REPO}/pulls/${1}" --jq '.state' 2>/dev/null) || return 1
  [ "$st" = "open" ]
}

# adopt_mirror <issue> <body-b64> — rewrite the ownership line to this
# pull request. Only the line: the body is the mirror's, and adopting is
# taking responsibility for it, not rewriting what it says.
adopt_mirror() {
  local body
  body=$(printf '%s' "$2" | b64_decode)
  if printf '%s\n' "$body" | grep -q "$OWN_RE"; then
    body=$(printf '%s\n' "$body" | sed "s/^| Introduced by | #[0-9][0-9]* |.*/${OWN_LINE}/")
  else
    body="${body}"$'\n'"${OWN_LINE}"
  fi
  gh api -X PATCH "repos/${REPO}/issues/${1}" -f "body=${body}" >/dev/null
}

# clear_status <issue> <labels-csv> — a retired mirror keeps every label
# except its place in the pipeline, for the same reason a completed one
# does (docs/product/stage-3-github-issues/labels.md): the close and its
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

# The origin label — `origin:rule` or `origin:report`, projecting the
# task's stored `origin`. Unlike `status:` it is never changed and never
# removed: origin is a fact about how the task came to exist, so it stays
# on the mirror through every state, closed included
# (docs/product/stage-3-github-issues/labels.md).
#
# origin_label <file-origin> <labels-csv> — the label to carry. A label
# the mirror already wears wins over the file, because the field is
# written once and a disagreement means this diff is the stale one; a
# task that arrives without the field — one the front-matter check should
# have refused — leaves the label empty rather than guessing, and the next
# recording commit adds it from the queue.
origin_label() {
  local worn
  worn=$(printf '%s\n' "$2" | tr ',' '\n' | grep '^origin:' | head -n1 || true)
  if [ -n "$worn" ]; then printf '%s' "$worn"; return 0; fi
  case "$1" in
    rule)   printf 'origin:rule' ;;
    report) printf 'origin:report' ;;
  esac
}

# ensure_origin_label <label> — created on first use like every other,
# in the vocabulary an Issues reader already knows: GitHub's stock bug
# red for a report, its documentation blue for a rule.
ensure_origin_label() {
  case "$1" in
    origin:rule)   ensure_label "origin:rule" "0075ca" "Derived from an authored rule" ;;
    origin:report) ensure_label "origin:report" "d73a4a" "Born from a report of work an existing rule authorizes" ;;
  esac
}

# put_status_labels <issue-number> <status-label> <origin-label> — the
# mirror's whole label set, rewritten. Every rewrite replaces the set, so
# the origin label is re-stated in each of them: leaving it out would be
# a removal, and this one is never removed.
#
# Only the open path calls it. `status:proposed` is the one label the
# queue cannot project, because the file is not on the authority branch
# yet — every other one is written from the queue, after the merge.
#
# Creating the label in the repository happens here, at the write, and
# not where the label is computed. The paths that decide *not* to touch a
# mirror — somebody else's and still open, or a pull request closed
# without merging — would otherwise leave a label behind in a repository
# where nothing wears it.
put_status_labels() {
  local args=()
  if [ -n "$3" ]; then
    ensure_origin_label "$3"
    args=(-f "labels[]=$3")
  fi
  gh api -X PUT "repos/${REPO}/issues/${1}/labels" \
    -f "labels[]=writrun:task" -f "labels[]=${2}" \
    ${args[@]+"${args[@]}"} >/dev/null
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

# Only what this script still writes. `status:backlog` and `status:ready`
# are the projection's, created where they are written — a label declared
# here and never worn is one more thing to keep in sync for nothing.
if [ "$open" = "true" ]; then
  ensure_label "writrun:task" "1d76db" "Mirrors a work/tasks/ entry"
  ensure_label "status:proposed" "ededed" "A pull request proposes this task; it is not in the queue yet"
fi

# Every task the diff adds gets a mirror in the right state.
LIVE_NUMS=""
while IFS="$TAB" read -r tid fname priority milestone torigin ttitle; do
  [ -n "$tid" ] || continue
  [ "$torigin" = "-" ] && torigin=""
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
    # An open pull request only *proposes* the task — it may still close
    # unmerged, and the mirror retires with it, so the queue does not
    # hold it yet, and no reader but this one can say so. A merged one
    # puts the task in the queue, and from there the label is derived
    # from the file: minted bare here, labelled by the projection that
    # runs next (docs/product/stage-3-github-issues/labels.md).
    status_args=()
    if [ "$open" = "true" ]; then
      status_args=(-f "labels[]=status:proposed")
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
    olbl=$(origin_label "$torigin" "")
    olabel_args=()
    if [ -n "$olbl" ]; then
      ensure_origin_label "$olbl"
      olabel_args=(-f "labels[]=${olbl}")
    fi
    gh api -X POST "repos/${REPO}/issues" \
      -f "title=$(tag_of_id "$tid") ${ttitle}" \
      -f "labels[]=writrun:task" \
      ${status_args[@]+"${status_args[@]}"} \
      ${olabel_args[@]+"${olabel_args[@]}"} \
      -f "body=${body}" >/dev/null
    if [ "$merged" = "true" ]; then
      echo "Created issue for ${tid} — its label is the projection's"
    else
      echo "Created issue for ${tid}"
    fi
    continue
  fi

  num=$(printf '%s' "$row" | cut -f1)
  istate=$(printf '%s' "$row" | cut -f2)
  ilabels=$(printf '%s' "$row" | cut -f3)
  ibody=$(printf '%s' "$row" | cut -f4)

  # The origin label the open path's rewrite carries, worked out here
  # where the mirror's worn labels are in hand. Nothing is created in the
  # repository yet: that is put_status_labels' job, at the write. The
  # merged path writes no labels at all, so a mirror missing its
  # `origin:` gains it from the projection instead.
  olbl=$(origin_label "$torigin" "$ilabels")

  # Three answers to "whose mirror is this", not two. Mine: proceed.
  # Somebody's, and that somebody is still open: refuse, exactly as
  # before — two live pull requests must never fight over one mirror.
  # Nobody's — the introducing pull request closed, merged, or never
  # existed: adopt it, because refusing leaves the task with no mirror at
  # all and nothing ever creates one.
  adopted=false
  if ! is_mine "$ibody"; then
    owner=$(owner_of "$ibody")
    if [ -n "$owner" ] && pr_is_open "$owner"; then
      echo "WARNING: ${tid} is mirrored by #${owner}, which is still open — not touching it."
      continue
    fi
    adopt_mirror "$num" "$ibody"
    adopted=true
    if [ -n "$owner" ]; then
      echo "${tid}: adopted stale mirror #${num} — #${owner} is no longer open."
    else
      echo "${tid}: adopted unowned mirror #${num} — no pull request introduced it."
    fi
  fi

  if [ "$open" = "true" ]; then
    # A reopened PR finds its mirrors closed as orphans; they are not
    # orphans any more. An adopted mirror gets the same treatment
    # whatever state it was in: its labels were the old owner's, and
    # this pass is what re-derives them.
    if [ "$istate" = "closed" ] || [ "$adopted" = "true" ]; then
      # Reopened means open, and open means proposed — the task is back
      # to being offered, not back in the queue.
      gh api -X PATCH "repos/${REPO}/issues/${num}" -f state=open >/dev/null
      put_status_labels "$num" "status:proposed" "$olbl"
      [ "$adopted" = "true" ] || echo "${tid} reopened with #${PR}"
    else
      echo "${tid} already mirrored; nothing to do."
    fi
    continue
  fi

  if [ "$merged" = "true" ]; then
    # A mirror adopted while closed is reopened here — the projection
    # writes a label next, and a closed issue wearing one says where the
    # task is twice and disagrees with itself.
    if [ "$adopted" = "true" ] && [ "$istate" = "closed" ]; then
      gh api -X PATCH "repos/${REPO}/issues/${num}" -f state=open >/dev/null
    fi
    # And no label. The merge is the moment the file became the truth,
    # so the label is the queue's to project — this pass has answered
    # the only question that was its own, which is whether the mirror
    # exists at all.
    echo "${tid} is in the queue; its label is the projection's"
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
