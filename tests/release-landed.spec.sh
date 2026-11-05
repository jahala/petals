#!/usr/bin/env bash
# Spec: every path the June 2026 release work touched is accounted for. A path
# is landed when this checkout tracks it, and left out when it falls under a
# prefix the review names under "Left out of the landing", is the ignored brand
# cache, or is named in the review by its exact path. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
LIST=docs/plans/release-work-paths.txt
fails=0; n=0
[ -f "$LIST" ] || { echo "not ok - $LIST exists"; exit 1; }
left_out() {
  case "$1" in
    docs/tend/*|.githooks/*|*.DS_Store) return 0 ;;
    .brand/products/petals/*) return 1 ;;
    .brand/*) return 0 ;;
  esac
  return 1
}
missing=""
while IFS= read -r p; do
  [ -n "$p" ] || continue; n=$((n+1))
  if git ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || left_out "$p" || grep -qF -- "\`$p\`" docs/plans/old-code-review.md; then :; else missing="$missing $p"; fi
done < "$LIST"
if [ -z "$missing" ]; then echo "ok - all $n release-work paths are landed or named as left out"
else echo "not ok - release-work paths unaccounted for:$missing"; fails=1; fi
grep -q '^## Left out of the landing' docs/plans/old-code-review.md && echo "ok - the review names what was left out" || { echo "not ok - the review names what was left out"; fails=$((fails+1)); }
echo; echo "$fails failure(s)"; exit "$fails"
