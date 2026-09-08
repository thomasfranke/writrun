#!/usr/bin/env bash
. "$(dirname "$0")/../../harness.sh"

# The commit vocabulary is a value, so it lives in settings.json and the
# checks read it there (docs/technical/settings/schema.md#settings).
# Before that it was embedded in check_observance.sh while
# conventions/commits.md declared it in prose: an adopter who edited the
# prose changed nothing the door saw, and one who edited the script had
# it reverted by the next update (report-0040).

R="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/read_setting.sh"
C="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/check_settings.sh"

WORK=$(mktemp -d); cd "$WORK"; mkdir -p writrun
# check_settings.sh renders its summary through read_setting.sh at a
# path relative to the root it is run from, so the kit's home has to be
# reachable here.
ln -s "$REPO_ROOT/.writrun" .writrun

settings() {   # settings <types-line> <scopes-line>
  cat > writrun/settings.json <<JSON
{
  "stage": 3,
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
    "commit_scopes": "$2",
    "commit_types": "$1",
    "pr_title_style": "conventional"
  }
}
JSON
}

# Absent is the behaviour from before the keys existed: the words the
# check carried embedded, so a project that declares neither is judged
# exactly as it was.
check "an undeclared vocabulary is the documented default" 0 "docs feat fix refactor chore	default" \
  -- bash "$R" stage_2.commit_types --origin
check "and its scopes are the embedded list of the day" 0 "about product technical tasks specs skills ci tests agents readme setup queue conventions	default" \
  -- bash "$R" stage_2.commit_scopes --origin

settings "docs feat fix" "api web"
check "a declared type list is the project's" 0 "docs feat fix	declared" \
  -- bash "$R" stage_2.commit_types --origin
check "a declared scope list is the project's" 0 "api web	declared" \
  -- bash "$R" stage_2.commit_scopes --origin
check "and the file is canonical with both keys" 0 "canonical" -- bash "$C"

# The words are the project's; the shape is the contract, because the
# readers split on single spaces.
settings "" "api web"
check "an empty vocabulary is refused by name" 1 "commit_types is empty" -- bash "$C"

settings "docs Feat" "api web"
check "an upper-case word is refused" 1 "lower-case words" -- bash "$C"

settings "docs feat" "api  web"
check "a double space is refused — it would read as an empty word" 1 "double space" -- bash "$C"

settings "docs,feat" "api web"
check "a comma-separated list is refused" 1 "lower-case words" -- bash "$C"

cd "$REPO_ROOT"
finish
