#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `provenance` is the one field in the contract allowed to open a block
# list, and the allowance is narrow on purpose: a dash-opened line per
# entry, each entry a flow mapping written whole on that line. The shape
# that is refused is the one a YAML parser would accept and every reader
# here would miss — an entry opened as a block mapping, its keys on lines
# of their own (docs/technical/README.md#task-schema).

ledger() {   # ledger <field-block> — one task whose provenance is this
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
$1
---

# A task with a ledger
EOF
}

setup

ledger 'provenance:
  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 37266324, cache_write: 366590}
  - {by: human, login: octocat}'
check "the canonical ledger is accepted" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'provenance:
  - by: agent
    model: claude-opus-5
    login: octocat'
check "an entry spread over several lines is refused" 1 \
  "never opened as a block mapping" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'provenance: [{by: human, login: octocat}]'
check "and so is a ledger folded onto the field's own line" 1 \
  "an inline ledger is only ever \[\]" \
  -- bash "$CHECK_FRONT_MATTER"

ledger 'provenance:'
check "a block list with no entries is refused" 1 \
  "opens a block list with no entries" \
  -- bash "$CHECK_FRONT_MATTER"

# The field itself is not optional: a task that omits it is a task whose
# ledger a reader cannot tell from a ledger nobody kept.
cat > work/tasks/task-002.md <<'EOF'
---
id: task-002
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
---

# A task with no ledger field at all
EOF
check "and a task that omits the field is refused" 1 \
  "field 'provenance' must appear exactly once" \
  -- bash "$CHECK_FRONT_MATTER"
rm -f work/tasks/task-002.md

# A spec has no ledger, so the exception does not travel: a block there
# is the fault it always was.
cat > work/specs/spec-001.md <<'EOF'
---
id: spec-001
task_ref: task-001
status: draft
created: 2026-08-23T00:00:00Z
provenance:
  - {by: human, login: octocat}
---

# A spec reaching for a ledger
EOF
ledger 'provenance: []'
check "a spec may not open a block list either" 1 \
  "block forms are outside the contract" \
  -- bash "$CHECK_FRONT_MATTER"

finish
