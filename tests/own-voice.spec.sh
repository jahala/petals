#!/usr/bin/env bash
# Spec: petals' own messages follow the brand it carries. voice.md bans em
# dashes, so no finding, summary or result line petals prints contains one.
# The control page breaks every rule once, so its run prints every message
# kind. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
fails=0
for run in "test/fixtures/control/control.html test/fixtures/brand-plotplot-v1.9.0/.brand" \
           "test/fixtures/landing/hero.html test/fixtures/brand-plotplot-v1.11.0/.brand" \
           "test/fixtures/check/bad.css test/fixtures/brand-plotplot-v1.9.0/.brand"; do
  set -- $run
  out=$(bash "$SCRIPT" "$1" --brand "$2" --product petals 2>&1)
  hits=$(printf '%s\n' "$out" | grep -n '—')
  if [ -z "$hits" ] && [ -n "$out" ]; then echo "ok - petals check on $1 prints no em dash"
  else echo "not ok - petals check on $1 prints no em dash"; printf '%s\n' "$hits" | sed 's/^/# /'; fails=$((fails+1)); fi
done
[ "$fails" = 0 ]
