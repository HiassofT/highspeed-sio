#all: coms diag.atr

#all: coms patchrom
all: coms hisio.atr hipatch.atr diag.atr patchrom patchrom.exe
all: hipatch.atr patchrom patchrom.exe

ATASM=atasm
#ATASMFLAGS=
ATASMFLAGS=-s

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=hisio.src hisiocode.src hisiodet.src hisio.inc

%.com: %.src
	$(ATASM) $(ATASMFLAGS) -o$@ $<

coms: hipatch.com hipatchr.com dumpos.com
#coms: hi4000.com hi5000.com hi6000.com hi7000.com hipatch.com dumpos.com

hi4000.com: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dSTART=16384 -ohi4000.com hisio.src

hi5000.com: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dSTART=20480 -ohi5000.com hisio.src

hi6000.com: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dSTART=24576 -ohi6000.com hisio.src

hi7000.com: $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -dSTART=28672 -ohi7000.com hisio.src

hipatch-code.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -ohipatch-code.bin hipatch-code.src

hipatch.com: hipatch.src hipatch-code.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohipatch.com hipatch.src

hipatch-code-rom.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -ohipatch-code-rom.bin -dROMABLE=1 hipatch-code.src

hipatchr.com: hipatch.src hipatch-code-rom.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohipatchr.com -dROMABLE=1 hipatch.src

diag.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr diag.src

test.com: test.src hi4000.com
	$(ATASM) $(ATASMFLAGS) -otest1.com test.src
	cat test1.com hi4000.com > test.com
	rm test1.com

hisio.atr: test.com coms
	cp hi*.com test.com disk
	dir2atr 720 hisio.atr disk

hipatch.atr: hipatch.com hipatchr.com dumpos.com
	cp hipatch.com hipatchr.com dumpos.com patchdisk
	dir2atr 720 hipatch.atr patchdisk

hicode.h: hipatch-code-rom.bin
	xxd -i hipatch-code-rom.bin > hicode.h

patchrom.o: patchrom.cpp patchrom.h hicode.h

patchrom: patchrom.o
	$(CXX) -o patchrom patchrom.o

patchrom.exe: patchrom.cpp patchrom.h hicode.h
	i586-mingw32msvc-g++ $(CXXFLAGS) -o patchrom.exe patchrom.cpp
	i586-mingw32msvc-strip patchrom.exe

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist*

