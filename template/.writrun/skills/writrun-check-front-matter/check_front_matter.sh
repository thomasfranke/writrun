#!/usr/bin/env bash
# check_front_matter.sh — every queue file's front matter is canonical.
#
# Usage: check_front_matter.sh [task-dir] [spec-dir] [docs-dir]
#   Defaults: work/tasks work/specs docs. Validates every task-*.md and
#   spec-*.md in the working tree; READMEs are skipped. All three are
#   relative to the working directory, and deliberately the same base: a
#   cwd wrong enough to hide `docs/` has already hidden the queue, so the
#   check finds nothing to complain about rather than complaining about
#   everything.
#
# Every reader in this methodology is line-based on purpose — plain
# bash/awk/sed, no YAML parser, no runtime dependency. YAML, though,
# allows the same meaning in forms those readers cannot see: a block
# list under `spec_ref:` reads as an empty list (a task would look
# ready without its approval gate), a quoted value never matches a path
# comparison, a folded scalar reads as nothing. Silently — which is the
# failure mode this repository treats as worse than a wrong answer.
#
# So the canonical form is a checked contract, not an assumption:
#
#   - front matter opens at line 1 with `---` and closes with `---`
#   - one field per line: `key: value` — no continuations, no comments
#   - values are bare: no quotes, no `>` / `|` block scalars, no
#     trailing whitespace
#   - every schema field present exactly once, even when null
#   - lists are inline — `[]` or `[spec-001, spec-002]` — and their
#     items are well-formed ids
#   - `id` agrees with the filename; statuses and priority hold only
#     their documented values; `blocked` and `blocked_reason` come
#     paired, both ways; dates are YYYY-MM-DD
#   - `doc_ref` is null or a path under docs/ written *relative to*
#     docs/ — a `docs/` prefix would double when the machinery resolves
#     it
#   - `origin` is `rule` or `report`, always present on a task — how it
#     came to exist is a fact, and there is no third answer
#
# Unknown keys in canonical shape are allowed — an adopter may extend.
# The schemas themselves: docs/technical/README.md.
#
# Exit codes: 0 every file canonical (or nothing to validate); 1 a file
# is malformed; 3 usage error.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions.

set -euo pipefail

TASK_DIR="${1:-work/tasks}"
SPEC_DIR="${2:-work/specs}"
DOCS_DIR="${3:-docs}"

status=0
checked=0

fail() {   # fail <file> <reason>
  echo "MALFORMED: $1: $2" >&2
  status=1
}

# fm_block <file> — prints the lines between the opening and closing
# `---`; fails when either fence is missing.
fm_block() {
  awk '
    NR == 1 { if ($0 != "---") exit 1; next }
    /^---$/ { closed = 1; exit }
    { print }
    END { exit closed ? 0 : 1 }
  ' "$1"
}

get() {   # get <block> <field> — first value, as a line-based reader sees it
  printf '%s\n' "$1" | sed -n "s/^$2: *//p" | head -n1
}

count() {   # count <block> <field>
  printf '%s\n' "$1" | grep -c "^$2:" || true
}

require_once() {   # require_once <file> <block> <field>
  local n
  n=$(count "$2" "$3")
  [ "$n" = "1" ] || fail "$1" "field '$3' must appear exactly once (found $n)"
}

check_shape() {   # check_shape <file> <block> — every line is `key: value`
  local line key val
  while IFS= read -r line; do
    [ -n "$line" ] || { fail "$1" "front matter holds an empty line"; continue; }
    case "$line" in
      *": "*) key="${line%%: *}"; val="${line#*: }" ;;
      *:)     fail "$1" "field '${line%:}' has no inline value — block forms are outside the contract"; continue ;;
      *)      fail "$1" "not a 'key: value' line: '$line' — continuations and list items are outside the contract"; continue ;;
    esac
    printf '%s' "$key" | grep -qE '^[A-Za-z_][A-Za-z0-9_-]*$' \
      || { fail "$1" "malformed key '$key'"; continue; }
    case "$val" in
      \"*|\'*) fail "$1" "field '$key' is quoted — values are written bare" ;;
      '>'|'|'|'>-'|'|-') fail "$1" "field '$key' uses a block scalar — outside the contract" ;;
    esac
    printf '%s' "$val" | grep -q '[[:space:]]$' \
      && fail "$1" "field '$key' carries trailing whitespace"
  done <<EOF
$2
EOF
  return 0
}

check_list() {   # check_list <file> <block> <field> <item-prefix>
  local val inner it
  val=$(get "$2" "$3")
  case "$val" in
    \[*\]) ;;
    *) fail "$1" "field '$3' must be an inline list — [] or [${4}-001, ...]"; return 0 ;;
  esac
  inner=$(printf '%s' "$val" | sed 's/^\[//; s/\]$//' | tr ',' ' ')
  for it in $inner; do
    printf '%s' "$it" | grep -qE "^${4}-[0-9]+$" \
      || fail "$1" "field '$3' item '$it' is not a ${4} id"
  done
  return 0
}

check_date() {   # check_date <file> <block> <field> <null-ok>
  # An RFC 3339 UTC timestamp, and `Z` is the only spelling accepted.
  # That is the load-bearing half: every reader here is line-based, and
  # with one spelling a lexicographic sort of these strings is a
  # chronological sort. Allowing `+02:00` alongside `Z` would keep `sort`
  # looking correct while being wrong for exactly the entries that
  # crossed a timezone (docs/technical/decisions/0049-...). A bare date
  # is rejected for the reason that rule exists: it cannot order two
  # entries made the same day, which is most of them in an active queue.
  local val
  val=$(get "$2" "$3")
  [ "$4" = "null-ok" ] && [ "$val" = "null" ] && return 0
  printf '%s' "$val" \
    | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' \
    || fail "$1" "field '$3' is '$val' — expected YYYY-MM-DDTHH:MM:SSZ$([ "$4" = "null-ok" ] && printf ' or null')"
  return 0
}

check_id() {   # check_id <file> <block> — id agrees with the filename's id
  # A queue file is named <id> or <id>-<subject>: identity is the id, the
  # subject slug only makes a directory listing readable. Both shapes are
  # canonical, and anything else disagrees with its own name.
  local want got
  want=$(basename "$1" .md | tr '[:upper:]' '[:lower:]')
  got=$(get "$2" "id" | tr '[:upper:]' '[:lower:]')
  case "$want" in
    "$got"|"$got"-*) return 0 ;;
  esac
  fail "$1" "id '$(get "$2" id)' is not the filename's id — a queue file is named <id>.md or <id>-<subject>.md"
  return 0
}

check_task() {   # check_task <file>
  local block f st reason pr org ref
  f="$1"
  if ! block=$(fm_block "$f"); then
    fail "$f" "front matter must open at line 1 with --- and close with ---"
    return 0
  fi
  check_shape "$f" "$block"
  for field in id status blocked_reason taken_by spec_ref doc_ref origin priority depends_on milestone created queued completed merged; do
    require_once "$f" "$block" "$field"
  done
  check_id "$f" "$block"

  st=$(get "$block" status)
  case "$st" in
    backlog|ready|in-progress|in-review|done|blocked|dropped) ;;
    *) fail "$f" "status '$st' is not a task status (backlog|ready|in-progress|in-review|done|blocked|dropped)" ;;
  esac

  # blocked and blocked_reason come paired, both ways: a blocked task
  # states its own unblock condition, and a reason on an unblocked task
  # is a status disagreeing with itself.
  reason=$(get "$block" blocked_reason)
  if [ "$st" = "blocked" ] && [ "$reason" = "null" ]; then
    fail "$f" "status is blocked but blocked_reason is null — a blocked task names what unblocks it"
  fi
  if [ "$st" != "blocked" ] && [ -n "$reason" ] && [ "$reason" != "null" ]; then
    fail "$f" "blocked_reason is set but status is '$st' — null unless blocked"
  fi

  # taken_by is the machinery's record of who has the task: a forge
  # login while a pull request works it, kept on done as who completed
  # it, null everywhere else — a login on a task nobody has is a claim
  # the forge never made.
  taken=$(get "$block" taken_by)
  if [ "$taken" != "null" ]; then
    printf '%s' "$taken" | grep -qE '^[A-Za-z0-9-]+(\[bot\])?$' \
      || fail "$f" "taken_by '$taken' is not a bare forge login or null"
    case "$st" in
      in-progress|in-review|done) ;;
      *) fail "$f" "taken_by is set but status is '$st' — a login only while a PR works the task, or on done" ;;
    esac
  fi

  pr=$(get "$block" priority)
  case "$pr" in
    high|medium|low) ;;
    *) fail "$f" "priority '$pr' is not high, medium, or low" ;;
  esac

  # How the task came to exist, and there are only two answers: derived
  # from an authored rule, or born from a report of work an existing rule
  # already authorizes. Written once at creation and never rewritten, so
  # the only thing left to hold is that it is there and says one of the
  # two (docs/technical/README.md#task-schema).
  org=$(get "$block" origin)
  case "$org" in
    rule|report) ;;
    *) fail "$f" "origin '$org' is not rule or report" ;;
  esac

  check_list "$f" "$block" spec_ref spec
  check_list "$f" "$block" depends_on task

  # Relative to docs/ — a docs/ prefix would double when the machinery
  # prefixes it back (queue impact, the delta check).
  ref=$(get "$block" doc_ref)
  if [ "$ref" != "null" ]; then
    case "$ref" in
      docs/*) fail "$f" "doc_ref starts with docs/ — paths are written relative to docs/" ;;
      *.md|*.md#*)
        # **The path, never the anchor.** Reverse traceability is only a
        # grep if the file is really there, and a doc_ref pointing at
        # nothing passed every check until now. The anchor is left
        # unverified on purpose: a heading can be renamed without moving
        # the file, and matching one means parsing markdown, which every
        # reader in this methodology refuses to do. So this proves the
        # file, not the section — a limit worth stating rather than a gap
        # to close later.
        target="${DOCS_DIR}/${ref%%#*}"
        [ -f "$target" ] \
          || fail "$f" "doc_ref '$ref' names no file — ${target} does not exist"
        ;;
      *) fail "$f" "doc_ref '$ref' is not null or a .md path (optionally with #anchor)" ;;
    esac
  fi

  # Four dates, one shape. `created` is the only one a task always has;
  # the machinery's two and `completed` are null until the event each
  # records happens (docs/product/pipeline.md#flows-and-statuses).
  check_date "$f" "$block" created strict
  check_date "$f" "$block" queued null-ok
  check_date "$f" "$block" completed null-ok
  check_date "$f" "$block" merged null-ok
  return 0
}

check_spec() {   # check_spec <file>
  local block f st ref
  f="$1"
  if ! block=$(fm_block "$f"); then
    fail "$f" "front matter must open at line 1 with --- and close with ---"
    return 0
  fi
  check_shape "$f" "$block"
  for field in id task_ref status created; do
    require_once "$f" "$block" "$field"
  done
  check_id "$f" "$block"

  st=$(get "$block" status)
  case "$st" in
    draft|approved|implemented) ;;
    *) fail "$f" "status '$st' is not a spec status (draft|approved|implemented)" ;;
  esac

  ref=$(get "$block" task_ref)
  printf '%s' "$ref" | grep -qE '^task-[0-9]+$' \
    || fail "$f" "task_ref '$ref' is not a task id — a spec belongs to exactly one task"

  check_date "$f" "$block" created strict
  return 0
}

for f in "$TASK_DIR"/*.md; do
  [ -f "$f" ] || continue
  case "$(basename "$f" | tr '[:upper:]' '[:lower:]')" in
    readme.md) continue ;;
    task-*.md) ;;
    *) continue ;;
  esac
  check_task "$f"
  checked=$((checked + 1))
done

for f in "$SPEC_DIR"/*.md; do
  [ -f "$f" ] || continue
  case "$(basename "$f" | tr '[:upper:]' '[:lower:]')" in
    readme.md) continue ;;
    spec-*.md) ;;
    *) continue ;;
  esac
  check_spec "$f"
  checked=$((checked + 1))
done

if [ "$status" -eq 0 ]; then
  echo "OK — ${checked} queue file(s), all canonical."
fi
exit "$status"
