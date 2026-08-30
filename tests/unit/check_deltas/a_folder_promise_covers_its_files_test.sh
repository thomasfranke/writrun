#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A promise ending in `/` names a folder — the shape a rename or a
# chapter-wide sweep is promised in. It is honoured when the diff
# touches anything under it, and it declares everything under it.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved "product/renamed-chapter/"
commit_all
mkdir -p docs/product/renamed-chapter
printf '# Moved\n' > docs/product/renamed-chapter/one.md
printf '# Moved too\n' > docs/product/renamed-chapter/two.md
commit_all
check "a folder promise covers the files under it" 0 "OK" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

# Untouched, the folder promise is missing like any other.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved "product/renamed-chapter/"
commit_all
printf 'code only\n' > code.txt
commit_all
check "an untouched folder promise is missing" 1 "promised change under" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

# And it declares nothing outside itself.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved "product/renamed-chapter/"
commit_all
mkdir -p docs/product/renamed-chapter
printf '# Moved\n' > docs/product/renamed-chapter/one.md
printf 'stray edit\n' >> docs/product/chapter.md
commit_all
out=$(bash "$CHECK_DELTAS" spec-001 main...HEAD 2>&1); rc=$?
if [ "$rc" = "2" ] && printf '%s' "$out" | grep -q "UNDECLARED: 'docs/product/chapter.md'"; then
  echo "ok    a stray outside the folder is still undeclared"; pass=$((pass+1))
else
  echo "FAIL  a stray outside the folder is still undeclared"; printf '%s\n' "$out" | sed 's/^/      | /'; fail=$((fail+1))
fi

finish
