#!/usr/bin/env bash
# Spec: the check reads the brand's component contracts and flags a control
# rebuilt by hand. Outside a component's home, a raw element its Covers column
# names, without the contract's class, is an error that names the home. The
# home itself, a use with the class, a capitalised component (<Button>) and
# quoted markup are fine. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
F=test/fixtures/reuse
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

out=$(bash "$SCRIPT" "$F/src/page.html" --brand "$F/brand" --product petals 2>&1); rc=$?
t "a raw button outside its home is an error naming the home" 'ERROR \[reuse\] line 3: a raw <button> rebuilds a component\. Use \.btn from src/components/button\.html \(components/button\.md\)\.' "$out"
t "a raw checkbox outside its home is an error naming the home" 'ERROR \[reuse\] line 5: a raw <input type=checkbox> rebuilds a component\. Use \.check from src/components/checkbox\.html \(components/checkbox\.md\)\.' "$out"
n "a use with the contract's class is fine" 'line (2|4): a raw' "$out"
n "an element no contract covers is fine" 'line 6: a raw' "$out"
n "a capitalised component is the component in use" 'line 7: a raw' "$out"
n "quoted markup is not a control" 'line 8: a raw' "$out"
t "the summary counts reuse" '^Reuse: +2 error\(s\)' "$out"
[ "$rc" = 1 ] && echo "ok - rebuilt controls fail the check" || { echo "not ok - rebuilt controls fail the check (rc $rc)"; fails=$((fails+1)); }

out=$(bash "$SCRIPT" "$F/src/components/button.html" --brand "$F/brand" --product petals 2>&1)
n "a raw element in its own home is the component" '\[reuse\]' "$out"

out=$(bash "$SCRIPT" "$F/src/page.html" --brand "$F/brand" --product petals --format sarif 2>&1)
t "SARIF names the rule reuse/rebuilt-component" '"ruleId": *"reuse/rebuilt-component"' "$out"

out=$(bash "$SCRIPT" "$F/src/page.html" --brand test/fixtures/brand-plotplot-v1.11.0/.brand --product petals 2>&1)
n "a brand without contracts flags no rebuild" '\[reuse\]' "$out"
t "and the summary says there are no contracts" '^Reuse: +no contracts' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
