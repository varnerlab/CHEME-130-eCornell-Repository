#!/bin/sh

# Clear out junk
rm -f *aux

# Tex this mofo -
pdflatex Advanced.tex
bibtex Advanced
pdflatex Advanced.tex
makeindex Advanced
pdflatex Advanced.tex
bibtex Advanced
pdflatex Advanced.tex