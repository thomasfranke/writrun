#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `agent_coauthor: false` says everything the agent writes into git and the
# forge carries the change alone. That write is visible afterwards, so it
# is checked rather than trusted — and under `true` there is nothing to
# check, because the adopter allowed it.
setup

forbidding() {
  settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "agent_coauthor": false,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
}

allowing() {
  settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
}

forbidding
commit_message "$(printf 'feat(ci): a clean message\n\nNo trailer here.')"

export PR_TITLE="feat(ci): a clean message"
check "a clean range under agent_coauthor false passes" 0 "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

commit_message "$(printf 'feat(ci): a message that signs itself\n\nCo-Authored-By: Some Agent <noreply@example.com>')"
check "a co-author trailer is flagged, and the line is named" 1 \
  "carries platform credit while agent_coauthor is false" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
check "and the offending line is printed" 1 "Co-Authored-By: Some Agent" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The same range, the flag flipped: the credit the `false` direction
# forbids is the artifact `true` obliges, so the same commits pass.
#
# The `true` direction's own check — every commit trailered once the body
# declares agent work — is not here yet: spec-0035's step 3 assumed a
# committer identity that does not exist, and the amendment that replaces
# it is under review. This case holds the half that is implemented.
allowing
commit_all
check "under agent_coauthor true the same range is not faulted" 0 \
  "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# A session trailer and a generated-with line are the same write in two
# other spellings.
setup
forbidding
commit_message "$(printf 'feat(ci): a message with a session link\n\nClaude-Session: https://claude.ai/code/session_0123')"
export PR_TITLE="feat(ci): a message with a session link"
check "a session trailer is flagged" 1 \
  "carries platform credit while agent_coauthor is false" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

setup
forbidding
commit_message "$(printf 'feat(ci): a message with a generated-with line\n\n🤖 Generated with an agent platform')"
export PR_TITLE="feat(ci): a message with a generated-with line"
check "a generated-with line is flagged" 1 \
  "carries platform credit while agent_coauthor is false" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The body is the other half: half-covering — a clean commit under an
# advertising pull request — would strip the record and keep the
# billboard (decision 0054).
setup
forbidding
commit_message "feat(ci): a clean message"
export PR_TITLE="feat(ci): a clean message"
PR_BODY="$(printf 'What\n\nSomething.\n\n🤖 Generated with an agent platform')" \
check "the pull request body is read too" 1 \
  "the pull request body carries platform credit" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD
PR_BODY="$(printf 'What\n\nRemove the Co-Authored-By trailer from the release commit.')" \
check "a subject mentioning a trailer is prose, not a trailer" 0 \
  "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The machinery's own recording commit is not an agent's action, so no
# conduct flag reaches it — and it is skipped by identity, never by a
# subject a message could imitate.
setup
forbidding
commit_message "feat(ci): a clean message"
bot_commit "$(printf 'chore(queue): record what the merge decided\n\nCo-Authored-By: github-actions <noreply@github.com>')"
export PR_TITLE="feat(ci): a clean message"
check "the recording commit is never judged" 0 "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The range arrives written for `git diff`, where `A...B` is "B since
# the merge base". Read as a log range the same three dots mean the
# symmetric difference, which would judge whatever the base gained since
# the branch point — another pull request's commits, blamed on this one.
setup
forbidding
commit_message "feat(ci): a clean message"
git checkout -q main
commit_message "$(printf 'chore(ci): work that landed in another pull request\n\nCo-Authored-By: Some Agent <noreply@example.com>')"
git checkout -q feature
export PR_TITLE="feat(ci): a clean message"
check "a commit the base gained since the branch point is not judged" 0 \
  "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

finish
