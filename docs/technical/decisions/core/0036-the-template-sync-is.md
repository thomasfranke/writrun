# the template sync is a script, not a Makefile recipe.

**2026-08-23**

The Makefile's own header says thin aliases only, and `template-sync`
was the one exception: real logic inline where no test executes it —
the same shape the workflow YAML had before its extraction, carrying
the same cost on order. It also told a quiet lie: a path in the
mirror list but gone from the root had its template copy deleted and
still printed "synced". Now `scripts/sync_template.sh` (home
automation, beside `release.sh` — an adopter has no `template/`) is
the single writer: a missing root path is a named error that leaves
the stale copy in place, and the integration tier executes every
behaviour, the silent lie included. Rejected: leaving the recipe
inline (the Makefile's own contract forbids it), and folding the
sync into `release.sh` (the sync is useful alone, and the release
already reaches it through the alias).
