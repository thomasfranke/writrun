#!/usr/bin/env bash
# check_promise_companions.sh — a promise includes its mandatory
# companions, refused where the spec enters.
#
# Usage: check_promise_companions.sh <diff-range>
#
# Some documents never change alone: a rule elsewhere makes touching one
# imply touching another, so a promise naming the first without the
# second is not a smaller promise — it is a wrong one
# (docs/product/concepts/spec.md#the-doc-delta-contract).
#
# **Where this fires is the whole point.** The completion gate,
# `writrun-check-spec-deltas`, already catches an incomplete promise —
# but it catches it against a finished branch, where the fix is an
# amendment under an open pull request and a suspended task. That is the
# case this check exists to stop happening again: it reads the specs the
# range adds or modifies, which is the pull request that *creates or
# amends* a spec, where the fix is one edit and nothing has been assented
# to yet. It is not a second completion gate and never judges the diff's
# doc changes — only the promise's own internal completeness.
#
# **The pair table is a table so a second pair is a row.** One line per
# pair, `<entry-glob> <companion>`, both repository-root relative — the
# shape promises are normalised to below. The first pair is the one the
# authoring case named; the next one is a line, not a rewrite.
#
# Exit codes: 0 every promise read carries its companions, or there was
# no promise to read; 1 a promise is incomplete, with each named; 3 usage
# error, or a range that could not be read.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions, no associative
# arrays. See the standing rule in docs/technical/decisions/.

set -euo pipefail

RANGE="${1:?usage: check_promise_companions.sh <diff-range>}"

# --- the pair table -------------------------------------------------------
#
# The dated decisions log and its chronology index. The index is the only
# part of that folder that is rewritten, and it is rewritten by appending
# a row whenever an entry is added — so an entry promised alone is always
# a promise short of the truth.
#
# The leading `*` in the entry glob is what covers both `decisions_style`
# variants at once: `per-subsystem` puts the entry in a folder of the
# adoption level it concerns, `chronological` puts it in the log's root,
# and a `case` pattern's `*` spans the separator either way. A project
# that spells its layout a third way changes this row; it does not read
# the setting, because the promise is a path and the path is what is
# being judged.
PAIRS="
docs/technical/decisions/*[0-9][0-9][0-9][0-9]-*.md docs/technical/decisions/README.md
"

# git_read <label> <git-args...> — runs git and leaves its stdout in
# GIT_OUT. On failure it prints what git said and exits 3, because a
# check that could not read its input must never report the empty result
# as a clean one: `$(git … || true)` yields exactly the same empty string
# whether nothing matched or nothing ran, and this one is a gate
# (spec-0013).
#
# **Never call this inside a command substitution.** The `exit` would end
# only the subshell, and the caller would go on reading the empty value
# this exists to prevent — the very shape of the bug being removed.
GIT_OUT=""
git_read() {
  local label="$1" err
  shift
  err=$(mktemp "${TMPDIR:-/tmp}/writrun-git.XXXXXX")
  if ! GIT_OUT=$(git "$@" 2>"$err"); then
    echo "${label} failed:" >&2
    head -n 2 "$err" >&2
    rm -f "$err"
    exit 3
  fi
  rm -f "$err"
}

# promised_paths <spec-file> — every path both Proposed-changes sections
# name, anchor stripped, normalised to repository-root the way the schema
# says to read them: a spec writes `technical/…`, relative to `docs/`.
#
# A deliberate second reader of the same two sections, not a call into
# the completion gate: that script is a Stage 1 skill and must keep
# running with nothing but `work/` and git, while this one is workflow
# machinery. The scope of what they share is four lines of awk; the cost
# of coupling them is a skill that stops working where it is promised to.
#
# The empty line is dropped *before* the prefix, or a `none —` bullet's
# nothing would arrive as the path `docs/`.
promised_paths() {
  awk '
    /^## Proposed (product|technical) changes/ { inp = 1; next }
    /^## / && inp { inp = 0 }
    inp && /^- `/ { print }
  ' "$1" \
    | sed -n 's/^- `\([^`]*\)`.*/\1/p' | sed 's/#.*//' \
    | sed '/^$/d' | sed 's|^|docs/|' | sort -u
}

# fm_field <field> <file> — the front-matter block alone; a body line
# spelling `id:` at column 0 never counts.
fm_field() {
  awk -v f="$1" '
    NR == 1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    sub("^" f ": *", "") { sub(/[[:space:]]*$/, ""); print; exit }
  ' "$2"
}

# --- the specs this change enters -----------------------------------------

git_read "git diff --name-only ${RANGE} -- work/specs" \
  diff --name-only "$RANGE" -- 'work/specs/*.md'
touched="$GIT_OUT"

read_specs=0
faults=0
fault() { echo "REJECTED: $*" >&2; faults=$((faults + 1)); }

# Read line by line and never with `for s in $touched`: word splitting
# turns one path containing a space into two paths that exist nowhere,
# each skipped by the `-f` test below — a promise dropped in silence,
# which for a gate is the same failure as reading nothing at all.
#
# Here-documents throughout rather than pipes: a pipeline's subshell
# cannot raise the counter it is counting into.
while IFS= read -r spec; do
  [ -n "$spec" ] || continue

  # git quotes a path holding control characters or non-ASCII bytes. A
  # spec path never needs it, so a quoted one is a path this check cannot
  # parse, and an unparseable input is refused rather than skipped.
  case "$spec" in
    '"'*)
      echo "cannot read the changed path ${spec} — refusing rather than skipping it" >&2
      exit 3
      ;;
  esac

  [ -f "$spec" ] || continue        # deleted on the branch: promises nothing

  promised=$(promised_paths "$spec")
  [ -n "$promised" ] || continue    # a promise of "none" names no path
  read_specs=$((read_specs + 1))

  id=$(fm_field id "$spec")
  [ -n "$id" ] || id="$spec"

  while read -r glob companion; do
    [ -n "$glob" ] || continue

    # Asked once per pair rather than once per entry: a promise naming
    # three entries and the index is complete, and asking per entry would
    # only be the same yes three times.
    if printf '%s\n' "$promised" | grep -qxF "$companion"; then
      continue
    fi

    while IFS= read -r p; do
      [ -n "$p" ] || continue
      # Unquoted on purpose: the table's field is a pattern, not a path.
      case "$p" in
        $glob) ;;
        *) continue ;;
      esac
      fault "${id} promises ${p} and not ${companion}, which adding an entry implies."
    done <<PROMISED
${promised}
PROMISED
  done <<PAIRTABLE
${PAIRS}
PAIRTABLE
done <<TOUCHED
${touched}
TOUCHED

if [ "$faults" -ne 0 ]; then
  echo "" >&2
  echo "Some documents never change alone, and a promise naming the first" >&2
  echo "without the second is wrong rather than smaller. Add the companion" >&2
  echo "to the same Proposed changes section — here, where it is one edit," >&2
  echo "rather than at the completion gate, where it is an amendment under" >&2
  echo "a finished branch" >&2
  echo "(docs/product/concepts/spec.md#the-doc-delta-contract)." >&2
  exit 1
fi

if [ "$read_specs" -eq 0 ]; then
  echo "No spec this change adds or modifies promises a path — nothing to judge."
  exit 0
fi

echo "OK — ${read_specs} promise(s) read; every mandatory companion is present."
