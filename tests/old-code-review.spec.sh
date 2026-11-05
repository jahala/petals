#!/usr/bin/env bash
# Spec: docs/plans/old-code-review.md gives a verdict (port, learn from or
# drop) and a reason for every script petals ships and every /petals command
# SKILL.md dispatches. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
DOC=docs/plans/old-code-review.md
fails=0
[ -f "$DOC" ] || { echo "not ok - $DOC exists"; exit 1; }
has_verdict() { # has_verdict <row-prefix-regex>
  grep -E "^\| \`$1" "$DOC" | grep -qE '\| (port|learn from|drop) \| [^|]{12,}'
}
for f in petals/scripts/*.sh petals/scripts/lib/*.sh; do
  name=${f#petals/}
  if has_verdict "${name//./\\.}\`"; then echo "ok - $name has a verdict and a reason"
  else echo "not ok - $name has a verdict and a reason"; fails=$((fails+1)); fi
done
for cmd in $(grep -oE '^\| `/petals [a-z]+' petals/SKILL.md | awk '{print $3}' | sort -u); do
  if has_verdict "$cmd"; then echo "ok - /petals $cmd has a verdict and a reason"
  else echo "not ok - /petals $cmd has a verdict and a reason"; fails=$((fails+1)); fi
done
echo; echo "$fails failure(s)"; exit "$fails"
