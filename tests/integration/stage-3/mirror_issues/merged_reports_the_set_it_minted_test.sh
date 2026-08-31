#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Which mirrors exist is derived here, from the pull request's files;
# which get labelled is derived by the caller from a commit range. A
# rebase merge is where the two part — `merge_commit_sha` names only the
# last rebased commit — and a mirror minted but never labelled is a state
# no later event corrects. So this pass reports its own set, and the
# projection is given it alongside the recording's scope.
setup_forge
export PR_STATE=closed PR_MERGED=true

# One task the merge brings whose mirror does not exist yet: minted here.
added_task task-0005 "Minted at the merge"
# One that already has this pull request's own mirror: reconciled here.
added_task task-0006 "Already mirrored"
forge_issue 66 open "writrun:task,status:proposed" "[TASK-0006] Already mirrored"
# And one another *open* pull request owns, which this pass refuses to
# touch. Refusing it and then handing it to the projection would be the
# same defect at one remove, so it is left out of the set.
added_task task-0007 "Somebody else's mirror"
forge_issue 67 open "writrun:task,status:proposed" "[TASK-0007] Somebody else's mirror" 9
forge_pr_state 9 open

OUT=$(mktemp "${TMPDIR:-/tmp}/writrun-out.XXXXXX")
check "the merge reconciles what it owns" 0 \
  "task-0005" -- env GITHUB_OUTPUT="$OUT" bash "$MIRROR_ISSUES" o/r 7

reported=$(sed -n 's/^tasks=//p' "$OUT")
case " $reported " in
  *" task-0005 "*) echo "ok    it reports the mirror it minted"; pass=$((pass+1)) ;;
  *) printf 'FAIL  it reports the mirror it minted\n      | tasks=%s\n' "$reported"
     fail=$((fail+1)) ;;
esac
case " $reported " in
  *" task-0006 "*) echo "ok    and the one it found to be its own"; pass=$((pass+1)) ;;
  *) printf 'FAIL  and the one it found to be its own\n      | tasks=%s\n' "$reported"
     fail=$((fail+1)) ;;
esac
case " $reported " in
  *" task-0007 "*)
     printf 'FAIL  and never one it refused to touch\n      | tasks=%s\n' "$reported"
     fail=$((fail+1)) ;;
  *) echo "ok    and never one it refused to touch"; pass=$((pass+1)) ;;
esac

rm -f "$OUT"
finish
