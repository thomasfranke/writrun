# an unusable gh aborts the release before anything is mutated.

**2026-08-24**

The cut ends at the forge (`gh release create`), which runs
after the push — so a missing or unauthenticated `gh` used to fail
there, with the tag already public: a half-release, from a script
whose whole design is that a bad tag is unrepresentable. The guard now
sits with the others, up front (`command -v gh` + `gh auth status`,
which reads local config and needs no network). Rejected: checking
only that the binary exists — an unauthenticated gh fails at the same
worst moment.
