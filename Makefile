#all: hipatch.atr patchrom patchrom.exe

all: hipatch.atr patchrom patchrom.exe \
 diag-read.atr diag-ext-read.atr diag-hias-read.atr \
 diag-write.atr diag-ext-write.atr diag-hias-write.atr \
 hisioboot.atr hisioboot-atarisio.atr

ATASM ?= atasm
ATASMFLAGS ?=
#ATASMFLAGS=-s
#ATASMFLAGS=-s -v

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

MINGW_CXX=i686-w64-mingw32-g++
MINGW_STRIP=i686-w64-mingw32-strip

HISIOSRC=hisio.src hisiodet.src hisiodetbt.src hisio.inc \
	hisiocode.src \
	hisiocode-break.src hisiocode-cleanup.src hisiocode-main.src \
	hisiocode-send.src hisiocode-check.src hisiocode-diag.src \
	hisiocode-receive.src hisiocode-vbi.src

%.com: %.src
	$(ATASM) $(ATASMFLAGS) -o$@ $<

COMS =	hisio.com hisiok.com \
	hisior.com hisiork.com \
	dumpos.com 

hipatch-code.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTVBI=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src

hipatch-code-rom.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTVBI=1 -dROMABLE=1 -dPATCHKEY=1 -r -o$@ hipatch-code.src

hipatch-code-rom-bt.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dFASTVBI=1 -dROMABLE=1 -dBT=1 -r -o$@ hipatch-code.src

hisio.com: hipatch.src hipatch-code.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHKEY=1 -o$@ $<

hisiok.com: hipatch.src hipatch-code.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -o$@ $<

hisior.com: hipatch.src hipatch-code-rom.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dROMABLE=1 -dPATCHKEY=1 -o$@ $<

hisiork.com: hipatch.src hipatch-code-rom.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dROMABLE=1 -o$@ $<

hisioboot.atr: hipatch.src hipatch-code.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -dPATCHKEY=1 -dATRBOOT=1 -r -o$@ $<

hisioboot-atarisio.atr: hipatch.src hipatch-code.bin hipatch.inc cio.inc atarisio.src
	$(ATASM) $(ATASMFLAGS) -dPATCHKEY=1 -dATRBOOT=1 -dATARISIO_SWAP=1 -r -o$@ $<

diag-hias-read.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -r -o$@ $<

diag-read.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=1 -r -o$@ $<

diag-ext-read.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=2 -r -o$@ $<

diag-write.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=1 -dDIAG_WRITE=1 -r -o$@ $<

diag-ext-write.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dSHIPDIAG=2 -dDIAG_WRITE=1 -r -o$@ $<

diag-hias-write.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -f0 -dDIAG_WRITE=1 -r -o$@ $<

diag-entry.atr: diag-entry.src hisio.inc hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -f0 -r -o$@ $<

test.com: test.src hi4000.com
	$(ATASM) $(ATASMFLAGS) -otest1.com test.src
	cat test1.com hi4000.com > test.com
	rm test1.com

hipatch.atr: $(COMS)
	mkdir -p patchdisk
	cp $(COMS) patchdisk
	dir2atr 720 hipatch.atr patchdisk

hicode.h: hipatch-code-rom.bin
	xxd -i hipatch-code-rom.bin > hicode.h

hicodebt.h: hipatch-code-rom-bt.bin
	xxd -i hipatch-code-rom-bt.bin > hicodebt.h

patchrom.o: patchrom.cpp patchrom.h hicode.h hicodebt.h

patchrom: patchrom.o
	$(CXX) -o patchrom patchrom.o

patchrom.exe: patchrom.cpp patchrom.h hicode.h hicodebt.h
	$(MINGW_CXX) $(CXXFLAGS) -static -o patchrom.exe patchrom.cpp
	$(MINGW_STRIP) patchrom.exe

atarisio: atarisio-highsio.bin

# build with ultraspeed only support
atarisio-highsio.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dUSONLY -dFASTVBI -dRELOCTABLE -dSTART=4096 -o$@ $<

# full highspeed code with FASTVBI, starting at beginning of a page
check-highsio-page.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dFASTVBI -dSTART=4096 -o$@ $<

# full highspeed code with FASTVBI and reloctable, starting at beginning of a page
check-reloctable.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dFASTVBI -dRELOCTABLE -dSTART=4096 -o$@ $<

# highspeed code without hisiodet, starting at $092A
check-mypdos.bin: check-hisiocode.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dFASTVBI -dSTART=\$$092A -r -o$@ $<

# full code without clock adjust, starting at $4009
check-thecart.bin: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dFASTVBI -dFASTVBI_NOCLOCK -dMAXDRIVENO=15 -dSTART=\$$04009 -r -o$@ $<

check: hipatch-code.bin hipatch-code-rom.bin hipatch-code-rom-bt.bin \
	atarisio-highsio.bin \
	check-highsio-page.bin \
	check-reloctable.bin \
	check-mypdos.bin \
	check-thecart.bin

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom
	rm -rf disk patchdisk

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist* *.txt

