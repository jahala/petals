#!/usr/bin/env bash
# Spec: every shell script petals ships or tests with is free of shellcheck
# errors (for example `local` outside a function, which stops a script under
# set -e). Prints TAP. Run from the repo root: bash tests/shellcheck.spec.sh
cd "$(dirname "$0")/.." || exit 1
command -v shellcheck >/dev/null || { echo "shellcheck is not installed"; exit 127; }
fails=0
for f in scripts/*.sh petals/scripts/*.sh petals/scripts/lib/*.sh tests/*.sh tests/book/*.sh petals/bin/petals; do
  if out=$(shellcheck -S error "$f" 2>&1); then echo "ok - $f has no shellcheck errors"
  else echo "not ok - $f has shellcheck errors"; printf '%s\n' "$out" | sed 's/^/# /'; fails=$((fails+1)); fi
done
# sed -i takes its arguments differently on macOS and Linux, so a test that
# edits a file with it passes on one and silently edits nothing on the other
hits=$(grep -nE '(^|[^-a-z])sed -i' tests/*.sh | grep -v '^tests/shellcheck.spec.sh:' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#')
if [ -z "$hits" ]; then echo "ok - no test edits files with sed -i"
else echo "not ok - no test edits files with sed -i"; printf '%s\n' "$hits" | sed 's/^/# /'; fails=$((fails+1)); fi
echo; echo "$fails failure(s)"; exit "$fails"
