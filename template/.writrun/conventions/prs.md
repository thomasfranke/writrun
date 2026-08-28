# Pull requests

- **Title**: every task the PR carries, tagged, then the Conventional
  Commit the squash will produce — `[TASK-0012] fix(ci): debounce mirror
  updates`, or `[TASK-0012][TASK-0014] feat(mirror): …` when several,
  one bracket each and no separator. Uppercase; the machinery maps it to
  the lowercase file id. **The tag leads** because the squash puts the
  title into `main`'s history, where a scanning eye reads the left edge:
  what work this was comes before what kind of change it was, and a
  task's story stays a `git log --grep`. Authoring and tracking PRs
  carry no tag: their tasks are born in the PR, not worked by it, and
  their titles open with the type.
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
