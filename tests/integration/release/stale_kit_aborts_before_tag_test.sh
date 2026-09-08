#!/usr/bin/env bash
. "$(dirname "$0")/../../release_lib.sh"

# The sync must produce nothing but the stamp: the release commit stages
# only the two VERSION files, so any other sync output would be left
# behind and the tag would ship a template disagreeing with its own root
# — while the suite looks green, because it runs on the synced tree.
release_setup

# A make whose template-sync actually finds drift to fix — the situation
# a mirror-test failure merged past main would produce.
cat > "$WORK/stub-bin/make" <<EOF
#!/usr/bin/env bash
echo "make \$*" >> "$WORK/calls.log"
[ "\$1" = "template-sync" ] && printf 'drifted\n' > template/drifted.txt
exit 0
EOF
chmod +x "$WORK/stub-bin/make"

out=$(bash "$RELEASE_SH" 2>&1); code=$?
if [ "$code" -ne 0 ] &&
   printf '%s' "$out" | grep -q 'changed more than the version stamp' &&
   [ -z "$(git tag --list 'v0*')" ] &&
   ! grep -q 'make tests' "$WORK/calls.log"; then
  echo "ok    a template the sync had to fix aborts the release"; pass=$((pass + 1))
else
  echo "FAIL  a template the sync had to fix aborts the release"
  printf '%s\n' "$out" | sed 's/^/      | /'
  git tag --list | sed 's/^/      | tag: /'
  fail=$((fail + 1))
fi

finish
