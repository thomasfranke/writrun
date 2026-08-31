#!/usr/bin/env bash
# check_observance.sh — the settings an agent is told to obey, checked
# where disobedience leaves a trace
# (docs/technical/README.md#observance-is-checked-where-it-leaves-a-trace).
#
# Usage: check_observance.sh <diff-range>
#   The PR title and body arrive via $PR_TITLE and $PR_BODY — through the
#   environment, never inline interpolation: both are attacker-controlled
#   text on a fork PR. Run from the repository root.
#
# Two verifications, and both exist because the flag they enforce is
# otherwise pure trust:
#
#   1. **The title obeys `stage_2.pr_title_style`.** The style is the
#      adopter's choice and the squash puts the title into the authority
#      branch's history, so a title in the other style is a permanent
#      entry in a log the project decided would read one way.
#
#   2. **Nothing carries platform credit while `stage_2.credit_ai` is
#      `false`.** A co-author trailer, a session link or a generated-with
#      line in a commit message or the pull request body is exactly the
#      write that flag forbids, and it is visible from here.
#
# **What leaves no trace stays instruction-bound.** `auto_commit` and
# `auto_pr` govern whether the agent *asked* before acting, and no diff
# can show a question that wasn't asked. They are not checked, and this
# script does not pretend otherwise — a check that guessed at them would
# fail honest agents and pass the dishonest one that committed silently.
#
# **The machinery's own recording commit is never judged.** It is not an
# agent's action, so no conduct flag reaches it; it is skipped by its
# committer identity, which the workflow sets and nothing else in a pull
# request's range carries.
#
# Exit 0: the range and the title observe what the settings declare.
# Exit 1: they do not, with every offence named.
# Exit 3: usage error, or git could not be read.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail
RANGE="${1:?usage: check_observance.sh <diff-range>}"

HERE="$(cd "$(dirname "$0")" && pwd)"
READ_SETTING="$HERE/read_setting.sh"

faults=0
fault() { echo "REJECTED: $*" >&2; faults=$((faults + 1)); }

# The committer the approve workflow writes its one recording commit as.
# Matching on the identity rather than the subject is deliberate: the
# subject is a variable the adopter is invited to edit (conventions/
# commits.md), the identity is the forge's.
BOT_COMMITTER="github-actions[bot]"

# git_read <label> <git-args...> — runs git and leaves its stdout in
# GIT_OUT. On failure it prints what git said and exits 3, because a
# check that could not read its input must never report the empty result
# as a clean one: `$(git … || true)` yields the same empty string whether
# nothing matched or nothing ran, and this is a gate.
#
# **Never call this inside a command substitution.** The `exit` would end
# only the subshell, and the caller would go on reading the empty value
# this exists to prevent.
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

# ---------------------------------------------------------------- title

STYLE=$(bash "$READ_SETTING" stage_2.pr_title_style)
TITLE="${PR_TITLE:-}"

# The vocabularies, as conventions/commits.md spells them. They are the
# adopter's to edit there; this list is the machine half of the same
# statement, and the two are kept in step by hand — the file is prose an
# agent reads, not a format a script can parse.
TYPES="docs feat fix refactor chore"
SCOPES="about product technical tasks specs skills ci tests agents readme setup"

# The `[TASK-NNNN]` tag is not the settable part: one bracket per task,
# uppercase, no separator, leading the title. Stripping it leaves the
# summary, which is what the style governs. Authoring and reporting
# titles carry no tag, so for them the summary is the whole title — the
# same grammar, checked tagless.
summary="$TITLE"
while :; do
  case "$summary" in
    \[TASK-[0-9][0-9][0-9][0-9]\]*) summary="${summary#\[TASK-????\]}" ;;
    *) break ;;
  esac
done
# One space is allowed between the last tag and the summary, and only
# because a title with none reads as one word to a human scanning it.
summary="${summary# }"

in_list() {   # in_list <needle> <space-separated haystack> — case-folded
  local n
  n=$(printf '%s' "$1" | tr 'A-Z' 'a-z')
  case " $2 " in *" $n "*) return 0 ;; esac
  return 1
}

if [ -z "$TITLE" ]; then
  echo "No PR title given — the title check needs \$PR_TITLE and has none."
elif [ -z "$summary" ]; then
  fault "the title is nothing but task tags: '${TITLE}' — the style '${STYLE}' asks for a summary after them"
else
  case "$STYLE" in
    conventional)
      # type(scope): subject — the scope optional, omitted when a change
      # genuinely spans the repository.
      if printf '%s' "$summary" \
        | grep -qE '^[a-z]+(\([a-z-]+\))?: .+$'; then
        t=$(printf '%s' "$summary" | sed -E 's/^([a-z]+).*/\1/')
        sc=$(printf '%s' "$summary" | sed -nE 's/^[a-z]+\(([a-z-]+)\):.*/\1/p')
        in_list "$t" "$TYPES" \
          || fault "the title's type '${t}' is outside the vocabulary (${TYPES}): '${TITLE}'"
        if [ -n "$sc" ]; then
          in_list "$sc" "$SCOPES" \
            || fault "the title's scope '${sc}' is outside the vocabulary (${SCOPES}): '${TITLE}'"
        fi
      else
        fault "the title does not read as the declared 'conventional' style — 'type(scope): subject' after any task tags: '${TITLE}'"
      fi ;;
    bracketed)
      # [Type][Scope] Sentence — the scope optional for the same reason.
      # Case inside the brackets is not judged: the convention writes
      # `[Docs][Product]` for an implementing title and `[DOCS]` for an
      # authoring one, and a check that picked one would reject the
      # project's own examples.
      if printf '%s' "$summary" \
        | grep -qE '^\[[A-Za-z]+\](\[[A-Za-z-]+\])? .+$'; then
        t=$(printf '%s' "$summary" | sed -E 's/^\[([A-Za-z]+)\].*/\1/')
        sc=$(printf '%s' "$summary" | sed -nE 's/^\[[A-Za-z]+\]\[([A-Za-z-]+)\].*/\1/p')
        in_list "$t" "$TYPES" \
          || fault "the title's type '${t}' is outside the vocabulary (${TYPES}): '${TITLE}'"
        if [ -n "$sc" ]; then
          in_list "$sc" "$SCOPES" \
            || fault "the title's scope '${sc}' is outside the vocabulary (${SCOPES}): '${TITLE}'"
        fi
      else
        fault "the title does not read as the declared 'bracketed' style — '[Type][Scope] Sentence' after any task tags: '${TITLE}'"
      fi ;;
    *)
      # An unreadable style is check_settings.sh's fault to name. Judging
      # the title against a vocabulary nobody declared would fail every
      # honest title for a fault in another file.
      echo "pr_title_style is '${STYLE}', which this check does not know — check_settings.sh names that; no title judged." ;;
  esac
fi

# --------------------------------------------------------------- credit

CREDIT=$(bash "$READ_SETTING" stage_2.credit_ai)

if [ "$CREDIT" != "false" ]; then
  echo "credit_ai is '${CREDIT}' — the adopter allows platform credit, so nothing is judged here."
else
  # Trailers and whole lines, never a subject: a title that *mentions*
  # a trailer ("remove the Co-Authored-By trailer") is prose about the
  # rule, not an instance of it. Anchored to the start of a line for the
  # same reason.
  CREDIT_LINES='^[[:space:]]*(Co-[Aa]uthored-[Bb]y:|Claude-Session:|Generated-[Bb]y:|Co-authored-by:)'
  CREDIT_PROSE='(Generated with \[?Claude|🤖 Generated with|https://claude\.ai/code/session)'

  # The commits in the range, minus the machinery's own. The committer
  # name is read rather than the message, so the skip is by identity and
  # no subject text can imitate it.
  git_read "git log --format ${RANGE}" \
    log --format='%h%x09%cn' "$RANGE"
  shas=$(printf '%s\n' "$GIT_OUT" \
    | grep -vF "	${BOT_COMMITTER}" \
    | cut -f1 || true)

  for sha in $shas; do
    [ -n "$sha" ] || continue
    git_read "git log -1 --format=%B ${sha}" log -1 --format='%B' "$sha"
    hit=$(printf '%s\n' "$GIT_OUT" \
      | grep -E "$CREDIT_LINES|$CREDIT_PROSE" | head -n 1 || true)
    [ -z "$hit" ] || fault "commit ${sha} carries platform credit while credit_ai is false: ${hit}"
  done

  body="${PR_BODY:-}"
  if [ -n "$body" ]; then
    hit=$(printf '%s\n' "$body" \
      | grep -E "$CREDIT_LINES|$CREDIT_PROSE" | head -n 1 || true)
    [ -z "$hit" ] || fault "the pull request body carries platform credit while credit_ai is false: ${hit}"
  fi
fi

# ---------------------------------------------------------------- close

if [ "$faults" -ne 0 ]; then
  echo "" >&2
  echo "These are settings the project declared and an agent was told to" >&2
  echo "obey. What leaves a trace is checked rather than trusted" >&2
  echo "(docs/technical/README.md#observance-is-checked-where-it-leaves-a-trace)." >&2
  exit 1
fi

echo "OK — the title observes '${STYLE}', and credit_ai is honoured."
