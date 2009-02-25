all: diag.atr diagt.atr diag-ext.atr diag-hias.atr commands.atr testov.atr testsend.atr

ATASM=atasm
ATASMFLAGS=-I..
#ATASMFLAGS=-s -I..

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=../hisio.src ../hisiocode.src ../hisiodet.src ../hisio.inc

diag-hias.atr: ../diag.src $(HISIOSRC) fastvbi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-hias.atr ../diag.src

diag.atr: ../diag.src $(HISIOSRC) fastvbi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr -dSHIPDIAG=1 ../diag.src

diag-ext.atr: ../diag.src $(HISIOSRC) fastvbi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-ext.atr -dSHIPDIAG=2 ../diag.src

diagt.atr: diagt.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiagt.atr diagt.src

commands.atr: commands.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -ocommands.atr commands.src

testov.atr: testov.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -otestov.atr testov.src

testsend.atr: testsend.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -otestsend.atr testsend.src


clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist*

