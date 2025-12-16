all:
	latexmk -pdf

clean:
	latexmk -c

cleanall:
	latexmk -C
	rm -rf _minted-*
