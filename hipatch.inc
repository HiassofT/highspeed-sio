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
  .if .def PATCHKEY
    RESETAD = $010E
  .else
    RESETAD = $010D
  .endif
.else
  RAMBUF = $CC00
  RESETAD = $0100
.endif

SIOSPEED = RAMBUF
SPEEDTB	= RAMBUF+1
HIBUF	= RAMBUF+9	; .. RAMBUF+12 (4 bytes for get status)

.if .def PATCHKEY
; add a config byte to enable/disable highspeed SIO with keyboard
HIENAB	= RAMBUF+12
.else
.endif

PDEST = $CC00
PSTD = $CC10
PSIO = $CC20

.if .def PATCHKEY
; patched keyboard IRQ handler
PKEY = $CF80

KEYIRQ  = $FC20 ; this contains "LDA $D209"
KEYIRQ2 = $FC23 ; next instruction of IRQ handler
.endif

PVER = $CFF0
