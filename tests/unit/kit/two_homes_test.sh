#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The two homes rule (docs/product/adoption.md#two-homes): every file is
# exactly one side's. .writrun/ is the kit's whole — an update replaces
# it entire — and the adopter's answers live in writrun/, which no
# update touches. This guard is what fails when an adopter file creeps
# back into the kit's folder, in the root or in the kit it ships.

for root in "$REPO_ROOT" "$REPO_ROOT/template"; do
  side=${root#"$REPO_ROOT"}; side=${side:-.}
  for f in settings.json gates.md conventions; do
    if [ -e "$root/.writrun/$f" ]; then
      echo "FAIL  $side: .writrun/$f is an adopter file in the kit's home — it lives in writrun/"
      fail=$((fail + 1))
    else
      echo "ok    $side: .writrun/ holds no $f"
      pass=$((pass + 1))
    fi
    if [ -e "$root/writrun/$f" ]; then
      echo "ok    $side: writrun/$f is where the adopter's file lives"
      pass=$((pass + 1))
    else
      echo "FAIL  $side: writrun/$f is missing from the project's home"
      fail=$((fail + 1))
    fi
  done
done

finish
