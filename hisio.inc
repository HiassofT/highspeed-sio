;  highsio.inc - definitions for highspeed SIO code
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

	POKMSK = $10

	STATUS = $30
	CHKSUM = $31
	BUFRLO = $32
	BUFRHI = $33
	BFENLO = $34
	BFENHI = $35
	CRETRY = $36
	DRETRY = $37

	FTYPE = $3E
	FEOF = $3F

	SOUNDR = $41
	CRITIC = $42

	CDTMV1 = $218
	
	CDTMA1 = $226
	CDEVIC = $23A
	CCOMND = $23B
	CAUX1 = $23C
	CAUX2 = $23D

	DUNIT = $301
	DCOMND = $302
	DSTATS = $303
	DBUFLO = $304
	DBUFHI = $305
	DTIMLO = $306
	DBYTLO = $308
	DBYTHI = $309
	DAUX1 = $30A
	DAUX2 = $30B

	AUDF3 = $D204
	AUDF4 = $D206
	AUDC4 = $D207
	AUDCTL = $D208
	SKREST = $D20A
	SERIN = $D20D
	SEROUT = $D20D
	IRQEN = $D20E
	IRQST = $D20E
	SKCTL = $D20F
	SKSTAT = $D20F

	PBCTL = $D303

	SETVBV = $E45C

	TURSPD = 6
	XFSPD = 16
	STDSPD = $28

	TURFLG = $80
	XFFLG = $40
	HAPFLG = $41

