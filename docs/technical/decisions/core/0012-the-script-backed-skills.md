# the script-backed skills carry a test suite.

**2026-08-22**

"There is
nothing to build" is true of the docs and of trivial scripts, and these
are neither: one of them is the mechanical guard on a human gate, and the
rest encode rules the methodology is unusable without. A check nobody
executes is a check nobody can trust — the failure mode is not a wrong
answer but a silent one, which looks exactly like a clean result.
The suite is two tiers — `unit/` for the skill scripts, `integration/`
for the workflow step logic — one directory per script under test, one
file per behaviour suffixed `_test.sh`; each sources the fixture for
its domain (`tests/pipeline_lib.sh`, `tests/release_lib.sh` — layered
on `tests/harness.sh`),
builds a throwaway repository, asserts exit codes, and runs standalone
or under the discovering `tests/run.sh`; all of it under the same
constraints as the scripts themselves: git, `bash`, POSIX `awk`/`sed`,
no framework — the one external voice, the forge's review count, arrives
through `gh` and is a PATH-stubbed fake in tests. The integration tier
exists because the workflows' step logic used to live inline in YAML,
where no test could execute it: it moved to `.writrun/scripts/`, and the
YAML thinned to wiring events onto scripts. Rejected: a test framework — a package
manager to verify a doc change contradicts the portability rule these
scripts already live under; and leaving them untested on the grounds that
they are short, since length was never the argument.
