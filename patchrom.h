/*
  patchrom.h - settings and addresses for ROM update
*/

/* base address of OS ROM */
#define ROMBASE 0xC000

/* length of OS ROM - 16k */
#define ROMLEN 16384

/* base address for highspeed SIO code */
#define HIBASE 0xCC00

/* length of highspeed SIO code block */
#define HILEN 0x0400

/* buffer for storing the old SIO code */
#define HISTDSIO 0xCC10

/* entry point for new highspeed SIO code */
#define HISIO 0xCC20

/* address of SIO code in ROM */
#define XLSIO 0xE971

