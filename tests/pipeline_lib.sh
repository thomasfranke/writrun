#!/usr/bin/env bash
# pipeline_lib.sh — the fixture behind every case that exercises the
# pipeline's scripts: the four skills (unit tier) and the workflow step
# logic in .writrun/scripts (integration tier).
#
# A case file sources this and then runs standalone:
#
#   bash tests/unit/check_state/born_implemented_rejected_test.sh
#
# or under tests/run.sh, which discovers and aggregates. Layout
# convention: one tier per directory; inside it one directory per script
# under test, named after the script; one file per behaviour, suffixed
# `_test.sh`.

. "$(dirname "${BASH_SOURCE[0]}")/harness.sh"

CHECK_STATE="$REPO_ROOT/.writrun/skills/writrun-check-task-state/check_state.sh"
CHECK_DELTAS="$REPO_ROOT/.writrun/skills/writrun-check-spec-deltas/check_deltas.sh"
LIST_TASKS="$REPO_ROOT/.writrun/skills/writrun-select-next-task/list_tasks.sh"
NEW_SH="$REPO_ROOT/.writrun/skills/writrun-create-task-and-spec/new.sh"
BRIEF="$REPO_ROOT/.writrun/skills/writrun-select-next-task/brief.sh"

# The workflow step scripts — what the integration tier exercises, the same
# way the unit tier exercises the skills.
CI_SCRIPTS="$REPO_ROOT/.writrun/scripts"
READ_SETTING="$CI_SCRIPTS/stage-2-pull-requests/read_setting.sh"
CHECK_SETTINGS="$CI_SCRIPTS/stage-2-pull-requests/check_settings.sh"
STAGE_GATE="$CI_SCRIPTS/stage-2-pull-requests/stage_gate.sh"
CHECK_OBSERVANCE="$CI_SCRIPTS/stage-2-pull-requests/check_observance.sh"
TAKE_TASK="$CI_SCRIPTS/stage-2-pull-requests/take_task.sh"

# The Stage 1 half: the ledger's writer, the helper that proposes an entry
# from the agent platform's usage data, and the rollup. No forge is
# involved in any of the three — the field they work on exists wherever
# tasks do.
RECORD_PROVENANCE="$CI_SCRIPTS/stage-1-tasks-and-specs/record_provenance.sh"
PREFLIGHT="$CI_SCRIPTS/stage-1-tasks-and-specs/preflight.sh"
SESSION_CARD="$CI_SCRIPTS/stage-1-tasks-and-specs/session_card.sh"
READ_USAGE="$CI_SCRIPTS/stage-1-tasks-and-specs/read_usage.sh"
PROVENANCE_ROLLUP="$CI_SCRIPTS/stage-1-tasks-and-specs/provenance_rollup.sh"

# ledger_kept — a settings file whose one interesting line declares that
# this project keeps a ledger. Everything else is the documented default,
# spelled out because every documented key is present, always.
ledger_kept() {
  settings_file <<'JSON'
{
  "stage": 1,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": true,
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
}
WORKFLOWS="$REPO_ROOT/.github/workflows"

# settings_file — the whole settings file, from stdin, at the address it
# lives at today. Written verbatim, because half of what the check exists
# for is the shapes a generator would never produce.
settings_file() {
  mkdir -p .writrun
  cat > .writrun/settings.json
}

# legacy_settings_file — the same, at the address the file had before it
# moved to WritRun's root. The reader honours one left there, flat, under
# the contract frozen at the move; the check is what names the move
# (docs/technical/decisions/tasks-and-specs/0053-settings-at-the-root.md).
legacy_settings_file() {
  mkdir -p .writrun/conventions
  cat > .writrun/conventions/settings.json
}

# check_front_matter runs on files alone, so it is a skill rather than a
# CI script — it is the one check available at every adoption stage.
CHECK_FRONT_MATTER="$REPO_ROOT/.writrun/skills/writrun-check-front-matter/check_front_matter.sh"

# stub_gh <n> — put a fake `gh` on PATH that answers every invocation with
# <n>, standing in for the forge's count of authorized approving reviews.
stub_gh() {
  mkdir -p "$WORK/stub-bin"
  printf '#!/usr/bin/env bash\necho %s\n' "$1" > "$WORK/stub-bin/gh"
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
}

# stub_forge — a fake `gh` that answers the two questions the id checks
# ask, and records every call. Reads are served post-jq, the shape the
# real scripts request, so the shell logic under test sees exactly what
# CI would (the same contract mirror_lib.sh's forge holds):
#
#   gh pr list --json number        -> $FORGE_DIR/pr_numbers
#   gh api .../pulls/N/files        -> $FORGE_DIR/pr_N_paths
#   ... --jq '...status == "added"' -> $FORGE_DIR/pr_N_added
#
# The two consumers of the file list want different halves of it: the
# check selects the added files, the generator reads every path. The jq
# expression is what tells them apart, the same way it does at the real
# endpoint.
#
# **The list is paged, because that is the bug this stub has to be able
# to reproduce**: without `--paginate` the caller sees $FORGE_PAGE
# entries and no sign that more exist.
#
# Touch $FORGE_DIR/unavailable and every call fails, which is what no
# network, no auth, and no remote all look like from the caller's side.
# Call after setup — it lives in the repository setup created.
stub_forge() {
  FORGE_DIR="$WORK/forge"
  FORGE_LOG="$WORK/forge/gh.log"
  mkdir -p "$FORGE_DIR"
  : > "$FORGE_LOG"
  # GitHub's own page size for a pull request's file list.
  FORGE_PAGE=100
  export FORGE_DIR FORGE_LOG FORGE_PAGE

  mkdir -p "$WORK/stub-bin"
  cat > "$WORK/stub-bin/gh" <<'GH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FORGE_LOG"
[ -e "$FORGE_DIR/unavailable" ] && exit 1
case "${1:-}" in
  pr)
    field=""; prev=""
    for a in "$@"; do
      [ "$prev" = "--json" ] && field="$a"
      prev="$a"
    done
    case "$field" in
      number)         cat "$FORGE_DIR/pr_numbers" 2>/dev/null ;;
      # Two consumers of the same list, told apart by the fields they ask
      # for the way the `api` arm below tells its two apart by --jq: the
      # lister asks for the author column and the amendment check does
      # not, and handing four columns to a three-column reader puts the
      # title where the author goes.
      *author*)       cat "$FORGE_DIR/pr_lines" 2>/dev/null ;;
      *headRefName*)  [ -f "$FORGE_DIR/pr_lines" ] &&
                        awk -F'\t' -v OFS='\t' '{ print $1, $2, $4 }' \
                          "$FORGE_DIR/pr_lines" ;;
    esac
    ;;
  api)
    n=$(printf '%s' "${2:-}" | sed -n 's|.*/pulls/\([0-9][0-9]*\)/files$|\1|p')
    [ -n "$n" ] || exit 0
    jq=""; prev=""; paginate=""
    for a in "$@"; do
      [ "$prev" = "--jq" ] && jq="$a"
      [ "$a" = "--paginate" ] && paginate=yes
      prev="$a"
    done
    case "$jq" in
      *added*) src="$FORGE_DIR/pr_${n}_added" ;;
      *)       src="$FORGE_DIR/pr_${n}_paths" ;;
    esac
    [ -e "$src" ] || exit 0
    if [ -n "$paginate" ]; then cat "$src"; else head -n "$FORGE_PAGE" "$src"; fi
    ;;
esac
exit 0
GH
  chmod +x "$WORK/stub-bin/gh"
  export PATH="$WORK/stub-bin:$PATH"
}

# forge_pr <number> <added|modified> <path> — one file on one open pull
# request. The number joins the open list once; the path is visible to the
# generator either way, and only an added one is a claim the check reads.
# Files land in the order they are declared, which is the order the pages
# come in.
forge_pr() {
  grep -qxF "$1" "$FORGE_DIR/pr_numbers" 2>/dev/null \
    || printf '%s\n' "$1" >> "$FORGE_DIR/pr_numbers"
  printf '%s\n' "$3" >> "$FORGE_DIR/pr_${1}_paths"
  [ "$2" = added ] && printf '%s\n' "$3" >> "$FORGE_DIR/pr_${1}_added"
  return 0
}

# forge_open_pr <number> <branch> [title] [author] — one open pull request
# as the richer query sees it: the number, the head branch, the author and
# the title, which is where the [TASK-NNNN] tags live. Stored in the four
# -column shape the widest consumer asks for; the stub projects it down
# for the narrower one. Joins the plain number list too, so a case may mix
# this with forge_pr's file lists.
forge_open_pr() {
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "${4:-someone}" "${3:-}" \
    >> "$FORGE_DIR/pr_lines"
  grep -qxF "$1" "$FORGE_DIR/pr_numbers" 2>/dev/null \
    || printf '%s\n' "$1" >> "$FORGE_DIR/pr_numbers"
  return 0
}

# forge_pr_filler <number> <count> — <count> modified files on one open
# pull request, to push what follows them onto a later page.
forge_pr_filler() {
  local i=1
  while [ "$i" -le "$2" ]; do
    forge_pr "$1" modified "docs/filler-${i}.md"
    i=$((i + 1))
  done
}

# forge_unavailable — no `gh` answer at all, from here on.
forge_unavailable() { : > "$FORGE_DIR/unavailable"; }

# forge_untouched <name> — not a single call reached the forge.
forge_untouched() {
  if [ -s "$FORGE_LOG" ]; then
    printf 'FAIL  %s\n      expected no gh call at all\n' "$1"
    sed 's/^/      | /' "$FORGE_LOG"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}

# take_setup — the repository a take runs in: main checked out, a bare
# `origin` beside it holding the same commit, and the forge stubbed. The
# real git is deliberately kept — a take's whole contract is what it does
# to a repository and a remote, and a stub of both would only assert that
# the script called the commands the stub was written for.
take_setup() {
  setup
  git checkout -q main
  # The remote, the forge stub and the stub bin all live inside the work
  # directory, which is also the repository — so they are ignored before
  # anything else, or every take would refuse on a dirty tree made
  # entirely of test scaffolding.
  printf 'origin.git/\nforge/\nstub-bin/\nout.txt\n' > .gitignore
  git add .gitignore >/dev/null
  git commit -qm "ignore the scaffolding"
  git init -q --bare "$WORK/origin.git"
  git remote add origin "$WORK/origin.git"
  git push -q -u origin main 2>/dev/null
  stub_forge
}

# publish_main — main as the forge holds it. A take cuts its branch from
# `origin/main`, so a case that commits its queue on main has to publish
# it or the cut branch would lack the very files the take just read.
publish_main() { git push -q origin main 2>/dev/null; git fetch -q origin main 2>/dev/null; }

# no_branch_cut <name> <branch> — neither the checkout nor the remote
# grew the branch. What "nothing was done" means, asserted rather than
# trusted.
no_branch_cut() {
  if git rev-parse --verify --quiet "refs/heads/$2" >/dev/null 2>&1 \
     || git -C "$WORK/origin.git" rev-parse --verify --quiet "refs/heads/$2" >/dev/null 2>&1; then
    printf 'FAIL  %s\n      %s exists after a run that should have created nothing\n' "$1" "$2"
    fail=$((fail + 1))
  else
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  fi
}

# A repository with docs/ and one commit on main. cd's into it.
setup() {
  WORK_PREV="$WORK"
  WORK=$(mktemp -d)
  [ -n "$WORK_PREV" ] && rm -rf "$WORK_PREV"
  cd "$WORK" || exit 1
  git init -q .
  git symbolic-ref HEAD refs/heads/main
  git config user.email t@example.com
  git config user.name Test
  mkdir -p work/tasks work/specs docs/product docs/technical
  printf '# Product\n\n## Scope\n\nbaseline\n' > docs/product/chapter.md
  printf '# Technical\n\n## Decisions\n\nbaseline\n' > docs/technical/README.md
  printf '# About\n\nbaseline\n' > docs/about.md
  git add -A >/dev/null
  git commit -qm baseline
  git checkout -qb feature
}

# task_file <id> <status> <spec_ref> [completed] [taken_by] [origin] [ledger]
#
# `ledger` is the whole provenance field as it should appear — the empty
# `provenance: []` unless a case is about the ledger, in which case it is
# the block form, entry lines and all.
task_file() {
  cat > "work/tasks/$1.md" <<EOF
---
id: $1
status: $2
blocked_reason: null
taken_by: ${5:-null}
spec_ref: [$3]
doc_ref: null
origin: ${6:-rule}
priority: medium
depends_on: []
milestone: null
created: 2026-08-22T00:00:00Z
queued: null
completed: ${4:-null}
merged: null
${7:-provenance: []}
---

# Test task $1
EOF
}

# task_field <name> <task-id> <field> <value> — one front-matter field of
# one task, as the queue now holds it.
#
# The multi-task cases assert files rather than output: one run writes
# several tasks, and only the file says what each of them became.
task_field() {
  local got
  got=$(sed -n "s/^$3: *//p" "work/tasks/$2.md" | head -n1)
  if [ "$got" = "$4" ]; then
    printf 'ok    %s\n' "$1"; pass=$((pass + 1))
  else
    printf 'FAIL  %s\n      %s: %s is "%s", expected "%s"\n' "$1" "$2" "$3" "$got" "$4"
    fail=$((fail + 1))
  fi
}

# spec_file <id> <task> <status> [promised-path...]
#
# Every promised path lands in the section the schema puts it in — a
# `technical/…` path under Proposed technical changes, everything else
# under Proposed product changes — so a fixture promise has the shape a
# real one has. A section that gets none says "none", which is the other
# shape a promise comes in and the one a companion check must ignore.
spec_file() {
  local id="$1" task="$2" status="$3"
  shift 3
  local p product="" technical=""
  for p in "$@"; do
    [ -n "$p" ] || continue
    case "$p" in
      technical/*) technical="${technical}- \`${p}\` — test promise."$'\n' ;;
      *)           product="${product}- \`${p}\` — test promise."$'\n' ;;
    esac
  done
  [ -n "$product" ]   || product="- none — no behaviour change"$'\n'
  [ -n "$technical" ] || technical="- none — no machinery change"$'\n'

  cat > "work/specs/${id}.md" <<EOF
---
id: ${id}
task_ref: ${task}
status: ${status}
created: 2026-08-22T00:00:00Z
---

# ${id} — test

## Proposed product changes

${product}
## Proposed technical changes

${technical}
## Outcome

_(fill after execution)_
EOF
}

# report_file <id> <status> [task_ref] [triaged] [doc_ref]
#
# A report as the queue holds it. The directory is created here rather
# than in setup(), because "an adopter who never recorded one has no
# work/reports/" is a state every gate has to read as zero reports — and
# a fixture that always made the directory would hide the day one stopped
# doing so.
report_file() {
  mkdir -p work/reports
  cat > "work/reports/$1.md" <<EOF
---
id: $1
status: $2
task_ref: [${3:-}]
doc_ref: ${5:-null}
created: 2026-08-22T00:00:00Z
triaged: ${4:-null}
---

# Test report $1
EOF
}

commit_all() { git add -A >/dev/null; git commit -qm "change"; }

# commit_message <message> — one commit carrying exactly this message,
# body and trailers included. The credit check reads whole messages, so a
# case that needs a trailer needs a commit that really has one.
commit_message() {
  printf 'change %s\n' "$(date +%s%N 2>/dev/null || date +%s)" >> marker.txt
  git add -A >/dev/null
  git commit -q -m "$1"
}

# bot_commit <message> — the machinery's own recording commit, written
# with the committer identity the approve workflow sets. Never an agent's
# action, so no conduct flag reaches it.
bot_commit() {
  printf 'recorded %s\n' "$(date +%s%N 2>/dev/null || date +%s)" >> marker.txt
  git add -A >/dev/null
  git -c user.name='github-actions[bot]' \
      -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
      commit -q -m "$1"
}
