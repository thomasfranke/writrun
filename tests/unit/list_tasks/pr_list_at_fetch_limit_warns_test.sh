#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A PR list that filled the fetch limit may be missing rows, and a
# missing row reports a taken task as free — so hitting the limit is
# said out loud instead of passed off as a complete answer.
setup
task_file task-001 ready ""
mkdir -p "$WORK/stub-bin"
cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
i=1
while [ "$i" -le 200 ]; do
  printf '%s\tunrelated-branch-%s\tsomeone\n' "$i" "$i"
  i=$((i + 1))
done
GH
chmod +x "$WORK/stub-bin/gh"
export PATH="$WORK/stub-bin:$PATH"
check "a PR list at the fetch limit warns" 0 "hit the fetch limit" \
  -- bash "$LIST_TASKS"

finish
