#!/usr/bin/env bash
# new.sh — scaffolds a schema-correct task or spec file.
#
# Usage:
#   new.sh task "<title>" [--priority high|medium|low] \
#                          [--depends-on task-nnn[,task-mmm...]] \
#                          [--doc-ref path/to/doc.md#anchor] \
#                          [--milestone name]
#   new.sh spec task-nnn "<title>"
#
# Run from the repository root — paths are relative to work/tasks and
# work/specs there.
#
# Exists because the schema in docs/technical/README.md is precise about
# details easy to get wrong from memory: spec_ref/depends_on are always
# lists even with one element, doc_ref is a full path+anchor resolved
# relative to docs/, and every field is present even when null. A
# hand-written task drifted on exactly these while this methodology's own
# docs/product/ chapters were being drafted (see
# docs/product/concepts/task.md#example) — this script fills them
# mechanically instead of relying on an agent recalling the rules
# correctly every time.
#
# `new.sh spec` also appends the new spec's id to its task's spec_ref list
# — appends, never overwrites existing entries.
#
# The next id is minted above the queue, the history, *and* every open pull
# request — an id is unique across all three
# (docs/technical/README.md#task-schema). Consulting the forge is
# best-effort by design: no `gh`, no network, or no auth mints from this
# checkout alone, exactly as before, and says so. A narrower view is not
# wrong, it is narrower — and a silently narrower scan is how two branches
# cut from the same main both claimed 0009 here.
#
# Body templates resolve in three layers — the project's shape wins:
#   1. .writrun/conventions/templates/{task,spec}.md   — the project customized
#   2. .writrun/templates/{task,spec}.md      — WritRun's shipped default
#   3. the skeleton built into this script    — safety: works anywhere
# The template's {{id}}, {{title}}, {{task_ref}} are substituted.
#
# The *contract* front matter is always generated here, never templated —
# the machinery reads those fields, and a template that reshaped them
# would blind it silently. A project template may, however, open with a
# front-matter block of its own: those are **extension fields** (owner,
# estimate, whatever the project tracks), appended to the generated
# contract block. A template that redefines a contract field, or writes
# an extension the canonical form would reject, is refused — the same
# pattern as a spec template missing the contract headings (the two
# Proposed-changes sections and Outcome), which generation also refuses:
# a shape that would blind or fail a check is stopped where it is born.
#
# Exit codes: 0 success; 3 usage error or an invalid project template.

set -euo pipefail

# --- what open pull requests already claim --------------------------------
#
# FORGE_VIEW is `forge` once open pull requests have answered, `local`
# otherwise; FORGE_PATHS holds every path they touch. Never called from
# inside a command substitution — the subshell would swallow both.
FORGE_VIEW=local
FORGE_PATHS=""

# forge_scan — asks the forge for the paths open pull requests touch,
# added *or* modified. Coarser than the collision check downstream, and
# deliberately: a generator needs an upper bound, not an accusation. A
# modified queue file's id is already on the branch this checkout reads,
# so folding it in can only agree with what the tree said — while the one
# extra call per pull request that `status` would cost buys nothing.
forge_scan() {
  command -v gh >/dev/null 2>&1 || return 0
  local paths
  # gh defaults to 30 open pull requests, and the id this misses is
  # exactly the one worth seeing.
  paths=$(gh pr list --state open --limit 200 --json files \
    --jq '.[].files[]?.path' 2>/dev/null) || return 0
  FORGE_VIEW=forge
  FORGE_PATHS="$paths"
  return 0
}

# mint_report — what the id above was minted against, printed after the
# file so an id claimed elsewhere is never reported as simply "created".
mint_report() {
  if [ "$FORGE_VIEW" = forge ]; then
    echo "Minted above the queue, its history, and every open pull request."
  else
    echo "Minted from this checkout only — no forge answered, so an id an" >&2
    echo "open pull request already claims would not have been seen." >&2
  fi
}

next_id() {
  # next_id <dir> <prefix>  — e.g. next_id work/tasks task
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
  while IFS= read -r f; do bump "$f"; done \
    < <(find "$dir" -maxdepth 1 -type f -iname "${prefix}-*.md" -print)

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
  if [ -n "$FORGE_PATHS" ]; then
    while IFS= read -r f; do
      case "$f" in "$dir"/*) bump "$f" ;; esac
    done <<EOF
$FORGE_PATHS
EOF
  fi

  printf "%04d" $((max + 1))
}

# slugify <title> — the filename's subject: an extremely short kebab-case
# echo of the title, at most three words. Identity lives in the id, so a
# slug that loses nuance costs nothing; it exists to make a directory
# listing readable. Prints nothing when the title has no usable word,
# and the caller then writes a bare-id filename.
slugify() {
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

# queue_file <dir> <prefix> <id> — the file whose id is <id>, whatever
# its filename subject and whatever width its number was written at.
# Prints nothing when no file matches.
queue_file() {
  local dir="$1" prefix="$2" want f n
  want=$(printf '%s' "$3" | tr '[:upper:]' '[:lower:]' \
    | sed -E "s/^${prefix}-0*([0-9]+)$/\1/")
  [[ "$want" =~ ^[0-9]+$ ]] || return 0
  for f in "$dir"/"$prefix"-*.md; do
    [[ -f "$f" ]] || continue
    n=$(basename "$f" .md | tr '[:upper:]' '[:lower:]' \
      | sed -E "s/^${prefix}-0*([0-9]+).*/\1/")
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    if (( n == want )); then printf '%s' "$f"; return 0; fi
  done
  return 0
}

# render_template <file> <id> <title> <task_ref> — prints the template
# with {{id}}, {{title}}, {{task_ref}} substituted. Pure parameter
# expansion: titles may carry any character sed would trip on.
render_template() {
  local content
  content=$(<"$1")
  content=${content//'{{id}}'/$2}
  content=${content//'{{title}}'/$3}
  content=${content//'{{task_ref}}'/$4}
  printf '%s\n' "$content"
}

# body_template_for <task|spec> — the project's template wins, then the
# shipped default; empty output means fall back to the built-in skeleton.
body_template_for() {
  if [[ -f ".writrun/conventions/templates/$1.md" ]]; then
    printf '.writrun/conventions/templates/%s.md' "$1"
  elif [[ -f ".writrun/templates/$1.md" ]]; then
    printf '.writrun/templates/%s.md' "$1"
  fi
}

# The contract fields — the script's to write, never a template's.
TASK_CONTRACT="id status blocked_reason spec_ref doc_ref priority depends_on milestone created completed"
SPEC_CONTRACT="id task_ref status created"

# template_extensions — stdin: a rendered template. Prints the lines of
# its leading front-matter block (the extension fields); nothing when the
# template has no block.
template_extensions() {
  awk 'NR == 1 { if ($0 != "---") exit; next } /^---$/ { exit } { print }'
}

# template_body — stdin: a rendered template. Prints everything after the
# front-matter block (minus one separating blank line), or the whole
# input when there is no block.
template_body() {
  awk '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && /^---$/        { infm = 0; sep = 1; next }
    infm                   { next }
    sep && $0 == ""        { sep = 0; next }
    { sep = 0; print }
  '
}

# validate_extensions <template-file> <ext-lines> <contract-field-list> —
# refuses a template whose front-matter block redefines a contract field
# or writes a line the canonical form (check_front_matter.sh) would
# reject at the merge. Refused here, where the shape is born, so the
# generated file never carries the failure forward.
validate_extensions() {
  local tpl="$1" lines="$2" contract="$3" line key val seen=""
  [[ -n "$lines" ]] || return 0
  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      echo "${tpl}: front-matter extensions must not hold empty lines" >&2; exit 3
    fi
    case "$line" in
      *": "*) key="${line%%: *}"; val="${line#*: }" ;;
      *) echo "${tpl}: extension line is not 'key: value': '$line'" >&2; exit 3 ;;
    esac
    if ! printf '%s' "$key" | grep -qE '^[A-Za-z_][A-Za-z0-9_-]*$'; then
      echo "${tpl}: malformed extension key '$key'" >&2; exit 3
    fi
    case " $contract " in *" $key "*)
      echo "${tpl}: template redefines the contract field '$key' — contract front matter is generated, never templated" >&2
      exit 3 ;;
    esac
    case " $seen " in *" $key "*)
      echo "${tpl}: extension field '$key' appears twice" >&2; exit 3 ;;
    esac
    seen="$seen $key"
    case "$val" in
      \"*|\'*)
        echo "${tpl}: extension '$key' is quoted — values are written bare" >&2; exit 3 ;;
      '>'|'|'|'>-'|'|-')
        echo "${tpl}: extension '$key' uses a block scalar — outside the canonical form" >&2; exit 3 ;;
    esac
    if printf '%s' "$val" | grep -q '[[:space:]]$'; then
      echo "${tpl}: extension '$key' carries trailing whitespace" >&2; exit 3
    fi
  done <<EOF
$lines
EOF
  return 0
}

usage() {
  echo "Usage: new.sh task \"<title>\" [--priority high|medium|low] [--depends-on task-nnn,...] [--doc-ref path#anchor] [--milestone name]" >&2
  echo "       new.sh spec task-nnn \"<title>\"" >&2
  exit 3
}

cmd="${1:-}"
[[ -z "$cmd" ]] && usage

case "$cmd" in
  task)
    shift
    title="${1:-}"
    [[ -z "$title" ]] && usage
    shift
    priority=medium
    depends_on=""
    doc_ref=null
    milestone=null
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --priority) priority="$2"; shift 2 ;;
        --depends-on) depends_on="$2"; shift 2 ;;
        --doc-ref) doc_ref="$2"; shift 2 ;;
        --milestone) milestone="$2"; shift 2 ;;
        *) echo "Unknown flag: $1" >&2; exit 3 ;;
      esac
    done

    case "$priority" in
      high|medium|low) ;;
      *) echo "Invalid --priority '$priority' — expected high, medium, or low" >&2; exit 3 ;;
    esac

    forge_scan
    id="task-$(next_id work/tasks task)"
    slug=$(slugify "$title")
    file="work/tasks/${id}${slug:+-$slug}.md"
    [[ -e "$file" ]] && { echo "$file already exists" >&2; exit 3; }

    if [[ -n "$depends_on" ]]; then
      depends_list="[$(echo "$depends_on" | sed 's/,/, /g')]"
    else
      depends_list="[]"
    fi

    # Resolve and validate the template before writing anything — a
    # refusal must leave no half-written file behind.
    tpl=$(body_template_for task)
    tpl_ext=""
    tpl_body=""
    if [[ -n "$tpl" ]]; then
      rendered=$(render_template "$tpl" "$id" "$title" "")
      tpl_ext=$(printf '%s\n' "$rendered" | template_extensions)
      tpl_body=$(printf '%s\n' "$rendered" | template_body)
      validate_extensions "$tpl" "$tpl_ext" "$TASK_CONTRACT"
    fi

    {
      cat <<EOF
---
id: ${id}
status: pending
blocked_reason: null
spec_ref: []
doc_ref: ${doc_ref}
priority: ${priority}
depends_on: ${depends_list}
milestone: ${milestone}
created: $(date +%Y-%m-%d)
completed: null
EOF
      if [[ -n "$tpl_ext" ]]; then printf '%s\n' "$tpl_ext"; fi
      printf '%s\n\n' "---"
      if [[ -n "$tpl" ]]; then
        printf '%s\n' "$tpl_body"
      else
        cat <<EOF
# ${title}

TODO: what to do, and why it matters. No technical detail — that belongs
in the spec.
EOF
      fi
    } > "$file"
    echo "Created ${file} (${id})"
    mint_report
    ;;

  spec)
    shift
    task_id="${1:-}"
    title="${2:-}"
    [[ -z "$task_id" || -z "$title" ]] && usage

    task_file=$(queue_file work/tasks task "$task_id")
    [[ -n "$task_file" && -f "$task_file" ]] \
      || { echo "No such task: ${task_id} — a spec is never created before its task" >&2; exit 3; }
    # The task's file is the authority on how its id is written — the
    # argument only had to identify it, and `task-1` or a historical
    # `task-001` must still record the reference the queue actually holds.
    task_id=$(sed -n 's/^id: *//p' "$task_file" | head -n1 | sed 's/[[:space:]]*$//')

    forge_scan
    id="spec-$(next_id work/specs spec)"
    slug=$(slugify "$title")
    file="work/specs/${id}${slug:+-$slug}.md"
    [[ -e "$file" ]] && { echo "$file already exists" >&2; exit 3; }

    # Resolve and validate the template before writing anything — a
    # refusal must leave no half-written file behind.
    tpl=$(body_template_for spec)
    tpl_ext=""
    tpl_body=""
    if [[ -n "$tpl" ]]; then
      # A template may reshape everything except the contract: the delta
      # check greps these headings, and the completion flow fills Outcome
      # — a template without them blinds both silently.
      for h in "## Proposed product changes" "## Proposed technical changes" "## Outcome"; do
        if ! grep -qxF "$h" "$tpl"; then
          echo "${tpl} is missing the contract heading: ${h}" >&2
          echo "Add it back — the machinery reads these headings (see the public contract)." >&2
          exit 3
        fi
      done
      rendered=$(render_template "$tpl" "$id" "$title" "$task_id")
      tpl_ext=$(printf '%s\n' "$rendered" | template_extensions)
      tpl_body=$(printf '%s\n' "$rendered" | template_body)
      validate_extensions "$tpl" "$tpl_ext" "$SPEC_CONTRACT"
    fi

    {
      cat <<EOF
---
id: ${id}
task_ref: ${task_id}
status: draft
created: $(date +%Y-%m-%d)
EOF
      if [[ -n "$tpl_ext" ]]; then printf '%s\n' "$tpl_ext"; fi
      printf '%s\n\n' "---"
    } > "$file"
    if [[ -n "$tpl" ]]; then
      printf '%s\n' "$tpl_body" >> "$file"
      skip_default_body=1
    else
      skip_default_body=0
    fi
    [[ "$skip_default_body" -eq 1 ]] || cat >> "$file" <<EOF
# ${id} — ${title}

- **Goal:** TODO

## Scope

TODO

## Steps

1. TODO

## Acceptance criteria (EARS)

- TODO

## Edge cases

- TODO

## Tests required

TODO

## Definition of Done

- [ ] TODO

## Proposed product changes

- none — no behaviour change

## Proposed technical changes

- none — no machinery change

## Outcome

_(fill after execution)_
EOF

    # Append the new spec's id to the task's spec_ref list. Portable
    # single-arg sub() only — no gawk-only 3-arg match (see
    # writrun-check-spec-deltas/check_deltas.sh's own history with this).
    awk -v newid="$id" '
      /^spec_ref: \[/ {
        line = $0
        sub(/^spec_ref: \[/, "", line)
        sub(/\]$/, "", line)
        if (line == "") { print "spec_ref: [" newid "]" }
        else { print "spec_ref: [" line ", " newid "]" }
        next
      }
      { print }
    ' "$task_file" > "${task_file}.tmp" && mv "${task_file}.tmp" "$task_file"

    echo "Created ${file} (${id}), appended to ${task_file}'s spec_ref"
    mint_report
    ;;

  *)
    usage
    ;;
esac
