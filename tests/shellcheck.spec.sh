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
echo; echo "$fails failure(s)"; exit "$fails"
