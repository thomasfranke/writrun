# the adoption kit is `template/`: a full copy, guarded by a test.

**2026-08-22**

One folder an adopter pastes beats a manifest of paths to
collect by hand, but a copy is a second source of truth — so the copy
is legal only because a unit test holds every mirrored path
byte-identical to the root (`tests/template_mirrors.txt` is the single
list; `make template-sync` refreshes; hand-editing `template/` is never
the fix). The split also cleaned up what ships: the test-suite job left
`writrun-check.yml` — an adopter has no `tests/run.sh` for it to run —
into a home-only `tests.yml`, so the kit carries exactly the four
writrun workflows and nothing of this repository's own CI. Versions are
tags on `main`; adopters and the future CLI pin the tag they took the
kit from. The kit's second invariant, added when a blind `cp -R` was
audited: **copying must destroy nothing**. Its first cut shipped
`README.md`, `AGENTS.md`, and `docs/` skeletons at the kit root — a
blind copy would have replaced the adopting project's own README, the
worst possible first impression. Now every path that lands outside the
kit's folder is WritRun-namespaced, and all adaptable skeletons arrive
quarantined in `writrun-kit/`, grafted and then deleted. Rejected: a
delta-only template (no duplication, but the adopter assembles from two
places and the future `init` would too), and a separate template
repository (a second repo to keep in sync with no test spanning the
two).
