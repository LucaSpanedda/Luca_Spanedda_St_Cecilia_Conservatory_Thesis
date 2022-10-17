#! usr/bin/bash
# compile and open the thesis
pdflatex main.tex
biber main
pdflatex main.tex
chromium main.pdf
