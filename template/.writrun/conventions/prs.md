# Pull requests

- **Title**: the Conventional Commit the squash will produce.
- **Body**: the [template](../templates/pull_request_template.md), lives
  only in `.writrun/templates/` — agents fill it when opening any PR; a
  human opening one by hand copies it from there (GitHub does not
  pre-fill from `.writrun/`; this project chose one home over the
  platform's pre-fill). Everything in it is editable except the
  `## Derived work` heading, which `writrun check` reads — a **contract
  marker**.
- **Merge**: squash only — a messy branch history is fine; the commit
  landing on `main` is not.
