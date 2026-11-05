#!/usr/bin/env bash
# Spec: every Python file petals ships parses (checked with ast, so nothing
# is written to disk). Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
fails=0
for f in petals/scripts/*.py; do
  [ -f "$f" ] || continue
  if python3 -I -c 'import ast, sys; ast.parse(open(sys.argv[1], encoding="utf-8").read(), sys.argv[1])' "$f" 2>/dev/null; then echo "ok - $f parses"
  else echo "not ok - $f parses"; fails=$((fails+1)); fi
done
echo; echo "$fails failure(s)"; exit "$fails"
