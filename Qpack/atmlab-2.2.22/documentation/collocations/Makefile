TARGET=collocations

.PHONY: ${TARGET}.pdf
#${TARGET}.ps: ${TARGET}.dvi ${TARGET}.tex 
#	dvips ${TARGET}.dvi -o ${TARGET}.ps

${TARGET}.pdf: ${TARGET}.tex
	pdflatex -shell-escape -halt-on-error ${TARGET}
	bibtex ${TARGET}
	makeglossaries ${TARGET}
	pdflatex -shell-escape -halt-on-error ${TARGET}
	pdflatex -shell-escape -halt-on-error ${TARGET}
clean:
	rm -f ${TARGET}.acr ${TARGET}.acn ${TARGET}.alg ${TARGET}.aux ${TARGET}.bbl ${TARGET}.blg ${TARGET}.glo ${TARGET}.glg ${TARGET}.gls ${TARGET}.ist ${TARGET}.lof ${TARGET}.log  ${TARGET}.lot ${TARGET}.out ${TARGET}.pdf ${TARGET}.toc



