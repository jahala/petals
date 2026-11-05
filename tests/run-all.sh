#!/usr/bin/env bash
# Runs every spec suite under tests/ and prints their TAP lines.
# Exits non-zero when any suite fails. Run from anywhere. It also holds the
# landing page's test count ("400+"): the real count must reach that floor.
cd "$(dirname "$0")/.." || exit 1
rc=0; total=0
for spec in tests/*.spec.sh; do
  out=$(bash "$spec" 2>&1); code=$?
  printf '%s\n' "$out" | grep -E '^(ok|not ok) '
  total=$((total + $(printf '%s\n' "$out" | grep -cE '^ok ')))
  [ "$code" -eq 0 ] || { echo "# $spec exited $code"; rc=1; }
done
floor=$(grep -o '<dt>tests</dt><dd>[0-9]*+' index.html | grep -oE '[0-9]+')
if [ -n "$floor" ] && [ "$total" -ge "$floor" ]; then echo "ok - the landing page's test count ($floor+) holds: $total pass"
else echo "not ok - the landing page's test count (${floor:-missing}+) holds: $total pass"; rc=1; fi
exit "$rc"
