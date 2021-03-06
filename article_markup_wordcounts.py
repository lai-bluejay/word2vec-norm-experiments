import sys

print r"""\begin{center}
\begin{tabular}{l | r}
word & frequency \\
\hline"""
wcs = []
for line in sys.stdin:
    word, count = line.strip().split(',')
    wcs.append((word, int(count)))
for word, count in sorted(wcs, key=lambda (w, c): c):
    print r'\word{%s} & %s \\' % (word, count)
print r"""\end{tabular}
\end{center}"""
