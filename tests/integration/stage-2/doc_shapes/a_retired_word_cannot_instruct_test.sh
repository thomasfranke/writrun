#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A word this project retired keeps standing wherever nothing reads it —
# the adoption kit shipped `pending` long after the vocabulary dropped it.
# The rule is about position, not the word: a record may name what it
# retired, an instruction may not.
SHAPES="$CI_SCRIPTS/stage-2-pull-requests/check_doc_shapes.sh"
export CHECK_FRONT_MATTER="$CHECK_FRONT_MATTER"

setup
mkdir -p kit docs/technical/decisions
cat > vocab.txt <<'EOF'
# word replacement why
pending ready spec-0018 renamed the queue statuses
level stage spec-0018 renamed the settings key
EOF
export RETIRED_VOCABULARY=vocab.txt

printf '# Kit\n\nA task is available when it is `pending`.\n' > kit/AGENTS.md
check "a retired word in an instruction fails, naming its replacement" 1 \
  'say `ready`' -- bash "$SHAPES" kit

printf '# Kit\n\nA task is available when it is `ready`.\n' > kit/AGENTS.md
check "and the replacement passes" 0 "0 shown shape" -- bash "$SHAPES" kit

# The same word, unbackticked: ordinary English, and the kit's own work/
# chapter opens with "what is pending, never what is permanent".
printf '# Kit\n\nThe ephemeral half: what is pending, never what is permanent.\n' \
  > kit/AGENTS.md
check "the plain English word is not the status" 0 "0 shown shape" \
  -- bash "$SHAPES" kit

# History has to be able to name what it retired, or a decision record
# cannot say what it decided.
printf '# Kit\n\nA task is available when it is `ready`.\n' > kit/AGENTS.md
printf '# selection resumes `in-progress` before picking `pending`.\n' \
  > docs/technical/decisions/0002-selection.md
check "a decision record may name the retired word" 0 "0 shown shape" \
  -- bash "$SHAPES" kit docs

# Every word in the vocabulary is read, not just the first.
printf '# Kit\n\nDeclare `level` in the settings file.\n' > kit/AGENTS.md
check "the second entry is read too" 1 'say `stage`' -- bash "$SHAPES" kit

# The seeded file is the single source, and a deletion from it should be
# a deliberate act rather than a silent one.
unset RETIRED_VOCABULARY
if grep -q '^pending ready' "$REPO_ROOT/tests/retired_vocabulary.txt" \
  && grep -q '^level stage' "$REPO_ROOT/tests/retired_vocabulary.txt"; then
  echo "ok    the shipped vocabulary still carries both seeded words"
  pass=$((pass + 1))
else
  echo "FAIL  the shipped vocabulary still carries both seeded words"
  fail=$((fail + 1))
fi

finish
