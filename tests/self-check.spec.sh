#!/usr/bin/env bash
# Spec: petals' own pages pass petals. index.html is checked against the frozen
# brand it was built from, with petals' product layer, and must have no errors.
# Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
BRAND=test/fixtures/brand-plotplot-v1.13.0/.brand
if out=$(bash petals/scripts/check.sh index.html --brand "$BRAND" --product petals 2>&1) && echo "$out" | grep -q '^Result: PASS'; then
  echo "ok - index.html passes petals check"
else
  echo "not ok - index.html passes petals check"
  echo "$out" | grep -E '^(ERROR|Result)' | sed 's/^/# /'
  exit 1
fi
