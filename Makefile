# Makefile for ThuThesis
# $Id: Makefile 99 2006-06-21 08:05:44Z littleleo $


SRCPATH = fig plot 

MAKEFUNC = @MakeSubDir() \
{ \	
for DIR in `ls|grep -v 'include'|grep -v 'lib'|grep -v 'bin'| grep -v 'include'`; do \
if [ -d $${DIR} ]; then \
cd $${DIR}; \
MakeSubDir; \
if [ -f makefile -o -f Makefile ]; then \
echo ""; \
pwd; \
make $(1); \
if [ "$$?" != "0" ]; then \
exit 1; \
fi; \
fi; \
cd ..; \
fi; \
done; \
if [ -f makefile -o -f Makefile ]; then \
echo ""; \
pwd; \
make $(1); \
if [ "$$?" != "0" ]; then \
exit 1; \
fi; \
fi; \
}; \

MAKEME = cd $(2); MakeSubDir $(1); cd ..;

LOOPMAKEFUNC = $(MAKEFUNC) $(foreach dir,$(SRCPATH),$(call MAKEME,$(1),$(dir)))

ifeq ($(MAKE),)
	override MAKE=make
endif

ifeq ($(TEXI2DVI),)
	override TEXI2DVI=texi2dvi
endif

ifneq ($(METHOD),ps2pdf)
ifneq ($(METHOD),dvipdfm)
    override METHOD=ps2pdf
endif
endif

PACKAGE=zjuthesis
SOURCES=$(PACKAGE).ins $(PACKAGE).dtx 
THESISMAIN=main
THESISCONTENTS=$(THESISMAIN).tex data/*.tex
BIBFILE=$(PACKAGE).bib
#SHUJIMAIN=shuji
#SHUJICONTENTS=$(SHUJIMAIN).tex


.PHONY: all clean distclean all doc cls cfg dvi ps pdf

all: doc-pdf


###### generate cls/cfg
#cls: $(PACKAGE).cls

#$(PACKAGE).cls:	$(SOURCES)
#	rm -f $(PACKAGE).cls $(PACKAGE).cfg
#	elatex $(PACKAGE).ins

###### for doc

doc: selectable

doc-pdf: $(PACKAGE).pdf

pro: zjuproposal.pdf

#doc-dvi: $(PACKAGE).dvi

#doc-ps: $(PACKAGE).ps

#$(PACKAGE).dvi: $(PACKAGE).bbl
#	latex  $(PACKAGE).tex

$(PACKAGE).pdf: *.tex *.bib
	latex $(PACKAGE)
	bibtex $(PACKAGE)
	latex $(PACKAGE)
	gbk2uni $(PACKAGE)
	latex $(PACKAGE)
	evince $(PACKAGE).pdf
zjuproposal.pdf: proposalcontents.tex zjuproposal.tex proposalcover.tex
	latex zjuproposal
	bibtex zjuproposal
	latex zjuproposal
	gbk2uni zjuproposal
	latex zjuproposal
	evince zjuproposal.pdf
selectable: *.tex *.bib
	elatex $(PACKAGE).tex
	bibtex $(PACKAGE)
	elatex $(PACKAGE).tex
	gbk2uni $(PACKAGE)
	elatex $(PACKAGE).tex
	dvipdfmx $(PACKAGE).dvi
	evince $(PACKAGE).pdf

#dvips -Ppdf -G0 $(PACKAGE).dvi

$(PACKAGE).bbl: $(BIBFILE)
	$(TEXI2DVI) $(PACKAGE).tex
	bibtex $(PACKAGE)


###### for thesis

thesis: thesis-pdf

thesis-pdf: $(THESISMAIN).pdf

thesis-dvi: $(THESISMAIN).dvi

thesis-ps: $(THESISMAIN).ps

$(THESISMAIN).dvi:  $(THESISCONTENTS) $(THESISMAIN).bbl
	$(TEXI2DVI) $(THESISMAIN).tex

ifeq ($(METHOD),dvipdfm)
$(THESISMAIN).pdf: $(THESISMAIN).dvi
	gbk2uni $(THESISMAIN)
	latex $(THESISMAIN).tex
	dvipdfm $(THESISMAIN).dvi
else
$(THESISMAIN).pdf: $(THESISMAIN).ps
	ps2pdf $(THESISMAIN).ps
endif

$(THESISMAIN).ps: $(THESISMAIN).dvi
	gbk2uni $(THESISMAIN)
	latex $(THESISMAIN).tex
	dvips -Ppdf -G0 $(THESISMAIN).dvi

$(THESISMAIN).bbl: $(BIBFILE)
	$(TEXI2DVI) $(THESISMAIN).tex
	-bibtex $(THESISMAIN)



clean:
	-@rm -f \
		*.aux \
		*.bak \
		*.bbl \
		*.blg \
		*.cls \
		*.cfg \
		*.dvi \
		*.glo \
		*.gls \
		*.idx \
		*.ilg \
		*.ind \
		*.ist \
		*.log \
		*.out \
		*.ps \
		*.thm \
		*.toc \
		*.lof \
		*.lot \
		*.loe \
		*.pdf \
		data/*.aux

distclean: clean
	-@rm -f *.pdf *.tar.gz

dist:
	@if [ -z "$(VERSION)" ]; then \
	    echo "Usage: make dist VERSION=<version#>"; \
	else \
	    ./makedist.sh $(VERSION); \
	fi	
