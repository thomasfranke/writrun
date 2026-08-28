# the mirror workflows' logic moved out of the YAML too.

**2026-08-23**

The test-suite decision above moved every workflow step into
`.writrun/scripts/` — except the two Issues-mirror workflows, whose
reconciliation lived on as inline `github-script` JavaScript no test
could execute. The cost arrived on schedule: when the queue moved to
`work/`, the mirror's file filters kept matching `docs/tasks/` — a
regression a review caught, not a test, in exactly the code the earlier
decision had left exempt. Both are now bash — `mirror_issues.sh`,
`reflect_progress.sh` — under the same constraints as every other
script (`gh` where the forge must be asked, PATH-stubbed in tests;
POSIX `awk`/`sed`), with a third fixture, `tests/mirror_lib.sh`, faking
the forge's answers and recording every mutation for the cases to
assert against. Two behaviour notes the port makes explicit: the pull
request's files are still read as API patch data, never checked out —
the workflows now check out only the *base* branch, and only to obtain
the scripts themselves — and `reflect_progress.sh` resolves a spec
branch through the base checkout's own `work/specs/` file, the same
resolution `list_tasks.sh` performs. Rejected: keeping the JavaScript
and testing it under node — a runtime the suite's own constraints
exclude, for logic that is plumbing, not language-bound; and extracting
it untested, which is the state this entry exists to end.
