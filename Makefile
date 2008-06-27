all: hipatch.atr patchrom patchrom.exe

#all: hipatch.atr diag.atr patchrom patchrom.exe

ATASM=atasm
ATASMFLAGS=
#ATASMFLAGS=-s

CFLAGS = -W -Wall -g
CXXFLAGS = -W -Wall -g

HISIOSRC=hisio.src hisiocode.src hisiodet.src hisio.inc

%.com: %.src
	$(ATASM) $(ATASMFLAGS) -o$@ $<

COMS = hisio.com hisior.com hision.com hisiorn.com dumpos.com

hipatch-code-key.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -ohipatch-code-key.bin -dPATCHKEY=1 hipatch-code.src

hipatch-code-rom-key.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -ohipatch-code-rom-key.bin -dROMABLE=1 -dPATCHKEY=1 hipatch-code.src


hipatch-code-nokey.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -ohipatch-code-nokey.bin hipatch-code.src

hipatch-code-rom-nokey.bin: hipatch-code.src hipatch.inc $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -f0 -ohipatch-code-rom-nokey.bin -dROMABLE=1 hipatch-code.src


hisio.com: hipatch.src hipatch-code-key.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohisio.com -dPATCHKEY=1 hipatch.src

hisior.com: hipatch.src hipatch-code-rom-key.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohisior.com -dROMABLE=1 -dPATCHKEY=1 hipatch.src

hision.com: hipatch.src hipatch-code-nokey.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohision.com hipatch.src

hisiorn.com: hipatch.src hipatch-code-rom-nokey.bin hipatch.inc cio.inc
	$(ATASM) $(ATASMFLAGS) -ohisiorn.com -dROMABLE=1 hipatch.src


diag.atr: diag.src $(HISIOSRC)
	$(ATASM) $(ATASMFLAGS) -r -odiag.atr diag.src

test.com: test.src hi4000.com
	$(ATASM) $(ATASMFLAGS) -otest1.com test.src
	cat test1.com hi4000.com > test.com
	rm test1.com

hipatch.atr: $(COMS)
	mkdir -p patchdisk
	cp $(COMS) patchdisk
	dir2atr 720 hipatch.atr patchdisk

hicode-key.h: hipatch-code-rom-key.bin
	xxd -i hipatch-code-rom-key.bin > hicode-key.h

hicode-nokey.h: hipatch-code-rom-nokey.bin
	xxd -i hipatch-code-rom-nokey.bin > hicode-nokey.h

patchrom.o: patchrom.cpp patchrom.h hicode-key.h hicode-nokey.h

patchrom: patchrom.o
	$(CXX) -o patchrom patchrom.o

patchrom.exe: patchrom.cpp patchrom.h hicode-nokey.h hicode-key.h
	i586-mingw32msvc-g++ $(CXXFLAGS) -o patchrom.exe patchrom.cpp
	i586-mingw32msvc-strip patchrom.exe

clean:
	rm -f *.bin *.com *.atr *.o patchrom.exe patchrom
	rm -rf disk patchdisk

backup:
	tar zcf bak/hisio-`date '+%y%m%d-%H%M'`.tgz \
	Makefile *.src *.inc *.cpp *.h mkdist* *.txt

