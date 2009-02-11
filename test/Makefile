all: diag.atr diagt.atr commands.atr testov.atr

ATASM=atasm
#ATASMFLAGS=
ATASMFLAGS=-s -I..

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=../hisio.src ../hisiocode.src ../hisiodet.src ../hisio.inc

diag.atr: diag.src $(HISIOSRC) fastvbi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr diag.src

diagt.atr: diagt.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiagt.atr diagt.src

commands.atr: commands.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -ocommands.atr commands.src

testov.atr: testov.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -otestov.atr testov.src


clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist*

