# a release verifies the sync produced nothing but the stamp.

**2026-08-23**

The release decision above declared an unsynced mirror
unrepresentable, and the implementation did not deliver it: the
release commit stages only the two `VERSION` files, so if
`template-sync` had found real drift — a mirror-test failure merged
past `main` — the fix would be left uncommitted, the suite would pass
(it runs on the synced working tree), and the tag would ship a
template disagreeing with its own root, looking green throughout.
`release.sh` now aborts when the sync's output goes beyond the two
stamps, naming the drifted paths: a release records, it does not fix —
drift gets its own reviewed change. The guard's first real execution
caught exactly this: an e2e run against a working tree whose
`new.sh`/SKILL edits had not yet been re-synced. Rejected:
auto-committing the drift inside the release commit, which would hide
an unreviewed template change inside a `chore(release)`.
