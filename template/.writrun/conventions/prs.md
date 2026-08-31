# Pull requests

- **Title**: every task the PR carries, tagged, then a summary written in
  the style [`settings.json`](../settings.json) names.

  **The tag is not the settable part.** One bracket per task, uppercase,
  no separator — `[TASK-0012]`, or `[TASK-0012][TASK-0014]` when several.
  It leads because the squash puts the title into `main`'s history, where
  a scanning eye reads the left edge: what work this was comes before
  what kind of change it was, and a task's story stays a `git log
  --grep`. It is also how the machinery learns which tasks the PR
  carries, so it stays whatever the style. Authoring and tracking PRs
  carry none — their tasks are born in the PR, not worked by it.

  **`stage_2.pr_title_style` chooses what follows**, and the choice is
  about who reads the history:

  - `conventional` — the Conventional Commit the squash will produce:
    `[TASK-0012] fix(ci): debounce mirror updates`, and
    `docs(product): the merge is the assenting act` for an authoring PR.
    Familiar to tooling built around the convention, and a log that
    machines and people both scan.
  - `bracketed` — a human sentence behind bracketed labels:
    `[TASK-0012][Fix][CI] Debounce mirror updates`, and
    `[DOCS] The merge is the assenting act`. Nothing here parses a
    subject, so this costs no guarantee; it reads as prose rather than as
    a grammar, which suits a project whose history is read mostly by
    people.

  Neither is more correct. Pick the one your readers already know, state
  it in the settings file, and let the agents follow it.
- **Body**: the [template](../templates/pull_request_template.md), lives
  only in `.writrun/templates/` — agents fill it when opening any PR; a
  human opening one by hand copies it from there (GitHub does not
  pre-fill from `.writrun/`; this project chose one home over the
  platform's pre-fill). Everything in it is editable except the
  `## Derived work` heading, which `writrun check` reads — a **contract
  marker**.
- **Opening state**: an implementing PR opens as a **draft**, at the
  moment its task is taken and before the work starts — that is what puts
  the task's mirror on `status:in-progress`. Ready for review is the end
  of the work, not the start. Authoring and tracking PRs have no work to
  announce and open ready.
- **Merge**: squash only — a messy branch history is fine; the commit
  landing on `main` is not.

## Who opens the pull request — `stage_2.auto_pr`

`true`, the default, lets an agent open and update pull requests on its
own as its flow requires. `false` gates the action and never the work: the
agent still composes the **complete** title and body — the template
filled, the specs named, the verification stated — presents them, and
opens the pull request only after an explicit yes. Approval is per action,
never a session-wide grant.

**The flag outranks the agent platform's own autonomy mode**, exactly as
`auto_commit` does in [commits.md](commits.md): the platform's mode
governs what the *harness* asks, this flag governs what the *adopter*
allowed.

**It holds the draft too.** The pull request that reports a task as taken
is mechanical, but mechanical is not exempt — the flag gates the action,
not the reason for it. The agent presents, waits, and the taking flow
continues unchanged afterwards. It sits in `stage_2` rather than beside
`auto_commit` because pull requests begin at Stage 2; below that there is
nothing for it to gate.

`stage_1.credit_ai` reaches the body as it reaches a commit message: with
`false`, nothing an agent writes into the forge carries a generated-with
line, a session URL or any other platform credit.
