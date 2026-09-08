#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The project's home is the address; the kit's default answers behind it
# (docs/product/adoption.md#two-homes). Deferring is positional — the
# first line and there only — and an absent file defers too, so a
# project that deleted a stub is answered rather than left with nothing.

R="$REPO_ROOT/.writrun/scripts/stage-1-tasks-and-specs/resolve_doc.sh"

WORK=$(mktemp -d); cd "$WORK"
mkdir -p writrun/conventions .writrun/defaults/conventions
printf 'the kit default\n' > .writrun/defaults/conventions/commits.md
printf 'the kit gates\n'   > .writrun/defaults/gates.md

printf '/// writrun:default\n# Commits\n\nnothing of its own yet.\n' > writrun/conventions/commits.md
check "a marker on the first line defers to the kit" 0 \
  ".writrun/defaults/conventions/commits.md	default" \
  -- bash "$R" writrun/conventions/commits.md --origin

printf 'Our own rules.\n' > writrun/conventions/commits.md
check "content of its own is the project's answer" 0 \
  "writrun/conventions/commits.md	declared" \
  -- bash "$R" writrun/conventions/commits.md --origin

# The marker is positional for the reason the draft marker is: a file
# that documents the marker names it in its prose, and a whole-file
# search would call the documentation a stub.
printf '# Commits\n\nA stub opens with `/// writrun:default`.\n' > writrun/conventions/commits.md
check "the marker below the first line is content, not deferral" 0 \
  "writrun/conventions/commits.md	declared" \
  -- bash "$R" writrun/conventions/commits.md --origin

rm writrun/conventions/commits.md
check "an absent file defers too" 0 \
  ".writrun/defaults/conventions/commits.md	default" \
  -- bash "$R" writrun/conventions/commits.md --origin

check "without --origin it prints the path alone" 0 ".writrun/defaults/gates.md" \
  -- bash "$R" writrun/gates.md
# The origin is a second field, tab-separated — absent without the flag.
refute "and says nothing about which home won" "	" \
  -- bash "$R" writrun/gates.md

# An address nobody can answer is loud: printing nothing would let a
# caller pass by having read no rule at all.
check "an address with no file and no default is loud" 4 "names nothing\|does not exist\|neither" \
  -- bash "$R" writrun/conventions/absent.md

printf '/// writrun:default\n' > writrun/conventions/orphan.md
check "a stub the kit ships no default for is loud" 4 "ships no default" \
  -- bash "$R" writrun/conventions/orphan.md

# The two homes are not interchangeable: a caller handing over a kit
# path has confused them, and guessing would hide that.
check "a kit path is refused, never resolved" 3 "not an address in the project's home" \
  -- bash "$R" .writrun/defaults/gates.md
check "no address at all is a usage error" 3 "usage:" \
  -- bash "$R"

cd "$REPO_ROOT"
finish
