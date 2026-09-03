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
# Prints the basenames no listed file mentions.
unnamed() {
  local parent="$1"; shift
  local dir name found f
  for dir in "$parent"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    found=false
    for f in "$@"; do
      [ -f "$f" ] || continue
      grep -q "$name" "$f" && { found=true; break; }
    done
    [ "$found" = true ] || printf '%s ' "$name"
  done
}

out=$(unnamed "$REPO_ROOT/template/work" "$REPO_ROOT/template/work/README.md")
if [ -z "$out" ]; then
  echo "ok    every directory the kit ships under work/ is named in its README"; pass=$((pass + 1))
else
  echo "FAIL  every directory the kit ships under work/ is named in its README"
  echo "      unnamed: $out"
  fail=$((fail + 1))
fi

out=$(unnamed "$REPO_ROOT/template/.writrun/skills" \
      "$REPO_ROOT/.writrun/README.md" "$REPO_ROOT/template/AGENTS.md")
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
rm -rf "$scratch"
if [ "$out" = "shipped-and-unnamed " ]; then
  echo "ok    a shipped folder the prose never names is reported by name"; pass=$((pass + 1))
else
  echo "FAIL  a shipped folder the prose never names is reported by name"
  echo "      got: '$out'"
  fail=$((fail + 1))
fi

finish
