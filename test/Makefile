all: diag.atr diagt.atr shawn.atr

ATASM=atasm
#ATASMFLAGS=
ATASMFLAGS=-s -I..

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=../hisio.src ../hisiocode.src ../hisiodet.src ../hisio.inc

diag.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr diag.src

diagt.atr: diagt.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiagt.atr diagt.src

shawn.atr: shawn.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -oshawn.atr shawn.src

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist*

