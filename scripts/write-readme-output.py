"""Put a real `petals check` run under the README's Try it command.

usage: python3 -I scripts/write-readme-output.py "<output>"
Called by tests/readme.spec.sh --write after a deliberate change to the
check's output; the spec then holds the README to the real run.
"""
import sys

text = open("README.md", encoding="utf-8").read()
section = text.index("## Try it")
# the second fenced block of the section holds the output
first_open = text.index("```", section)
first_close = text.index("```", first_open + 3)
second_open = text.index("```", first_close + 3)
start = text.index("\n", second_open) + 1
end = text.index("```", start)
output = sys.argv[1].rstrip("\n") + "\n"
open("README.md", "w", encoding="utf-8").write(text[:start] + output + text[end:])
