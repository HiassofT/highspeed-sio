;  hipatch - 6502 high speed SIO code OS patch program
;
;  Copyright (c) by ABBUC e.V. (www.abbuc.de) and Matthias Reichl
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

.if .def ROMABLE
  RAMBUF = $0100
.else
  RAMBUF = $CC00
.endif

SIOSPEED = RAMBUF	; speed byte for current operation
SPEEDTB	= RAMBUF+1	; 8-byte table for drive speeds

.if .def PATCHKEY
  ; add a config byte to enable/disable highspeed SIO with keyboard
  HIENAB = RAMBUF+9
  HIBUF = RAMBUF+10	; .. RAMBUF+13 (4 bytes for get status)
.else
  HIBUF = RAMBUF+9	; .. RAMBUF+12
.endif

; address of reset handler
.if .def ROMABLE
  RESETAD = HIBUF+4	; after end of highspeed SIO data
.else
  RESETAD = $0100	; at beginning of page 1
.endif

PDEST = $CC00		; starting address of code patch
PSTD = $CC10		; original SIO code + JMP back
PSIO = $CC20		; start of new highspeed code

.if .def PATCHKEY
PKEY = $CFA0		; new keyboard IRQ handler

KEYIRQ  = $FC20 	; this contains "LDA $D209"
.endif

PNMI = $CF48		; new NMI handler

PVER = $CFF0		; 16 bytes version string
