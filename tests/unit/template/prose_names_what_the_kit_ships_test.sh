#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The kit's prose is hand-maintained and drifts from what the kit ships.
# check_doc_shapes.sh reads that prose for retired words and wrong
# shapes, and it cannot read for absence: a concept the prose never
# mentions uses no retired word and shows no wrong shape. Silence has no
# signature — so the guard is built from the side that does have one,
# comparing what the kit **ships** against what its prose **names**.
#
# report-0012 is why: `work/reports/` and a fifth skill both shipped
# while three files went on describing four skills and a queue of two
# folders.

# unnamed <dir-of-directories> <file-that-should-name-them...>
#
# Prints the basenames no listed file mentions — and says so when the
# parent itself is missing or empty, because a guard that reads nothing
# reports nothing and a caller checking for empty output would call that
# a pass. A renamed tree is the failure this test exists for, not a
# reason for it to fall silent.
unnamed() {
  local parent="$1"; shift
  local dir name esc found f count=0

  [ -d "$parent" ] || { printf '!no-such-directory:%s ' "$parent"; return; }

  for dir in "$parent"/*/; do
    [ -d "$dir" ] || continue
    count=$((count + 1))
    name=$(basename "$dir")
    # Matched on a word boundary, not as a substring: `report/` must not
    # be satisfied by prose that says `reports/`, and a skill must not be
    # satisfied by prose naming a longer sibling.
    esc=$(printf '%s' "$name" | sed 's/[].[*^$\\+?(){}|]/\\&/g')
    found=false
    for f in "$@"; do
      [ -f "$f" ] || continue
      grep -qE "(^|[^A-Za-z0-9_-])${esc}([^A-Za-z0-9_-]|$)" "$f" \
        && { found=true; break; }
    done
    [ "$found" = true ] || printf '%s ' "$name"
  done

  [ "$count" -gt 0 ] || printf '!no-directories-under:%s ' "$parent"
}

out=$(unnamed "$REPO_ROOT/template/work" "$REPO_ROOT/template/work/README.md")
if [ -z "$out" ]; then
  echo "ok    every directory the kit ships under work/ is named in its README"; pass=$((pass + 1))
else
  echo "FAIL  every directory the kit ships under work/ is named in its README"
  echo "      unnamed: $out"
  fail=$((fail + 1))
fi

# Both sides of this comparison are the kit's: the skills it ships,
# against the two files an adopter reads them in once the copy is theirs.
out=$(unnamed "$REPO_ROOT/template/.writrun/skills" \
      "$REPO_ROOT/template/.writrun/README.md" "$REPO_ROOT/template/.writrun/AGENTS.md")
if [ -z "$out" ]; then
  echo "ok    every skill the kit ships is named where an adopter reads"; pass=$((pass + 1))
else
  echo "FAIL  every skill the kit ships is named where an adopter reads"
  echo "      unnamed: $out"
  fail=$((fail + 1))
fi

# The guard bites: a kit that ships a folder its README never names is
# what this case exists to fail on, and a case that cannot fail is not a
# guard.
scratch=$(mktemp -d)
mkdir -p "$scratch/work/shipped-and-unnamed" "$scratch/work/named"
printf '# work\n\nHolds `named/` and nothing else worth saying.\n' > "$scratch/work/README.md"
out=$(unnamed "$scratch/work" "$scratch/work/README.md")
if [ "$out" = "shipped-and-unnamed " ]; then
  echo "ok    a shipped folder the prose never names is reported by name"; pass=$((pass + 1))
else
  echo "FAIL  a shipped folder the prose never names is reported by name"
  echo "      got: '$out'"
  fail=$((fail + 1))
fi

# A near-miss is a miss: prose naming `reports/` does not account for a
# folder called `report/`, and a substring match would have called it one.
mkdir -p "$scratch/near/report"
printf '# work\n\nThe `reports/` folder holds what was observed.\n' > "$scratch/near/README.md"
out=$(unnamed "$scratch/near" "$scratch/near/README.md")
if [ "$out" = "report " ]; then
  echo "ok    prose naming a longer word does not account for the folder"; pass=$((pass + 1))
else
  echo "FAIL  prose naming a longer word does not account for the folder"
  echo "      got: '$out'"
  fail=$((fail + 1))
fi

# A tree that moved out from under the test is the drift the test exists
# for, so it fails loudly rather than passing on having read nothing.
out=$(unnamed "$scratch/renamed-away" "$scratch/work/README.md")
case "$out" in
  '!no-such-directory:'*)
    echo "ok    a directory the test can no longer find is reported, not shrugged at"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  a directory the test can no longer find is reported, not shrugged at"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

mkdir -p "$scratch/hollow"
out=$(unnamed "$scratch/hollow" "$scratch/work/README.md")
rm -rf "$scratch"
case "$out" in
  '!no-directories-under:'*)
    echo "ok    a parent that ships nothing is reported, not read as agreement"; pass=$((pass + 1)) ;;
  *)
    echo "FAIL  a parent that ships nothing is reported, not read as agreement"
    echo "      got: '$out'"
    fail=$((fail + 1)) ;;
esac

finish
