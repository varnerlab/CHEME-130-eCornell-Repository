#!/bin/sh

# Clear out junk
# rm -f *aux
# rm -f main.ind
# rm -f main.toc

# Tex this mofo -
pdflatex main.tex
bibtex main
pdflatex main.tex
makeindex main
pdflatex main.tex
bibtex main
pdflatex main.tex

