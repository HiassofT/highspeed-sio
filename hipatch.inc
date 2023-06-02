;  hipatch - 6502 high speed SIO code OS patch program
;
;  Copyright (c) 2006-2023 by Matthias Reichl <hias@horus.com>
;
;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program; if not, write to the Free Software
;  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;

; indicate we are building the OS ROM PATCH
HIPATCH = 1

.if .def ROMABLE
  RAMBUF = $0108	; leave the first 8 bytes at page 1 free, some programs use them
.else
  RAMBUF = $CC00
.endif

SIOSPEED = RAMBUF	; speed byte for current operation
SPEEDTB	= RAMBUF+1	; 8-byte table for drive speeds

.if .def SIO2BT
SPEEDTBSIZE = 4     ; SPEEDTB size, table for device speeds has only 4-bytes (when SIO2BT defined)!
BT576K = $08        ; HS Index for 57.600 Baud
DEVICETB = RAMBUF+5	; 4-byte table for last accessed devices
.endif

.if .def PATCHKEY
  ; add a config byte to enable/disable highspeed SIO with keyboard
  HIENAB = RAMBUF+9
  HIBUF = RAMBUF+10	; .. RAMBUF+13 (4 bytes for get status)
.else
  HIBUF = RAMBUF+9	; .. RAMBUF+12
.endif

.if .def SIO2BT
NEXTSPEEDSLOT = HIBUF+4
.endif

; address of reset handler
.if .def ROMABLE
    .if .def SIO2BT
      RESETAD = NEXTSPEEDSLOT+1
    .else
      RESETAD = HIBUF+4	; after end of highspeed SIO data
    .endif
.else
  RESETAD = $0108	; (almost) at beginning of page 1
.endif

PDEST	= $CC00		; starting address of code patch
PSTD	= $CC10		; original SIO code + JMP back
PPWRUP	= $CC18		; powerup-code, checking for SHIFT (=cold boot)

PSIO	= $CC30		; start of new highspeed code

; power-up code
PUPCODE	= $C2B3		; this contains "LDA $033D"

; PNMI	= $CF68		; new NMI handler

.if .def PATCHKEY
PKEY	= $CFB7		; new keyboard IRQ handler

KEYIRQ  = $FC20 	; this contains "LDA $D209"
.endif

PHISIO	= $CFED		; direct entry to hisio code
			; A needs to be set to highspeed mode/divisor
PVER = $CFF0		; 16 bytes version string
