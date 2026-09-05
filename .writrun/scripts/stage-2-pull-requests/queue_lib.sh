#!/usr/bin/env bash
# queue_lib.sh — the helpers both halves of the transition machine share:
# front-matter reads and writes, the resting derivation, the task-file
# resolver, and the carried-ids parser. Sourced, never executed; the
# sourcing script owes `set -euo pipefail` itself.
#
# One copy on purpose: flip_task_status.sh and record_task_status.sh
# each carried private clones of these until a review caught the clones
# drifting — and caught the resolver pipeline dying under pipefail when
# the last find candidate failed the id filter.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions. See the
# standing rule in docs/technical/decisions/.

# ql_fm_field <field> <file> — the field's value from the front-matter
# block alone; a body line spelling `status:` at column 0 never counts.
ql_fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  ' "$2"
}

# ql_set_field <file> <field> <value> — front matter only.
ql_set_field() {
  awk -v field="$2" -v value="$3" '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && /^---$/        { infm = 0; print; next }
    infm && index($0, field ":") == 1 { print field ": " value; next }
    { print }
  ' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# ql_task_num <anything> — the task number, zero-padding stripped;
# empty when the input names none.
#
# The zeros go in a step of their own, after the prefix rather than with
# it: `0034` is how every queue file and every [TASK-NNNN] tag spells the
# id, so it is what a person retypes — and stripping the padding only
# when a `task-` prefix carried it made that spelling resolve to nothing.
ql_task_num() {
  printf '%s' "$1" | sed -E 's/^task-//; s/^task\///; s/^0+//; s/[^0-9].*$//'
}

# ql_task_file <task-id-or-number> — the work/tasks file whose id is
# that number, whatever width it was written at; empty when none. The
# filter is an `if` on purpose: a trailing failed `[ … ] &&` would end
# the while loop non-zero and, under pipefail, kill the caller with no
# output at all.
ql_task_file() {
  local num
  num=$(ql_task_num "$1")
  [ -n "$num" ] || return 0
  find work/tasks \( -iname "task-*${num}.md" -o -iname "task-*${num}-*.md" \) 2>/dev/null \
    | while IFS= read -r c; do
        if [ "$(ql_task_num "$(basename "$c" .md)")" = "$num" ]; then
          printf '%s\n' "$c"
        fi
      done | head -n1
  return 0
}

# ql_spec_file <spec-id> — same resolution for a spec.
ql_spec_file() {
  find work/specs \( -iname "$1.md" -o -iname "$1-*.md" \) 2>/dev/null | head -n1
  return 0
}

# ql_resting <task-file> — where a task out of flight belongs: ready, or
# backlog if any spec it references is draft. An empty spec_ref is ready
# by construction — no approval event exists for it, and backlog must
# not be a trap.
ql_resting() {
  local refs ref spec st
  refs=$(ql_fm_field spec_ref "$1" | tr -d '[]' | tr ',' ' ')
  for ref in $refs; do
    [ -n "$ref" ] || continue
    spec=$(ql_spec_file "$ref")
    [ -n "$spec" ] || continue
    st=$(ql_fm_field status "$spec")
    if [ "$st" = "draft" ]; then printf 'backlog'; return 0; fi
  done
  printf 'ready'
}

# QL_CARRIED_MAX — the most distinct tasks one pull request may claim.
# It bounds the carried set below, counted after dedup, because the set
# is what becomes status writes: both routes into it are the author's to
# type, and without a ceiling one title moves the queue by being long.
# A constant, not a setting: the schema requires a key's documented
# default to be the behaviour from before the key existed, and here that
# behaviour is unbounded — the defect itself. Eight sits above five, the
# largest related batch one merge here ever produced, and far below the
# queue (docs/technical/decisions/pull-requests/0068-what-a-pull-request-claims-is-bounded.md).
QL_CARRIED_MAX=8

# ql_carried_of <head-branch> <title> — the task ids whose work a pull
# request carries: the head branch's own (task/NNNN-*) plus every
# [TASK-NNNN] tag leading the title, deduplicated. Both arguments are a
# fork's to write, so only digits survive.
#
# Above QL_CARRIED_MAX distinct tasks, the whole set is refused: the
# sentinel `over-ceiling:<count>` is printed alone on stdout, and the
# exit stays 0. A caller tests for it with one `case` before touching
# the ids; ql_carried_from_env passes it through untouched. Exit 0 on
# purpose — every call site assigns this output bare under
# `set -euo pipefail`, and a non-zero substitution would kill such a
# caller with no message at all. The sentinel is a token no task id can
# be, in the stream every caller already reads, so a forgetful caller
# meets a non-id that matches no task file, never a vanished run.
#
# Taking the pair as arguments is what lets a caller ask the question of
# *another* pull request — the amendment check has to, to name the one it
# suspends, and apply_pr_event.sh's survivor query has to, so a close
# finds a survivor by every route it carries a task — while the
# env-reading form below stays the shape CI uses.
ql_carried_of() {
  local carried="" num rest tg
  case "${1:-}" in
    task/[0-9]*)
      num=$(ql_task_num "$1")
      [ -n "$num" ] && carried="task-$num"
      ;;
  esac
  rest="${2:-}"
  while :; do
    rest=$(printf '%s' "$rest" | sed 's/^[[:space:]]*//')
    tg=$(printf '%s' "$rest" | sed -n 's/^\[[Tt][Aa][Ss][Kk]-0*\([0-9][0-9]*\)\].*/\1/p')
    [ -n "$tg" ] || break
    case " $carried " in
      *" task-$tg "*) ;;
      *) carried="${carried:+$carried }task-$tg" ;;
    esac
    rest=$(printf '%s' "$rest" | sed 's/^\[[Tt][Aa][Ss][Kk]-[0-9][0-9]*\]//')
  done
  # The count is of the deduplicated set, never of the tags: the set is
  # what becomes writes, so a title repeating one tag fifty times still
  # claims one task. Word splitting is the count — the ids carry no
  # spaces and no globs.
  # shellcheck disable=SC2086
  set -- $carried
  if [ "$#" -gt "$QL_CARRIED_MAX" ]; then
    printf 'over-ceiling:%s' "$#"
    return 0
  fi
  printf '%s' "$carried"
}

# ql_carried_from_env — the same question about the pull request CI is
# running on, read from env as data (PR_HEAD_REF, PR_TITLE).
ql_carried_from_env() {
  ql_carried_of "${PR_HEAD_REF:-}" "${PR_TITLE:-}"
}

# --- minting ------------------------------------------------------------
#
# The id and the filename subject, shared by the two writers that mint
# queue ids: the generator (skills/writrun-create-task-and-spec/new.sh)
# and the intake (scripts/stage-3-github-issues/intake_report.sh). One
# copy for the same reason the helpers above are one copy: the intake
# opened with a private clone of this stack, and by its first review the
# clone had already dropped the outside-a-repository guard and the
# generator's collision check.
#
# QL_FORGE_VIEW is `forge` once open pull requests have answered,
# `local` otherwise; QL_FORGE_PATHS holds every path they touch. Never
# call ql_forge_scan from inside a command substitution — the subshell
# would swallow both.
QL_FORGE_VIEW=local
QL_FORGE_PATHS=""

# ql_forge_scan [owner/repo] — asks the forge for the paths open pull
# requests touch. With an argument, every call is pinned to that
# repository; without one, gh answers for the checkout's own remote —
# the two channels must agree, or the scan reads one repository's pull
# request numbers and another's file lists.
#
# One call per open pull request instead of one call total, because the
# single `gh pr list --json files` this replaced was cheaper and wrong:
# that field stops at 100 files per pull request and says nothing when
# it does, so a larger diff hides every queue file it adds past the cut.
#
# All or nothing: a call that fails — or a listing that filled its own
# limit, which is a listing that may have been cut — leaves the view
# local rather than quietly narrow, since a scan that under-reports
# without saying so is the exact failure the uniqueness rule exists to
# prevent.
ql_forge_scan() {
  QL_FORGE_VIEW=local
  QL_FORGE_PATHS=""
  command -v gh >/dev/null 2>&1 || return 0
  local repo="${1:-}" numbers paths files n count
  if [ -n "$repo" ]; then
    numbers=$(gh pr list -R "$repo" --state open --limit 200 --json number \
      --jq '.[].number' 2>/dev/null) || return 0
  else
    # gh defaults to 30 open pull requests, and the id this misses is
    # exactly the one worth seeing.
    numbers=$(gh pr list --state open --limit 200 --json number \
      --jq '.[].number' 2>/dev/null) || return 0
  fi
  count=$(printf '%s\n' "$numbers" | sed '/^$/d' | wc -l | tr -d ' ')
  [ "$count" -ge 200 ] && return 0
  paths=""
  for n in $numbers; do
    # --paginate is the point: a pull request's own file list is paged
    # too, and the queue file may sit on any page of it.
    if [ -n "$repo" ]; then
      files=$(gh api "repos/${repo}/pulls/${n}/files" --paginate \
        --jq '.[].filename' 2>/dev/null) || return 0
    else
      files=$(gh api "repos/{owner}/{repo}/pulls/${n}/files" --paginate \
        --jq '.[].filename' 2>/dev/null) || return 0
    fi
    paths="${paths}${files}
"
  done
  QL_FORGE_VIEW=forge
  QL_FORGE_PATHS="$paths"
  return 0
}

# ql_mint_note — what the id was minted against, printed after the file
# so an id claimed elsewhere is never reported as simply "created".
ql_mint_note() {
  if [ "$QL_FORGE_VIEW" = forge ]; then
    echo "Minted above the queue, its history, and every open pull request."
  else
    echo "Minted from this checkout and its history only — no forge answered," >&2
    echo "so an id an open pull request already claims would not have been seen." >&2
  fi
}

# ql_next_id <dir> <prefix> — e.g. ql_next_id work/tasks task
ql_next_id() {
  local dir="$1" prefix="$2" max=0 f n
  bump() {
    # The id is the digits after the prefix; a filename subject slug
    # follows them (task-0004-file-naming) and is not part of identity.
    n=$(basename "$1" .md | tr '[:upper:]' '[:lower:]' \
      | sed -E "s/^${prefix}-0*([0-9]+).*/\1/")
    [[ "$n" =~ ^[0-9]+$ ]] || return 0
    (( n > max )) && max=$n
    return 0
  }

  # Scan case-insensitively so historical uppercase IDs contribute to the
  # next number while newly generated filenames remain lowercase.
  # A directory that is not there is zero files, not a failure: an adopter
  # who has never recorded a report has no work/reports/, and minting the
  # first id is exactly the moment that is still true.
  while IFS= read -r f; do bump "$f"; done \
    < <(find "$dir" -maxdepth 1 -type f -iname "${prefix}-*.md" -print 2>/dev/null)

  # An id is never reused, including after its file was deleted — and a
  # deleted file is invisible to the scan above. Every id this directory
  # ever held is recoverable from the history, so ask it too. Outside a git
  # repository the filesystem is all there is, which is the correct answer
  # there: nothing was ever deleted from a history that doesn't exist.
  if git rev-parse --git-dir >/dev/null 2>&1; then
    while IFS= read -r f; do
      case "$f" in "$dir"/*) bump "$f" ;; esac
    done < <(git log --diff-filter=A --name-only --pretty=format: -- "$dir" 2>/dev/null)
  fi

  # An open pull request holds numbers no branch here can see: it may be
  # a fork's, and even from this repository it reaches this checkout only
  # once fetched. Its paths are the third input, and the one the tree and
  # the history cannot stand in for.
  if [ -n "$QL_FORGE_PATHS" ]; then
    while IFS= read -r f; do
      case "$f" in "$dir"/*) bump "$f" ;; esac
    done <<EOT
$QL_FORGE_PATHS
EOT
  fi

  printf "%04d" $((max + 1))
}

# ql_slugify <title> — the filename's subject, **derived**: an extremely
# short kebab-case echo of the title, at most three words. Identity
# lives in the id, so a derived slug that loses nuance costs nothing; it
# exists to make a directory listing readable. Prints nothing when the
# title has no usable word, and the caller then writes a bare-id
# filename.
ql_slugify() {
  printf '%s' "$1" \
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
      }'
}
