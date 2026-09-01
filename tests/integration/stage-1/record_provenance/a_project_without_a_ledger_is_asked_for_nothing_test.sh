#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The ledger is a declared variant. A project that keeps none records
# nothing and satisfies every check, and an agent step that runs the
# writer unconditionally must come away clean here — otherwise "declaring
# false" would mean "editing your agent's instructions", which is not what
# a declaration is for
# (docs/product/concepts/provenance.md#the-adopter-decides-whether-to-keep-it).
setup
task_file task-001 ready ""

check "with no settings file at all, nothing is written" 0 \
  "keeps no ledger" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent model=claude-opus-5 login=octocat

if grep -qx 'provenance: \[\]' work/tasks/task-001.md; then
  echo "ok    and the empty ledger is untouched"; pass=$((pass + 1))
else
  echo "FAIL  and the empty ledger is untouched"
  sed -n '1,20p' work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

settings_file <<'JSON'
{
  "stage": 1,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
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
check "declaring false is the same answer" 0 "keeps no ledger" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent model=claude-opus-5 login=octocat

check "and the queue is canonical, ledgerless" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# The entry's own contract, checked by the writer as well as by the
# front-matter check: a writer that can emit a file its own checker
# rejects is a writer nobody can run unattended.
ledger_kept
check "an agent's entry must name its model" 1 "names its model" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent login=octocat input=5
check "a person's entry carries no counts" 1 "carries no counts" \
  -- bash "$RECORD_PROVENANCE" task-001 by=human login=octocat input=5
check "a person's entry carries no model" 1 "carries no model" \
  -- bash "$RECORD_PROVENANCE" task-001 by=human model=claude-opus-5 login=octocat
check "a third actor is refused" 1 "names a person or an agent" \
  -- bash "$RECORD_PROVENANCE" task-001 by=robot login=octocat
check "a count is a count" 1 "not a bare non-negative integer" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent model=claude-opus-5 login=octocat input=1.20
check "a key outside the vocabulary is refused" 3 "outside the ledger's vocabulary" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent model=claude-opus-5 login=octocat spend=4
check "and a task that resolves to nothing is named" 1 "resolves to no file" \
  -- bash "$RECORD_PROVENANCE" task-404 by=human login=octocat

finish
