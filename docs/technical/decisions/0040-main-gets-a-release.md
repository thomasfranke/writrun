# main gets a release pipeline of its own; the cut stays local.

**2026-08-23**

The home CI (`tests.yml`) ran only on pull requests, so a
change landing on `main` without one — an admin push — was never
re-checked on the branch releases are cut from. The two questions CI
answers are different — *is this change good?* on the PR, *is this
branch releasable?* on `main` — so they are two pipelines now:
`tests.yml` stays the pull-request suite, and `release-readiness.yml`
runs on every push to `main` with a dedicated named job for the
release signal: the template mirror case alone, fast, so a template
diverging from its root breaks a pipeline named for what it guards —
the same drift `make release` refuses locally — with the full suite
beside it. The cut itself deliberately does not move into CI: the
stamp commit cannot be pushed to a protected `main` by
`GITHUB_TOKEN`, and the tokens that could (a PAT, an App) are the
dependency this project has rejected three times over. Rejected: a
workflow_dispatch release pipeline (it ends at the push it cannot
make); one workflow carrying both triggers (a red run would not say
which question failed); and a third comparator script for the
divergence check — the suite's own mirror case is the comparison, run
alone rather than reimplemented.
