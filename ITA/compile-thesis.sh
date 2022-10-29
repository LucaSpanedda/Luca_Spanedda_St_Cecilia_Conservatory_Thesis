#! usr/bin/bash
printf "compiling the thesis, the bibliography, and again the thesis..."
pdflatex thesisCASes.tex
biber thesisCASes
pdflatex thesisCASes.tex
var=$(date +"%FORMAT_STRING")
now=$(date +"%m_%d_%Y")
printf "%s\n" $now
mv thesisCASes.pdf $now"-thesisCASes".pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$now"-compressed-thesisCASes".pdf $now"-thesisCASes".pdf
rm -r $now"-thesisCASes".pdf
mv $now"-compressed-thesisCASes".pdf thesis-pdf