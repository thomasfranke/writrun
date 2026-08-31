#!/usr/bin/env bash
# check_doc_shapes.sh — the shapes prose *shows* are held to the schema,
# and a retired word cannot stand in an instruction.
#
# Usage: check_doc_shapes.sh [root...]
#   Roots are files or directories, relative to the working directory.
#   Default: docs template .writrun AGENTS.md README.md CONTRIBUTING.md
#
# A schema is enforced where the machinery reads it, and nowhere else. So
# every example a chapter prints is unheld, and examples drift — this
# repository's own concept chapters printed front matter no checker would
# accept, and the adoption kit shipped it that way
# (docs/technical/README.md#front-matter-is-canonical).
#
# Two halves, and neither reads English.
#
#   1. **A fenced `yaml` block is read the way a queue file is.** One that
#      opens with `---` is a whole front matter: it is written into a
#      scratch queue and `check_front_matter.sh` — the same script that
#      reads the real files, not a second implementation of its rules —
#      is run over it. One that does not open with `---` is a fragment,
#      and its outermost keys must be schema fields; it is *named* as a
#      fragment in the output, because a block silently skipped is the
#      blindness this check exists to end.
#
#   2. **A retired word is refused where it instructs.** The vocabulary
#      is tests/retired_vocabulary.txt, one line per word. The match is on
#      the **backticked** form, so ordinary English survives: "what is
#      pending" is prose, `pending` is the status this project stopped
#      having. Exempt: docs/technical/decisions/, which is append-only
#      history — a record has to be able to name what it retired.
#
# **Two display conventions the check understands.** An annotation after
# a value (` # what this field is`) is stripped before the block is read:
# the schema chapters annotate every field, and the annotation is not
# part of the shape being taught. And a block that is deliberately not
# canonical — a chapter showing what the checker refuses, or a shape that
# is history — is fenced as ```text rather than ```yaml. **The language
# tag is the declaration of intent**, which is the only escape, so an
# escape is always visible in the diff.
#
# Exit codes: 0 every shape holds; 1 one does not, with each named; 3
# usage error.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CHECK_FM="${CHECK_FRONT_MATTER:-.writrun/skills/writrun-check-front-matter/check_front_matter.sh}"
[ -f "$CHECK_FM" ] || CHECK_FM="$HERE/../../skills/writrun-check-front-matter/check_front_matter.sh"
VOCAB="${RETIRED_VOCABULARY:-tests/retired_vocabulary.txt}"

if [ "$#" -gt 0 ]; then
  ROOTS="$*"
else
  ROOTS="docs template .writrun AGENTS.md README.md CONTRIBUTING.md"
fi

faults=0
blocks=0
fragments=0
skipped=0
fault() { echo "REJECTED: $*" >&2; faults=$((faults + 1)); }

# Every field either schema documents. A fragment's outermost keys are
# read against this; the whole-front-matter half never needs it, because
# the real checker knows its own fields.
SCHEMA_FIELDS="id task_ref status blocked_reason taken_by spec_ref doc_ref \
origin priority depends_on milestone created queued completed merged provenance"

in_list() {   # in_list <needle> <haystack...>
  local n="$1"; shift
  case " $* " in *" $n "*) return 0 ;; esac
  return 1
}

# The files: every .md under the roots. A root that is itself a file is
# taken as given, so the root list can name AGENTS.md without naming the
# directory it sits in.
files() {
  local r
  for r in $ROOTS; do
    if [ -f "$r" ]; then
      case "$r" in *.md) printf '%s\n' "$r" ;; esac
    elif [ -d "$r" ]; then
      find "$r" -name '*.md' -type f | sort
    fi
  done
}

# ---------------------------------------------------- the shown shapes

# blocks_of <file> — for each ```yaml block: a `@@ <startline>` marker,
# then the block's lines with the trailing annotation stripped. The
# annotation is ` #` — a space and a hash — never a bare `#`, so
# `doc_ref: product/concepts/task.md#two-invariants` keeps its anchor.
blocks_of() {
  awk '
    /^[[:space:]]*```yaml[[:space:]]*$/ { inb = 1; print "@@ " NR; next }
    inb && /^[[:space:]]*```[[:space:]]*$/ { inb = 0; next }
    inb {
      line = $0
      sub(/[[:space:]]+#[[:space:]].*$/, "", line)
      sub(/[[:space:]]+$/, "", line)
      print "|" line
    }
  ' "$1"
}

check_whole() {   # check_whole <file> <line> <block-file>
  local f="$1" ln="$2" body="$3" id dir ref target out
  id=$(sed -n 's/^id: *//p' "$body" | head -n1)
  case "$id" in
    task-[0-9]*) dir=tasks ;;
    spec-[0-9]*) dir=specs ;;
    *) fault "${f}:${ln}: the block opens as front matter but its id is '${id}' — a shown shape carries a real id, or it is fenced as \`\`\`text"; return 0 ;;
  esac

  local scratch; scratch=$(mktemp -d)
  mkdir -p "$scratch/work/tasks" "$scratch/work/specs" "$scratch/docs"
  # The name carries the line, so two examples in one document never
  # collide; the checker holds a file's id against its name, and
  # `<id>-<subject>` is canonical, so `<id>-l56` is a legal subject.
  cp "$body" "$scratch/work/${dir}/${id}-l${ln}.md"

  # **The reference is materialised, not exempted.** A teaching example
  # points into an imaginary project, and the checker resolves doc_ref
  # against a docs directory it takes as an argument — which is what that
  # argument is for. Every other field is held exactly as a real file's.
  ref=$(sed -n 's/^doc_ref: *//p' "$body" | head -n1)
  case "$ref" in
    ""|null|docs/*) ;;
    *.md|*.md\#*)
      target="$scratch/docs/${ref%%#*}"
      mkdir -p "$(dirname "$target")"
      : > "$target"
      ;;
  esac

  if ! out=$(bash "$CHECK_FM" "$scratch/work/tasks" "$scratch/work/specs" "$scratch/docs" 2>&1); then
    printf '%s\n' "$out" \
      | sed "s|MALFORMED: ${scratch}/work/${dir}/${id}-l${ln}.md: |REJECTED: ${f}:${ln}: the shown ${id} |" >&2
    faults=$((faults + 1))
  fi
  rm -rf "$scratch"
}

check_fragment() {   # check_fragment <file> <line> <block-file>
  local f="$1" ln="$2" body="$3" first key
  first=$(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\):.*/\1/p' "$body" | head -n1)
  if [ -z "$first" ] || ! in_list "$first" $SCHEMA_FIELDS; then
    # Not front matter at all — a settings example, a workflow snippet.
    # Counted rather than ignored: the count is what says the check
    # looked.
    skipped=$((skipped + 1))
    return 0
  fi
  fragments=$((fragments + 1))
  echo "  ${f}:${ln}: read as a front-matter fragment — keys only, no file around them"
  for key in $(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\):.*/\1/p' "$body"); do
    in_list "$key" $SCHEMA_FIELDS \
      || fault "${f}:${ln}: the fragment carries '${key}', which neither schema documents"
  done
}

for f in $(files); do
  grep -q '```yaml' "$f" || continue
  cur=""; ln=0
  tmp=$(mktemp)
  : > "$tmp"
  while IFS= read -r line; do
    case "$line" in
      "@@ "*)
        if [ -n "$cur" ]; then
          blocks=$((blocks + 1))
          if [ "$(head -n1 "$tmp")" = "---" ]; then
            check_whole "$f" "$cur" "$tmp"
          else
            check_fragment "$f" "$cur" "$tmp"
          fi
        fi
        cur="${line#@@ }"; : > "$tmp" ;;
      "|"*) printf '%s\n' "${line#|}" >> "$tmp" ;;
    esac
  done <<EOF
$(blocks_of "$f")
EOF
  if [ -n "$cur" ]; then
    blocks=$((blocks + 1))
    if [ "$(head -n1 "$tmp")" = "---" ]; then
      check_whole "$f" "$cur" "$tmp"
    else
      check_fragment "$f" "$cur" "$tmp"
    fi
  fi
  rm -f "$tmp"
done

# ------------------------------------------------------- retired words

if [ -f "$VOCAB" ]; then
  while IFS= read -r entry; do
    case "$entry" in ""|\#*) continue ;; esac
    word=$(printf '%s' "$entry" | awk '{print $1}')
    into=$(printf '%s' "$entry" | awk '{print $2}')
    [ -n "$word" ] && [ -n "$into" ] || continue
    for f in $(files); do
      case "$f" in docs/technical/decisions/*) continue ;; esac
      hits=$(grep -n -- "\`${word}\`" "$f" || true)
      [ -n "$hits" ] || continue
      printf '%s\n' "$hits" | while IFS= read -r hit; do
        echo "REJECTED: ${f}:${hit%%:*}: \`${word}\` was retired — say \`${into}\`; a record may name it, an instruction may not" >&2
      done
      faults=$((faults + 1))
    done
  done < "$VOCAB"
fi

if [ "$faults" -ne 0 ]; then
  echo "" >&2
  echo "A shape a chapter shows is documentation that lies with a straight" >&2
  echo "face: it is copied, and the first check refuses what it taught" >&2
  echo "(docs/technical/README.md#front-matter-is-canonical)." >&2
  exit 1
fi

echo "OK — ${blocks} shown shape(s): $((blocks - fragments - skipped)) whole, ${fragments} fragment(s), ${skipped} not front matter."
