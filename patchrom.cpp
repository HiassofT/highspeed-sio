/*
   patchrom - patch existing ROM file with highspeed SIO code

   (c) 2006-2023 by Matthias Reichl <hias@horus.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
 
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

#include <stdio.h>
#include <string.h>
#include <getopt.h>

#include "patchrom.h"
#include "hicode.h"
#include "hicode-sio2bt.h"

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
static unsigned char xl_oldcode[oldcode_len] = {
	0x4c, // JMP
	(XL_SIO+4) & 0xff,
	(XL_SIO+4) >> 8 };

static unsigned char old_oldcode[oldcode_len] = {
	0x4c, // JMP
	(OLD_SIO+4) & 0xff,
	(OLD_SIO+4) >> 8 };

#define keycode_len 3
static unsigned char orig_keycode[keycode_len] = {
	0xad, // LDA
	0x09, // D209
	0xd2};

static unsigned char new_keycode[keycode_len] = {
	0x20, // JSR
	PKEYIRQ & 0xff,
	PKEYIRQ >> 8 };

#define powerupcode_len 3
static unsigned char orig_powerupcode[powerupcode_len] = {
	0xad, // LDA
	0x3D, // 033D
	0x03};

/* powerupcode: check if SHIFT is pressed during reset,
   if yes do: do a cold boot */
static unsigned char new_powerupcode[powerupcode_len] = {
	0x4C, // JMP
	PUPCODE & 0xff,
	PUPCODE >> 8 };

#define origPHRcode_len 4
static unsigned char origPHRcode[origPHRcode_len] = {
	0xa5,   // LDA
	0x08,   // WARMST
	0xf0,   // BEQ
	0x25 }; // PHR2

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
static bool rom_checksums_ok(bool is_xl, bool verbose = false)
{
	unsigned int csum, csum_calc;
	bool ok = true;

	if (!is_xl) {
		if (verbose) {
			printf("verifying 10k rev A/B checksums isn't implemented yet\n");
		}
		return false; // not implemented yet
	}

	csum = rombuf[CSUM1_ADR - ROMBASE] | (rombuf[CSUM1_ADR + 1 - ROMBASE] << 8);
	csum_calc = get_csum1();

	if (verbose) {
		printf("checksum at %04X: %04X", CSUM1_ADR, csum);
	}
	if (csum == csum_calc) {
		if (verbose) {
			printf(" OK\n");
		}
	} else {
		if (verbose) {
			printf(" ERROR, should be %04X\n", csum_calc);
		}
		ok = false;
	}

	csum = rombuf[CSUM2_ADR - ROMBASE] | (rombuf[CSUM2_ADR + 1 - ROMBASE] << 8);
	csum_calc = get_csum2();

	if (verbose) {
		printf("checksum at %04X: %04X", CSUM2_ADR, csum);
	}
	if (csum == csum_calc) {
		if (verbose) {
			printf(" OK\n");
		}
	} else {
		if (verbose) {
			printf(" ERROR, should be %04X\n", csum_calc);
		}
		ok = false;
	}

	return ok;
}

static void update_rom_checksums(bool is_xl)
{
	unsigned int csum;

	if (!is_xl) {
		return; // not implemented yet
	}

	csum = get_csum1();
	rombuf[CSUM1_ADR - ROMBASE] = csum & 0xff;
	rombuf[CSUM1_ADR +1 - ROMBASE] = csum >> 8;

	csum = get_csum2();
	rombuf[CSUM2_ADR - ROMBASE] = csum & 0xff;
	rombuf[CSUM2_ADR +1 - ROMBASE] = csum >> 8;
}

static int fix_checksum(bool is_xl, const char* outfile) {
	if (!is_xl) {
		printf("fixing 10k rev A/B checksums isn't implemented yet\n");
		return 1;
	}

	update_rom_checksums(is_xl);
	if (!rom_checksums_ok(is_xl)) {
		printf("internal error - updating ROM checksums failed!\n");
		return 1;
	}

	FILE* f;
	if (!(f = fopen(outfile, "wb"))) {
		printf("cannot create %s\n", outfile);
		return 1;
	}
	if (fwrite(rombuf, 1, ROMLEN, f) != ROMLEN) {
		printf("error writing %s\n", outfile);
		fclose(f);
		return 1;
	}
	fclose(f);
	printf("successfully created ROM %s\n", outfile);
	return 0;
}

static bool check_already_patched()
{
	return (memcmp(newcode, rombuf + XL_SIO - ROMBASE, newcode_len) == 0)
	       || (memcmp(newcode, rombuf + OLD_SIO - ROMBASE, newcode_len) == 0);
}

int main(int argc, char** argv)
{
	char* origfile;
	char* newfile;
	bool need_csum_update;
	bool force_csum_update = false;

	bool patch_keyirq = true;
	bool patch_powerup = true;
	bool sio2bt = false;

	unsigned int sio_address;
	unsigned int key_address;
	unsigned int powerup_address;

	unsigned char* old_siocode;
	bool is_xl = true;

	int opt;
	size_t read_len;

	enum EOpMode {
		eOpPatch,
		eOpVerifyChecksum,
		eOpFixChecksum
	};

	EOpMode opmode = eOpPatch;

	printf("patchrom V1.33 (c) 2006-2023 Matthias Reichl <hias@horus.com>\n");

	while ((opt = getopt(argc, argv, "bcCfkp")) != -1) {
		switch(opt) {
		case 'b':
			sio2bt = true;
			break;
		case 'c':
			opmode = eOpVerifyChecksum;
			break;
		case 'C':
			opmode = eOpFixChecksum;
			break;
		case 'f':
			force_csum_update = true;
			break;
		case 'k':
			patch_keyirq = false;
			break;
		case 'p':
			patch_powerup = false;
			break;
		}
	}

	switch (opmode) {
	case eOpVerifyChecksum:
		if (argc != optind+1) {
			goto usage;
		}
		origfile = argv[optind++];
		newfile = NULL;
		break;
	default:
		if (argc != optind+2) {
			goto usage;
		}
		origfile = argv[optind++];
		newfile = argv[optind++];
		break;
	}

	FILE* f;
	if (!(f=fopen(origfile,"rb"))) {
		printf("cannot open %s\n", origfile);
		return 1;
	}

	is_xl = true;

	if ((read_len = fread(rombuf, 1, ROMLEN, f)) != ROMLEN) {
		if (read_len == ROMLEN_OSA) {
			printf("input ROM file is old 10k OS rev. A or B\n");
			unsigned char tmpbuf[ROMLEN_OSA];
			memcpy(tmpbuf, rombuf, ROMLEN_OSA);
			memset(rombuf, 0xff, ROMLEN);
			memcpy(rombuf+ROMBASE_OSA-ROMBASE, tmpbuf, ROMLEN_OSA);
			is_xl = false;
		} else {
			printf("error reading %s\n", origfile);
			fclose(f);
			return 1;
		}
	}
	fclose(f);

	switch (opmode) {
	case eOpVerifyChecksum:
		return rom_checksums_ok(is_xl, true);
	case eOpFixChecksum:
		return fix_checksum(is_xl, newfile);
	default:
		break;
	}

	if (check_already_patched()) {
		printf("%s is already patched\n", origfile);
		return 1;
	}
	if (is_xl && memcmp(rombuf + XL_SIO - ROMBASE, origcode, origcode_len) == 0) {
		sio_address = XL_SIO;
		old_siocode = xl_oldcode;
		key_address = XL_KEYIRQ;
		powerup_address = XL_PUPCODE;
	} else {
		if (memcmp(rombuf + OLD_SIO - ROMBASE, origcode, origcode_len) == 0) {
			is_xl = false;
			sio_address = OLD_SIO;
			old_siocode = old_oldcode;
			key_address = OLD_KEYIRQ;
		} else {
			printf("incompatible OS\n");
			return 1;
		}
	}
	if (!is_xl) {
		if (patch_powerup) {
			printf("detected old OS, not patching powerup/reset code\n");
			patch_powerup = false;
		}
	}

	if (is_xl) {
		need_csum_update = rom_checksums_ok(is_xl);
		if (!need_csum_update && force_csum_update) {
			need_csum_update = true;
			printf("wrong checksum in input ROM, update forced\n");
		}
	} else {
		need_csum_update = false;
	}

	// copy highspeed SIO code to ROM OS
	memset(rombuf + HIBASE - ROMBASE, 0, HILEN);
	if(sio2bt)
	{
		memcpy(rombuf + HIBASE - ROMBASE, hipatch_code_rom_sio2bt_bin, hipatch_code_rom_sio2bt_bin_len);
		if (memcmp(rombuf + PHR - ROMBASE, origPHRcode, origPHRcode_len) == 0) {
			rombuf[PHR - ROMBASE] = 0x60; // RTS
			printf("disabled PHR (for SIO2BT)\n");
		}
		printf("patched SIO2BT highspeed code\n");
	}
	else
	{
		memcpy(rombuf + HIBASE - ROMBASE, hipatch_code_rom_bin, hipatch_code_rom_bin_len);
	}

	// copy old standard SIO code to highspeed SIO code
	memcpy(rombuf + HISTDSIO - ROMBASE, rombuf + sio_address - ROMBASE, newcode_len);

	// add "jump to old code + 4"
	memcpy(rombuf + HISTDSIO + newcode_len - ROMBASE, old_siocode, oldcode_len);

	// change old SIO code
	memcpy(rombuf + sio_address - ROMBASE, newcode, newcode_len);

	// patch keyboard IRQ handler
	if (patch_keyirq && !sio2bt) {
		if (memcmp(rombuf + key_address -  ROMBASE, orig_keycode, keycode_len) == 0) {
			memcpy(rombuf + key_address -  ROMBASE, new_keycode, keycode_len);
			printf("patched keyboard IRQ handler\n");
		} else {
			printf("unknown OS, not patching keyboard IRQ handler\n");
		}
	}

	if (patch_powerup) {
		if (memcmp(rombuf + powerup_address -  ROMBASE, orig_powerupcode, powerupcode_len) == 0) {
			memcpy(rombuf + powerup_address -  ROMBASE, new_powerupcode, powerupcode_len);
			printf("patched powerup/reset code\n");
		} else {
			printf("unknown OS, not patching powerup/reset code\n");
		}
	}

	if (need_csum_update) {
		update_rom_checksums(is_xl);
		if (!rom_checksums_ok(is_xl)) {
			printf("internal error - updating ROM checksums failed!\n");
			return 1;
		}
		printf("updated ROM checksums\n");
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
	printf("usage: patchrom [-bcCfkp]] original.rom [new.rom]\n");
	printf("options:\n");
	printf("  -b  SIO2BT support (disables keyboard IRQ handler)\n");
	printf("  -c  don't patch, only verify XL/XE ROM checksums\n");
	printf("  -C  don't patch, only update XL/XE ROM checksums\n");
	printf("  -f  force ROM checksum update\n");
	printf("  -k  don't patch keyboard IRQ handler\n");
	printf("  -p  don't patch powerup/reset code\n");
	return 1;
}
