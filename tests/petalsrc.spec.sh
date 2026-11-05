#!/usr/bin/env bash
# Spec: this repository's .petalsrc pins the plotplot umbrella and names petals
# as its product, and the pinned version is a tag the source publishes.
# Reaches GitHub through git ls-remote; exits 3 (unevaluable) when it cannot.
# Prints TAP. Run from the repo root: bash tests/petalsrc.spec.sh
cd "$(dirname "$0")/.." || exit 1
fails=0
field() { sed -nE "s/^[[:space:]]*$1:[[:space:]]*\"?([^\"#]*[^\"#[:space:]])\"?.*/\\1/p" .petalsrc | head -1; }
[ "$(field source)" = "https://github.com/jahala/plotplot.git" ] && echo "ok - source is jahala/plotplot" || { echo "not ok - source is jahala/plotplot (got $(field source))"; fails=$((fails+1)); }
[ "$(field product)" = "petals" ] && echo "ok - product is petals" || { echo "not ok - product is petals"; fails=$((fails+1)); }
git ls-files --error-unmatch .brand/products/petals/colors.md >/dev/null 2>&1 && echo "ok - the petals product layer is committed" || { echo "not ok - the petals product layer is committed"; fails=$((fails+1)); }
git check-ignore -q .brand/colors.md && echo "ok - the umbrella's files are ignored" || { echo "not ok - the umbrella's files are ignored"; fails=$((fails+1)); }
# the pin names a tag the source publishes; being behind a newer tag is drift,
# reported by check-brand-drift.sh, never a failure of this repository's change
tags=$(git ls-remote --tags "$(field source)" 2>/dev/null) || { echo "unevaluable: the brand source is unreachable from here"; exit 3; }
[ -n "$tags" ] || { echo "unevaluable: the brand source answered with no tags"; exit 3; }
if printf '%s\n' "$tags" | grep -q "refs/tags/$(field version)\$"; then echo "ok - the pinned version $(field version) is a tag the source publishes"
else echo "not ok - the pinned version $(field version) is a tag the source publishes"; fails=$((fails+1)); fi
drift=$(bash petals/scripts/check-brand-drift.sh 2>/dev/null) && true
case "$drift" in *'"status":"drift"'*) echo "# drift: $drift" ;; esac
echo; echo "$fails failure(s)"; exit "$fails"
