#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

PUSH="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/push_recording.sh"

# A refusal that is not a race: origin refuses the push and lands
# nothing — a protected branch, a revoked token, a required check, all
# of which leave the tip exactly where the refusal found it. The next
# attempt's fetch sees an unmoved branch and the run fails there,
# spending none of the remaining attempts. No stderr is read to reach
# that verdict: movement is the one fact git and the forge word the
# same way across versions.
setup_intake
spy_git

cat > "$WORK/origin.git/hooks/pre-receive" <<'HOOK'
#!/usr/bin/env bash
echo "refused by the ruleset" >&2
exit 1
HOOK
chmod +x "$WORK/origin.git/hooks/pre-receive"

recording_commit work/tasks/task-0001.md "status: in-review"

check "a refusal over an unmoved branch fails at once" 1 \
  "main is unmoved" \
  -- spied bash "$PUSH" main

git_told_times "one push, and none of the remaining attempts spent" 1 "push "

refute "and the recording is nowhere on the branch" "task-0001.md" \
  -- authority ls-tree -r --name-only main

finish
