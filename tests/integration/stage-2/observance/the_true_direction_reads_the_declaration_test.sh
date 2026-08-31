#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `agent_coauthor: true` obliges an artifact with a fixed shape and a
# fixed place, so its absence is visible — which the old definition, a
# deferral to whatever a platform appended, made impossible.
#
# The unit is the pull request, and the amendment to spec-0035 says why:
# nothing here can decide whose commit a commit is. So the body's credit
# line is read as the declaration that an agent worked this, and the
# commits are held to it.
setup

obliging() {
  settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
}

obliging
export PR_TITLE="feat(ci): a change"

# Nothing declares agent work: no commit is judged. A human's pull
# request is asked for nothing, which is the whole reason the unit is not
# "every commit" — absence read as disobedience would fault the people
# who never used an agent.
commit_message "$(printf 'feat(ci): written by a person\n\nNo trailer, and none owed.')"
export PR_BODY="Just a change I made."
check "an undeclared pull request judges no commit" 0 \
  "nothing in the pull request body declares agent work" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The body declares it, and the commit does not carry the trailer: this
# is partial compliance, and it is what the direction exists to catch.
export PR_BODY="$(printf 'A change.\n\n🤖 Generated with Claude Code')"
check "a declared pull request faults an untrailered commit" 1 \
  "carries no Co-Authored-By: trailer while agent_coauthor is true" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# The same declaration, the trailer present and naming a model.
setup
obliging
commit_message "$(printf 'feat(ci): written with an agent\n\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>')"
check "a trailered commit under a declared pull request passes" 0 \
  "agent_coauthor is honoured" -- bash "$CHECK_OBSERVANCE" main...HEAD

# A category is not a model. The record has to survive the next model's
# arrival, and "an AI" answers nothing a quarter later.
setup
obliging
commit_message "$(printf 'feat(ci): written with something\n\nCo-Authored-By: an AI <noreply@example.com>')"
check "a trailer naming a category is refused" 1 \
  "a category rather than a model" -- bash "$CHECK_OBSERVANCE" main...HEAD
check "and the category is named back" 1 "names 'an-ai'" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

setup
obliging
commit_message "$(printf 'feat(ci): a family is not a model\n\nCo-Authored-By: Claude <noreply@anthropic.com>')"
check "a bare family name is a category too" 1 \
  "a category rather than a model" -- bash "$CHECK_OBSERVANCE" main...HEAD

# The machinery's recording commit is not an agent's action, so no
# conduct flag reaches it — in this direction either.
setup
obliging
commit_message "$(printf 'feat(ci): written with an agent\n\nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>')"
bot_commit "$(printf 'chore(queue): record what the merge decided')"
check "the recording commit owes no trailer" 0 "agent_coauthor is honoured" \
  -- bash "$CHECK_OBSERVANCE" main...HEAD

# A value the vocabulary does not hold is check_settings.sh's to name.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "agent_coauthor": yes,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
commit_message "$(printf 'feat(ci): a change\n\nNo trailer.')"
check "a value outside the vocabulary judges nothing here" 0 \
  "which this check does not know" -- bash "$CHECK_OBSERVANCE" main...HEAD

finish
