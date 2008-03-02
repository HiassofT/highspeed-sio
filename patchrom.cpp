/*
   patchrom - patch existing ROM file with highspeed SIO code
   (c) 2006 by Matthias Reichl <hias@horus.com>

   V1.0 2006-06-22
*/

#include <stdio.h>
#include <string.h>

#include "patchrom.h"
#include "hicode.h"

static unsigned char rombuf[ROMLEN];

#define origcode_len 4
static unsigned char origcode[origcode_len] = {
	0xba, // TSX
	0x8e, // STX $0318
	0x18,
	0x03 };

#define newcode_len 4
static unsigned char newcode[newcode_len] = {
	0xea, // NOP
	0x4c, // JMP
	HISIO & 0xff,
	HISIO >> 8 };

#define oldcode_len 3
static unsigned char oldcode[oldcode_len] = {
	0x4c, // JMP
	(XLSIO+4) & 0xff,
	(XLSIO+4) >> 8 };

#define CSUM1_ADR 0xC000
#define CSUM2_ADR 0xFFF8

static void update_checksum_block(unsigned int start, unsigned int end, unsigned int& csum)
{
	unsigned int i;
	for (i=start; i<=end; i++) {
		csum += rombuf[i - ROMBASE];
	}
	csum &= 0xffff;
}

static unsigned int get_csum1()
{
	unsigned int csum = 0;
	update_checksum_block(0xC002, 0xDFFF, csum);
	return csum;
}

static unsigned int get_csum2()
{
	unsigned int csum = 0;
	update_checksum_block(0xE000,0xFFF7, csum);
	update_checksum_block(0xFFFA,0xFFFF, csum);
	return csum;
}

/* check if the ROM checksums are OK */
static bool rom_checksums_ok()
{
	unsigned int csum;

	csum = get_csum1();
	if (rombuf[CSUM1_ADR - ROMBASE] != (csum & 0xff) ||
	    rombuf[CSUM1_ADR +1 - ROMBASE] != (csum >> 8)) {
	       return false;
	}

	csum = get_csum2();
	if (rombuf[CSUM2_ADR - ROMBASE] != (csum & 0xff) ||
	    rombuf[CSUM2_ADR +1 - ROMBASE] != (csum >> 8)) {
	       return false;
	}
	return true;
}

static void update_rom_checksums()
{
	unsigned int csum;

	csum = get_csum1();
	rombuf[CSUM1_ADR - ROMBASE] = csum & 0xff;
	rombuf[CSUM1_ADR +1 - ROMBASE] = csum >> 8;

	csum = get_csum2();
	rombuf[CSUM2_ADR - ROMBASE] = csum & 0xff;
	rombuf[CSUM2_ADR +1 - ROMBASE] = csum >> 8;
}

static bool check_already_patched()
{
	return memcmp(newcode, rombuf + XLSIO - ROMBASE, newcode_len) == 0;
}

int main(int argc, char** argv)
{
	char* origfile;
	char* newfile;
	bool need_csum_update;

	printf("patchrom V1.0 (c) 2006 Matthias Reichl <hias@horus.com>\n");

	if (argc != 3) {
		goto usage;
	}
	origfile = argv[1];
	newfile = argv[2];

	FILE* f;
	if (!(f=fopen(origfile,"rb"))) {
		printf("cannot open %s\n", origfile);
		return 1;
	}

	if (fread(rombuf, 1, ROMLEN, f) != ROMLEN) {
		printf("error reading %s\n", origfile);
		fclose(f);
		return 1;
	}
	fclose(f);
	if (check_already_patched()) {
		printf("%s is already patched\n", origfile);
		return 1;
	}
	if (memcmp(rombuf + XLSIO - ROMBASE, origcode, origcode_len)) {
		printf("incompatible OS\n");
		return 1;
	}
	need_csum_update = rom_checksums_ok();

	// copy highspeed SIO code to ROM OS
	memset(rombuf + HIBASE - ROMBASE, 0, HILEN);
	memcpy(rombuf + HIBASE - ROMBASE, hipatch_code_rom_bin, hipatch_code_rom_bin_len);

	// copy old standard SIO code to highspeed SIO code
	memcpy(rombuf + HISTDSIO - ROMBASE, rombuf + XLSIO - ROMBASE, newcode_len);

	// add "jump to old code + 4"
	memcpy(rombuf + HISTDSIO + newcode_len - ROMBASE, oldcode, oldcode_len);

	// change old SIO code
	memcpy(rombuf + XLSIO - ROMBASE, newcode, newcode_len);

	if (need_csum_update) {
		//printf("updating ROM checksums\n");
		update_rom_checksums();
		if (!rom_checksums_ok()) {
			printf("internal error - updating ROM checksums failed!\n");
			return 1;
		}
	}

	if (!(f = fopen(newfile, "wb"))) {
		printf("cannot create %s\n", newfile);
		return 1;
	}
	if (fwrite(rombuf, 1, ROMLEN, f) != ROMLEN) {
		printf("error writing %s\n", newfile);
		return 1;
	}
	fclose(f);
	printf("successfully created patched ROM %s\n", newfile);
	return 0;

	return 0;
usage:
	printf("usage: patchrom original.rom new.rom\n");
	return 1;
}
