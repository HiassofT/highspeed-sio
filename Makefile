#all: hipatch.atr patchrom patchrom.exe

all: hipatch.atr patchrom patchrom.exe \
 diag.atr diag-nonmi.atr diag-ext.atr diag-ext-nonmi.atr diag-hias.atr

ATASM=atasm
ATASMFLAGS=
#ATASMFLAGS=-s
#ATASMFLAGS=-s -v

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=hisio.src hisiocode.src hisiodet.src hisio.inc fastnmi.src

%.com: %.src
	$(ATASM) $(ATASMFLAGS) -o$@ $<

COMS =	hisio.com hisiok.com hisiokn.com hision.com \
	hisior.com hisiork.com hisiorkn.com hisiorn.com \
	dumpos.com 

hipatch-code-fastnmi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTNMI=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src

hipatch-code-rom-fastnmi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTNMI=1 -dROMABLE=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src

hipatch-code-fastvbi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTVBI=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src

hipatch-code-rom-fastvbi.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTVBI=1 -dROMABLE=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src


hisio.com: hipatch.src hipatch-code-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHNMI=1 -dPATCHKEY=1 -o$@ $<

hisiok.com: hipatch.src hipatch-code-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHNMI=1 -o$@ $<

hision.com: hipatch.src hipatch-code-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHKEY=1 -o$@ $<

hisiokn.com: hipatch.src hipatch-code-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ $<

hisior.com: hipatch.src hipatch-code-rom-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHNMI=1 -dROMABLE=1 -dPATCHKEY=1 -o$@ $<

hisiork.com: hipatch.src hipatch-code-rom-fastnmi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHNMI=1 -dROMABLE=1 -o$@ $<

hisiorn.com: hipatch.src hipatch-code-rom-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dROMABLE=1 -dPATCHKEY=1 -o$@ $<

hisiorkn.com: hipatch.src hipatch-code-rom-fastvbi.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dROMABLE=1 -o$@ $<



hisio-reloc.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dRELOCTABLE=1 -dSTART=4096 -o$@ hisio.src

hisio-reloc-fastvbi.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dRELOCTABLE=1 -dSTART=4096 -dFASTVBI=1 -o$@ hisio.src

diag-hias.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -f0 -r -o$@ $<

diag.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=1 -r -o$@ $<

diag-nonmi.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=2 -r -o$@ $<

diag-ext.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=3 -r -o$@ $<

diag-ext-nonmi.atr: diag.src $(HISIOSRC) fastnmi.src
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=4 -r -o$@ $<

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

atarisio: highsio-atarisio.bin

highsio-atarisio.bin: hisio.src hisio.inc hisiocode.src hisiodet.src
	$(ATASM) $(ATASMFLAGS) -dFASTVBI -dRELOCTABLE -dSTART=4096 -o$@ $<

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom
	rm -rf disk patchdisk

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist* *.txt

