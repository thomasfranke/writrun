# Thin aliases only — the scripts are the interface, this file just names
# them. CI calls the scripts directly and must keep working without make.

.PHONY: tests test test-unit test-integration

# Everything — both tiers.
tests:
	bash tests/run.sh

# `make test` is the muscle-memory alias for the same thing.
test: tests

test-unit:
	@fail=0; \
	for f in tests/unit/*/*_test.sh; do \
	  [ -e "$$f" ] || continue; \
	  bash "$$f" || fail=1; \
	done; \
	exit $$fail

test-integration:
	@fail=0; \
	for f in tests/integration/*/*_test.sh; do \
	  [ -e "$$f" ] || continue; \
	  bash "$$f" || fail=1; \
	done; \
	exit $$fail

# Refresh template/ from the root — the mirror list is the single source
# (tests/template_mirrors.txt); a unit test keeps the copy honest. The
# logic lives in scripts/sync_template.sh, where the suite executes it.
.PHONY: template-sync
template-sync:
	@bash scripts/sync_template.sh

# Cut a release: `make release` (= minor), or `make release minor|major|epoch`.
# The whole path — compute, stamp, sync, test, commit, tag, push, publish —
# lives in the script.
.PHONY: release minor major epoch
release:
	@MAKE="$(MAKE)" bash scripts/release.sh $(filter epoch major minor,$(MAKECMDGOALS))

# The bump words are goals only so `make release minor` parses — no-ops alone.
minor major epoch:
	@:

# make test-unit / test-integration (a tier), or test-check_state,
# test-check_deltas, test-list_tasks, test-new, test-flip_specs, ... (one
# suite directory, whichever tier it lives in).
test-%:
	@fail=0; found=0; \
	for f in tests/$*/*_test.sh tests/$*/*/*_test.sh tests/*/$*/*_test.sh; do \
	  [ -e "$$f" ] || continue; found=1; \
	  bash "$$f" || fail=1; \
	done; \
	if [ "$$found" -eq 0 ]; then echo "no such suite: $*"; exit 3; fi; \
	exit $$fail