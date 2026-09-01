#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Two actors, and neither is the default: an entry names a person or an
# agent, an agent's entry names the specific model, and a person's entry
# carries neither model nor counts — which is a complete record and not a
# missing one (docs/product/concepts/provenance.md#two-actors-and-neither-is-the-default).

ledger() {
  cat > work/tasks/task-001.md <<EOF
---
id: task-001
status: backlog
blocked_reason: null
taken_by: null
spec_ref: []
doc_ref: null
origin: rule
priority: medium
depends_on: []
milestone: null
created: 2026-08-23T00:00:00Z
queued: null
completed: null
merged: null
provenance:
  - {$1}
---

# A task with one entry
EOF
}

setup

ledger 'by: human, login: octocat'
check "a person's entry needs no model and no counts" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: agent, model: claude-opus-5, login: octocat'
check "an agent's entry without counts is canonical too" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: agent, login: octocat, input: 5'
check "an agent's entry without a model is refused" 1 \
  "agent entry names no model" \
  -- bash "$CHECK_FRONT_MATTER"

# A category is not a model. `model: ai` satisfies every shape check and
# answers nothing a quarter later, which is the one question the field
# exists for — the same refusal check_observance.sh makes of the trailer.
ledger 'by: agent, model: ai, login: octocat'
check "and neither is a category a model" 1 "is a category, not a model id" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: human, model: claude-opus-5, login: octocat'
check "a person's entry carrying a model is refused" 1 \
  "human entry carries model" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: human, login: octocat, input: 562, output: 175853'
check "and so is a person's entry carrying counts" 1 \
  "human entry carries counts" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: robot, login: octocat'
check "a third actor is refused" 1 "names a person or an agent and nothing else" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'model: claude-opus-5, login: octocat'
check "an entry naming no actor is refused" 1 "entry names no actor" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: agent, model: claude-opus-5'
check "an entry naming nobody accountable is refused" 1 "carries no login" \
  -- bash "$CHECK_FRONT_MATTER"

# Counts are the platform's own numbers, kept as counts: a converted sum
# would quietly become false the next time a price changed.
ledger 'by: agent, model: claude-opus-5, login: octocat, input: 1.20'
check "a count that is not a count is refused" 1 \
  "never a converted sum" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'by: agent, model: claude-opus-5, login: octocat, spend: 4'
check "and a key outside the ledger's vocabulary is refused" 1 \
  "which the ledger's vocabulary does not have" \
  -- bash "$CHECK_FRONT_MATTER"

finish
