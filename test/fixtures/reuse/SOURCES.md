# Reuse fixtures

A brand (plotplot v1.11.0 plus two component contracts) and a small project. `src/page.html` uses the button and the checkbox from their homes once each, and rebuilds each once with a raw element. `src/components/button.html` is the button's home, where a raw `<button>` is the component itself. tests/reuse.spec.sh judges them.
