#!/usr/bin/env bash
# Spec: SKILL.md stays small, because an agent loads all of it every time the
# skill activates; rarer tasks live in references/. Every path it names exists,
# and every reference is reachable from it. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SKILL=petals/SKILL.md
BUDGET=900   # words; about 1,200 tokens
fails=0
ok() { if [ "$2" = 0 ]; then echo "ok - $1"; else echo "not ok - $1"; fails=$((fails+1)); fi }
is() { if "${@:2}"; then ok "$1" 0; else ok "$1" 1; fi }
words=$(wc -w < "$SKILL" | tr -d ' ')
is "SKILL.md is at most $BUDGET words ($words)" [ "$words" -le "$BUDGET" ]
# shellcheck disable=SC2016  # the backticks are literal markdown
for p in $(grep -oE '`(scripts|references|templates)/[A-Za-z0-9._/-]*`' "$SKILL" | tr -d '`' | sort -u); do
  is "SKILL.md names $p, which exists" [ -e "petals/$p" ]
done
for f in petals/references/*.md; do
  r=${f#petals/}
  if grep -qF "\`$r\`" "$SKILL" || grep -lF "$r" petals/references/*.md | grep -qv "^$f$"; then ok "$r is reachable from SKILL.md or another reference" 0
  else ok "$r is reachable from SKILL.md or another reference" 1; fi
done
[ "$fails" = 0 ]
