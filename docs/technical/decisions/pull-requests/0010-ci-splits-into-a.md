# CI splits into a mandatory read-only check and a best-effort write.

**2026-08-22**

A protected `main` cannot be pushed to by
`GITHUB_TOKEN`, and a fork's head branch cannot be pushed to by it either
— no setting changes either fact. Rather than pick one contribution model,
the workflows decide at runtime: `writrun check` runs on every pull
request from anywhere with no secrets and no write permission, and is the
half that carries the guarantee; `writrun approve` records `draft →
approved` onto the pull request's own branch, and simply does not run for
a fork. An adopter without the write permission configured loses the
convenience and keeps the guarantee. Rejected: requiring a GitHub App
token to adopt at all (a methodology non-goal is platform lock-in, and App
setup is a barrier well above copying files), and firing the flip
post-merge on `main` (the one place the token provably cannot write).
