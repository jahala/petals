"""Render a real `petals check` run into the frame on index.html.

usage: python3 -I scripts/write-landing-frame.py "<output>"
Called by tests/landing-frame.spec.sh --write after a deliberate change to the
check's output; the spec then holds the frame to the real run.
"""
import html
import re
import sys


def esc(text):
    return html.escape(text, quote=True).replace("&#x27;", "'")


def line(text):
    m = re.match(r"^(ERROR|WARNING) (\[[a-z]+\]) (line \d+:)?(.*)$", text)
    if m:
        level, rule, path, rest = m.groups()
        cls = "t-err" if level == "ERROR" else "t-dim"
        out = '<span class="%s">%s</span> <span class="t-rule">%s</span> ' % (cls, level, rule)
        if path:
            out += '<span class="t-path">%s</span>' % path
        return out + esc(rest)
    return '<span class="t-dim">%s</span>' % esc(text) if text.strip() else ""


body = '<span class="t-prompt">$</span> petals check hero.html\n'
body += "\n".join(line(t) for t in sys.argv[1].split("\n")) + "\n"
page = open("index.html", encoding="utf-8").read()
start = page.index('<pre class="term-body">') + len('<pre class="term-body">')
end = page.index("</pre>", start)
open("index.html", "w", encoding="utf-8").write(page[:start] + body + page[end:])
