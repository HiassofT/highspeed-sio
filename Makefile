#all: hipatch.atr patchrom patchrom.exe

all: hipatch.atr diag.atr diag-nodma.atr diag-ext.atr diag-ext-nodma.atr patchrom patchrom.exe

ATASM=atasm
ATASMFLAGS=
#ATASMFLAGS=-s
#ATASMFLAGS=-s -v

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=hisio.src hisiocode.src hisiodet.src hisio.inc fastnmi.src

%.com: %.src
	$(ATASM) $(ATASMFLAGS) -o$@ $<

COMS =	hisio.com hisior.com hision.com hisiorn.com \
	hisioi.com hisiori.com hisioni.com hisiorni.com \
	dumpos.com 

hipatch-code-fastnmi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -o$@ -dPATCHKEY=1 -dFASTVBI=1 hipatch-code.src

hipatch-code-rom-fastnmi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -o$@ -dROMABLE=1 -dPATCHKEY=1 -dFASTVBI=1 hipatch-code.src

hipatch-code-fastvbi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -o$@ -dPATCHKEY=1 -dFASTNMI=1 hipatch-code.src

hipatch-code-rom-fastvbi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -o$@ -dROMABLE=1 -dPATCHKEY=1 -dFASTNMI=1 hipatch-code.src


hisio.com: hipatch.src hipatch-code-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dPATCHKEY=1 hipatch.src

hisior.com: hipatch.src hipatch-code-rom-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dROMABLE=1 -dPATCHKEY=1 hipatch.src

hision.com: hipatch.src hipatch-code-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ hipatch.src

hisiorn.com: hipatch.src hipatch-code-rom-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dROMABLE=1 hipatch.src


hisioi.com: hipatch.src hipatch-code-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dPATCHKEY=1 -dPATCHNMI=1 hipatch.src

hisiori.com: hipatch.src hipatch-code-rom-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dROMABLE=1 -dPATCHKEY=1 -dPATCHNMI=1 hipatch.src

hisioni.com: hipatch.src hipatch-code-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dPATCHNMI=1 hipatch.src

hisiorni.com: hipatch.src hipatch-code-rom-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ -dROMABLE=1 -dPATCHNMI=1 hipatch.src


hisio-reloc.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -ohisio-reloc.bin -dRELOCTABLE=1 -dSTART=4096 hisio.src

diag-hias.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-hias.atr diag.src

diag.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr -dSHIPDIAG=1 diag.src

diag-nodma.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-nodma.atr -dSHIPDIAG=2 diag.src

diag-ext.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-ext.atr -dSHIPDIAG=3 diag.src

diag-ext-nodma.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -r -odiag-ext-nodma.atr -dSHIPDIAG=4 diag.src

test.com: test.src hi4000.com
	$(ATASM) $(ATASMFLAGS) -otest1.com test.src
	cat test1.com hi4000.com > test.com
	rm test1.com

hipatch.atr: $(COMS)
	mkdir -p patchdisk
	cp $(COMS) patchdisk
	dir2atr 720 hipatch.atr patchdisk

hicode-fastvbi.h: hipatch-code-rom-fastvbi.bin
	xxd -i hipatch-code-rom-fastvbi.bin > hicode-fastvbi.h

hicode-fastnmi.h: hipatch-code-rom-fastnmi.bin
	xxd -i hipatch-code-rom-fastnmi.bin > hicode-fastnmi.h

patchrom.o: patchrom.cpp patchrom.h hicode-fastnmi.h hicode-fastvbi.h

patchrom: patchrom.o
	$(CXX) -o patchrom patchrom.o

patchrom.exe: patchrom.cpp patchrom.h hicode-fastnmi.h hicode-fastvbi.h
	i586-mingw32msvc-g++ $(CXXFLAGS) -o patchrom.exe patchrom.cpp
	i586-mingw32msvc-strip patchrom.exe

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom
	rm -rf disk patchdisk

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist* *.txt

