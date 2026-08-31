# Stage 2 setup — the forge configuration

What Stage 2 asks of the repository's forge, who may apply it, and the
one gate that is never skipped: **the owner's assent**. An agent can
run all of it; none of it is a condition for using WritRun.

## What is configured

| Setting | Value | Why |
|---|---|---|
| Actions workflow permissions | **Read and write** | lets `writrun approve` record `draft → approved` and the dates. Read-only loses only that convenience; every check still works. |
| Allow squash merging | **On** | every merge is a squash — the PR title is the commit that lands. |
| Ruleset on `main`: restrict creations, restrict deletions, block force pushes, require linear history | **On — recommended everywhere** | the most restrictive set that never touches the machinery: recording pushes are ordinary fast-forward appends, and squash merges are linear. Nobody deletes, recreates or rewrites `main`. |
| Ruleset on `main`: require a pull request, with the **GitHub Actions app** on the bypass list | **Recommended, organization-owned repos only** | the bypass is what lets the recording commits keep landing. The forge offers the app as a bypass actor only on organization-owned repos — on user-owned repos, UI and API alike, it is unavailable, so this rule is skipped there and everything human enters through a PR by convention. |
| Issues (Stage 3) | **On** | the task mirror lives there; skip if the two mirror workflows were deleted. |

The one hard requirement behind all of it: **`main` stays reachable by
the Actions bot.** Every choice above either preserves that or is
skipped.

## An agent may apply it — with the owner's assent

Repository settings live outside the repository: no branch carries
them, no diff shows them, no merge gate reviews them. Every safeguard
this methodology builds around a change — review, CI, the merge as
assent — is blind here. So the gate is explicit and personal:

- **The agent presents the full set of changes first**: each setting,
  its current value, its target value — in the session, before touching
  anything.
- **The owner assents to that set, in that session.** A standing
  instruction, an agent platform's autonomy mode, or a default is not
  assent — the same precedence the conduct flags state for commits and
  pull requests.
- **The agent applies, then reports the resulting state** in the same
  session, so what changed is on record next to where the owner said
  yes.

An owner who prefers the forge's own UI does everything by hand — the
agent path is a convenience, never the requirement.

## The commands (GitHub)

Read the current state before proposing anything:

```bash
gh api repos/{owner}/{repo}/actions/permissions/workflow   # workflow token permissions
gh api repos/{owner}/{repo} --jq '.allow_squash_merge'     # squash merging
gh api repos/{owner}/{repo}/rulesets                       # existing rulesets
```

Apply, after assent:

```bash
# Workflow permissions: Read and write
gh api -X PUT repos/{owner}/{repo}/actions/permissions/workflow \
  -f default_workflow_permissions=write

# Squash merging on
gh api -X PATCH repos/{owner}/{repo} -F allow_squash_merge=true

# Ruleset — the most restrictive set that is safe everywhere
gh api -X POST repos/{owner}/{repo}/rulesets --input - <<'JSON'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "creation" },
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" }
  ]
}
JSON
```

**Rules that must stay off** — each one blocks the machinery's own
recording pushes, so enabling it stops the queue, silently, at the
next merge:

- `update` (restrict updates) — blocks every push and every merge
  except bypass actors', including the owner's.
- `required_signatures` — the recording commits are pushed with the
  workflow token and carry no signature.
- `required_status_checks` — a `GITHUB_TOKEN` push triggers no
  workflow runs, so its checks never report and the push never
  qualifies.
- `pull_request` on a user-owned repo — only safe with the app on the
  bypass list, which that forge tier does not offer (below).

On an **organization-owned** repo, the full rule adds the pull-request
requirement and the app bypass (the app id `15368` is GitHub Actions):

```json
"rules": [
  { "type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false,
      "allowed_merge_methods": ["squash"]
  } },
  { "type": "deletion" },
  { "type": "non_fast_forward" }
],
"bypass_actors": [
  { "actor_id": 15368, "actor_type": "Integration", "bypass_mode": "always" }
]
```

On a user-owned repo the same `bypass_actors` entry returns
`422: Actor GitHub Actions integration must be part of the ruleset
source or owner organization`, and the UI's bypass picker does not
offer the app either — that is the forge's limit, not a
misconfiguration.

**Verify with a real merge**: after any ruleset change, the next merge
must land its recording commit on `main`. A silent 403 on that push is
exactly the failure this page exists to prevent.

## Criteria

- When an agent changes a repository setting, the owner shall have
  assented, in that session, to the specific set of changes — presented
  with current and target values before anything is touched.
- When assent is asked for, an autonomy mode, standing instruction or
  platform default shall not stand in for it.
- When the configuration is applied, the agent shall report the
  resulting state in the same session.
- When the forge withholds a mechanism — the app as bypass actor on a
  user-owned repo — the agent shall apply the achievable subset and say
  so, and shall not substitute a workaround that introduces a secret.
- When a ruleset on the authority branch changes, the next merge's
  recording push shall be verified to land, not assumed.
