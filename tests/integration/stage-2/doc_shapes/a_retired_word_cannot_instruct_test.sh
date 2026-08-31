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

# **The same records, under a root spelled three ways.** `find docs`
# prints `docs/...`, `find ./docs` prints `./docs/...`, and an absolute
# root prints an absolute path — one directory, three spellings, and a
# literal prefix glob knows only one of them. The failure it caused was
# the worst-shaped kind: green in CI, which passes the defaults, and red
# for the developer who typed `./docs` by hand, on the very files whose
# purpose is to name what was retired.
check "and still may under a dot-slash root" 0 "0 shown shape" \
  -- bash "$SHAPES" kit ./docs
check "and under an absolute one" 0 "0 shown shape" \
  -- bash "$SHAPES" kit "$PWD/docs"

# Every word in the vocabulary is read, not just the first.
printf '# Kit\n\nDeclare `level` in the settings file.\n' > kit/AGENTS.md
check "the second entry is read too" 1 'say `stage`' -- bash "$SHAPES" kit

# **One fault per offence, not per file.** The rejections are printed one
# to the line, and a count that moved by one behind three of them would
# report the file rather than the offences — the exit code is right
# either way, which is exactly why nothing would have shown it.
printf '# Kit\n\n`pending` one\n\n`pending` two\n\n`pending` three\n' \
  > kit/AGENTS.md
hits=$(bash "$SHAPES" kit 2>&1 >/dev/null | grep -c 'was retired' || true)
if [ "$hits" = "3" ]; then
  echo "ok    three offences in one file are three rejections"
  pass=$((pass + 1))
else
  echo "FAIL  three offences in one file are three rejections (got ${hits})"
  fail=$((fail + 1))
fi

# **The vocabulary is words, so the match is literal.** The file is
# documented as one word to the line; read as a regular expression, an
# entry carrying a `.` matches what it never named, and nothing in the
# output says which of the two happened.
cat > vocab.txt <<'EOF'
p.nding ready a regex metacharacter is not a word
EOF
printf '# Kit\n\nA task is available when it is `pending`.\n' > kit/AGENTS.md
check "a dot in an entry is a dot, not any character" 0 "0 shown shape" \
  -- bash "$SHAPES" kit

# **Not there is not empty.** The half that reads no vocabulary says so;
# answering "clean" for having read nothing is the blindness this check
# exists to end, and it is the shape the file had while it lived outside
# the mirrored tree — shipped to every adopter as a silent no-op.
check "an absent vocabulary is said, not assumed empty" 0 \
  "no vocabulary at" -- env RETIRED_VOCABULARY=nowhere.txt bash "$SHAPES" kit
check "and the summary counts what it read" 0 "0 retired word(s) read" \
  -- env RETIRED_VOCABULARY=nowhere.txt bash "$SHAPES" kit

# The seeded file is the single source, and a deletion from it should be
# a deliberate act rather than a silent one. It lives beside the script
# that reads it, inside the mirrored tree — a script shipped to an adopter
# without its data file is a check that passes by knowing nothing.
unset RETIRED_VOCABULARY
for root in "$REPO_ROOT" "$REPO_ROOT/template"; do
  v="$root/.writrun/scripts/stage-2-pull-requests/retired_vocabulary.txt"
  if [ -f "$v" ] && grep -q '^pending ready' "$v" && grep -q '^level stage' "$v"; then
    echo "ok    ${v#$REPO_ROOT/} carries both seeded words"
    pass=$((pass + 1))
  else
    echo "FAIL  ${v#$REPO_ROOT/} carries both seeded words"
    fail=$((fail + 1))
  fi
done

finish
