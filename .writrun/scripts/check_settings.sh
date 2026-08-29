#!/usr/bin/env bash
# check_settings.sh — .writrun/conventions/settings.json holds the shape a
# line-based reader can see, and only the choices Adoption leaves open.
#
# Usage: check_settings.sh
#   Run from the repository root; the path is relative to it.
#
# JSON permits nesting, arrays and free-form whitespace. read_setting.sh
# sees none of that and would misread it in silence, so the file is
# restricted to what such a reader can see — a flat object, one
# `"key": value` per line, two-space indent, values `true`, `false`, or a
# double-quoted string — and this is what enforces the restriction
# (docs/technical/README.md#the-shape-is-a-checked-contract).
#
# **Strictness is scoped to where the risk is.** `level` is parsed by the
# workflows, so its shape and its value are both checked. `pr_title_style`
# is read by agents only, and an agent reads JSON the way it reads prose,
# so only its value is.
#
# **An absent file passes.** The reader documents its defaults and keeps
# working without one; a check that failed here would make the file
# mandatory, which the schema does not.
#
# Exit codes: 0 the file is honest; 1 it is not, with every fault named;
# 3 usage error.
#
# Portable bash 3.2, POSIX awk/sed. See the standing rule in
# docs/technical/decisions/.

set -euo pipefail

SETTINGS=".writrun/conventions/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo "No ${SETTINGS} — the documented defaults apply."
  exit 0
fi

faults=0
fault() { echo "REJECTED: $*" >&2; faults=$((faults + 1)); }

# The vocabularies, as the schema spells them.
LEVELS="tasks-and-specs pull-requests github-issues"
TITLE_STYLES="conventional bracketed"

# A key that would switch off something Adoption lists as core is refused,
# not discouraged (product/adoption.md#mandatory-core-vs-documented-variant).
# Matched as substrings of the key name, because the shapes such a key
# could take are not enumerable.
#
# **This is a tripwire, not a proof.** A key named to evade it evades it;
# what this catches is the honest attempt — someone reaching for a switch
# the methodology does not offer, told where the rule is instead of
# discovering at review that their file was ignored.
CORE_STEMS="audience permanent ephemeral technical_detail proposed_changes identity human_gate gates"

lineno=0
keys=""
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))

  if [ "$lineno" -eq 1 ]; then
    [ "$line" = "{" ] || fault "line 1 is '${line}' — the file opens with a bare '{'"
    continue
  fi

  # A trailing blank line is the file's newline, not a line.
  [ -n "$line" ] || continue

  if [ "$line" = "}" ]; then
    closed=$lineno
    continue
  fi

  if [ -n "${closed:-}" ]; then
    fault "line ${lineno} follows the closing '}' — the object is flat and ends once"
    continue
  fi

  # One `"key": value` per line, two-space indent, and nothing else on it.
  if ! printf '%s' "$line" \
    | grep -qE '^  "[A-Za-z_][A-Za-z0-9_]*": (true|false|"[^"]*")(,?)$'; then
    fault "line ${lineno} is not one canonical '\"key\": value' pair: ${line}"
    continue
  fi

  key=$(printf '%s' "$line" | sed -E 's/^  "([^"]*)".*/\1/')
  val=$(printf '%s' "$line" | sed -E 's/^  "[^"]*": (.*)$/\1/')
  val=${val%,}
  case "$val" in \"*\") val=${val#\"}; val=${val%\"} ;; esac

  case " $keys " in *" $key "*) fault "'${key}' appears more than once" ;; esac
  keys="$keys $key"

  for stem in $CORE_STEMS; do
    case "$key" in
      *"$stem"*)
        fault "'${key}' names a rule Adoption lists as core — those are not settable (product/adoption.md#mandatory-core-vs-documented-variant)" ;;
    esac
  done

  case "$key" in
    level)
      case " $LEVELS " in
        *" $val "*) ;;
        *) fault "level '${val}' is outside its vocabulary: ${LEVELS}" ;;
      esac ;;
    pr_title_style)
      case " $TITLE_STYLES " in
        *" $val "*) ;;
        *) fault "pr_title_style '${val}' is outside its vocabulary: ${TITLE_STYLES}" ;;
      esac ;;
  esac
done < "$SETTINGS"

[ -n "${closed:-}" ] || fault "the object never closes — the file ends without a bare '}'"

# The last pair before the '}' carries no comma; anything else is invalid
# JSON, and a reader that tolerated it would be reading something no other
# tool agrees is a settings file.
last_pair=$(grep -n '^  "' "$SETTINGS" | tail -n1 | cut -d: -f1)
if [ -n "$last_pair" ]; then
  if sed -n "${last_pair}p" "$SETTINGS" | grep -q ',$'; then
    fault "line ${last_pair} is the last pair and ends with a comma — invalid JSON"
  fi
fi

# Every documented key is present, always — the same reason front matter
# carries null fields rather than omitting them: a reader sees the whole
# configuration without knowing the defaults.
for want in level pr_title_style; do
  case " $keys " in
    *" $want "*) ;;
    *) fault "'${want}' is missing — every documented key is present, always" ;;
  esac
done

if [ "$faults" -gt 0 ]; then
  echo "" >&2
  echo "The shape is a checked contract because read_setting.sh reads it" >&2
  echo "line by line and would misread anything else in silence" >&2
  echo "(docs/technical/README.md#the-shape-is-a-checked-contract)." >&2
  exit 1
fi

echo "OK — ${SETTINGS} is canonical: level=$(bash .writrun/scripts/read_setting.sh level), pr_title_style=$(bash .writrun/scripts/read_setting.sh pr_title_style)"
