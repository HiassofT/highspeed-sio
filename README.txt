Highspeed SIO patch V1.33 for Atari XL/XE OS and MyIDE OS

Copyright (c) 2006-2020 Matthias Reichl <hias@horus.com>

This program is proteced under the terms of the GNU General Public
License, version 2. Please read LICENSE for further details.

Visit http://www.horus.com/~hias/atari/ for new versions.


1. What is the highspeed SIO patch

The patch modifies the OS ROM so that highspeed SIO capable disk
drives (and also emulators like AtariSIO, SIO2PC, APE, ...) will be
accessed in full speed. All popular highspeed SIO variants are
supported:

- Ultra Speed (Happy, Speedy, AtariSIO/SIO2PC/APE, SIO2SD, ...)
- 1050 Turbo
- XF551
- Warp Speed (Happy 810)

This is the first patch that is 100% compatible with the MyIDE OS. So
you can use both your MyIDE drives and disk drives at the same time with
full speed. Other patches either disabled the MyIDE drives, didn't work
reliable, supported only a few drives, or were disabled when pressing
the reset button.

And: this is also the first patch that supports the highest possible
SIO speed (126kbit/sec) for normal operations!

This patch works with the following OSes:

- Stock Atari XL/XE OS
- MyIDE OS versions 3.x and 4.x

In addition to these OSes you can also create a patched "old"
Atari 400/800 OS (rev. A and rev. B) on your PC that will work
in XL/XE computers. Installing this patched OS in an Atari 400/800
is not easily possible, because the patch uses ROM addresses
$CC00-$CFFF which are not available in stock Atari 400/800 computers.

Other OSes might work but are untested. If you have success with any
other OS please drop me a line so I can include this information in
future docs.


2. How to use the patch

You can either patch the currently active OS (which needs the RAM under
the OS ROM) by running one of the "HISIO*.COM" files or install a
patched OS ROM into your Atari (which doesn't use the RAM under the
OS ROM and therefore also works with Turbo Basic and SpartaDos).

As an alternative you can boot hisioboot.atr or hisioboot-atarisio.atr.
They patch the currently active OS and then allow a disk to be booted.
hisioboot-atarisio.atr executes a "exchange D1: with D2:" AtariSIO
command and if it succeeds will immediately continue the boot process.
This allows for easy "chain-booting" the highspeed SIO patch by loading
hisioboot-atarisio.atr in D1: and the ATR file to boot in D2:.

The files "HISIO*.COM" and "DUMPOS.COM" can be found in the ZIP as
separate files and also in the included "hipatch.atr".

The "HISIO*.COM" files offer different features. If you are impatient
just use the "HISIO.COM" file. Otherwise have a look at the version
table below that describes the different features:

Filename                        Features
               coldstart   hotkeys   ROM-able
HISIO.COM      yes         yes       no
HISIOK.COM     yes         no        no
HISIOR.COM     yes         yes       yes
HISIORK.COM    yes         no        yes

Explanation of the features:

* coldstart

Pressing SHIFT+RESET does a coldstart instead of a warmstart.
All versions of the patch support this feature, but there are some
restrictions:

- This feature is not available when using patchrom to patch an
  "old" (rev. A or B) OS, pressing RESET always results in a
  coldstart.

- This feature is also not available when using the MyIDE "soft"
  (flashcart) OSes. Please use the builtin MyIDE OS or Highspeed
  SIO Patch keystrokes instead.
 
* hotkeys:

The keyboard IRQ routine of the OS is patched and you can control
the SIO patch using various keystrokes:

SHIFT+CONTROL+S    Clear SIO speed table and enable highspeed SIO
SHIFT+CONTROL+N    Disable highspeed SIO (normal speed)
SHIFT+CONTROL+H    Enable highspeed SIO
SHIFT+CONTROL+DEL  Coldstart Atari

* ROM-able:

This means you can dump the patched OS to a
file (using "DUMPOS.COM") and then program the OS ROM-dump
into an EPROM and install it into your Atari.
The drawback is that the ROM-able versions use slightly more
memory at the beginning of the stack area ($0108).

If you want to burn a replacement ROM and install it into your Atari
you first need to create a patched ROM. Currently there are two methods
to do this:

Start one of the ROM-able "HISIOR*.COM" files to patch the ROM.
Then start "DUMPOS.COM" and enter a filename (eg. "D:XLHI.ROM"). This
program will then write a 16k ROM dump to that file. Now you can use your
EPROM burner to write this dump to an EPROM.

The other method is creating a patched ROM image on a PC running Windows
or Unix. Windows users can use the included "patchrom.exe" file, Unix
users first have to compile the "patchrom" in the source directory
(just do a "cd src" and "make patchrom").

"patchrom" needs two command line arguments: the first one is the
filename of the original ROM image that you want to patch the second
argument is the filename where the patched ROM image should be stored.
So, for example, if you downloaded the MyIDE ROM "myide43i.rom" and
want to create a patched ROM named "hi43i.rom" simply type:

patchrom myide43i.rom hi43i.rom

To create a patched ROM file with SIO2BT support, use the "-b" option.
For example:

patchrom -b xl.rom xlhibt.rom

To create a patched ROM file without the keyboard IRQ handler,
use the "-k" option.
For example:

patchrom -k xl.rom xlhi.rom

To disable patching the powerup code (coldstart when pressing
SHIFT+RESET), use the "-p" option. Of course you may
also use two or more options at the same time. For example:

patchrom -k -p xl.rom xlhi2.rom

Now you can use your EPROM programmer to create a ROM replacement for
your Atari.

* ROM checksum handling in patchrom

patchrom can also be used to verify and/or update the checksums which
are present in the original XL/XE ROMs (but eg not in MyIDE ROMs).

By default it verifies if the checksums in the input ROM and if they
are correct it will update them in the patched ROM. This makes sure
patched original XL/XE ROMs and MyIDE ROMs will always be bootable.

To assist people wanting to manually patch OS ROMs patchrom provides
3 additional options:

Option "-c" verifies if the checksums are correct and outputs the
current and computed values. eg:

patchrom -c my.rom

Option "-C" updates the checksums to the correct values, but does not
apply the highspeed SIO patch. This is intended to make a manually
patched original XL/XE ROM bootable. eg:

patchrom -C my.rom my-bootable.rom

Option "-f" forces the checksums to be updated after applying the
highspeed SIO patch. This is intended to be used to add the highspeed
SIO patch to a manually patched original XL/XE ROM. eg:

patchrom -f my.rom my-hi.rom


3. Technical details

At first the patch checks if the current OS is compatible with
the highspeed SIO patch. If it's not compatible you get an error
message and it quits.

Then it checks if the OS was already patched. If this is the case,
it doesn't install itself again but clears the internal SIO speed
table. At the next drive access the drive type (and therefore
the highspeed SIO variant) will be detected again.

In the next step the patch checks if the currently running OS already
uses the RAM under the OS ROM (for example if you are using the MyIDE
soft OS from the MyIDE Flashcart). If this is not the case, the current
OS ROM is copied to the RAM and a reset handler is installed at the
beginning of the stack area ($108).

At last the OS in the RAM is patched and the highspeed SIO code is
installed at $CC00-$CFFF. Please note: this memory region is originally
used by the international character set, so if you switch to this
character set you'll just get garbage on the screen.

Since memory is tight in the Atari 8bit computers the first decision
was where to put it. Using memory in the standard RAM area wasn't an
option since the highspeed SIO code is quite big (more than 800 bytes)
and this would have made it incompatible with most programs. I also
didn't want to throw out code of the OS ROM (like the selftest or
the C: handler), so I decided it would be best to sacrifice the
international character set, which is actually seldomly used.

In addition to the program code (which isn't selfmodifying and therefore
can easily be included in a ROM) the SIO code also needs a total of 13 bytes
of RAM. 1 byte is used to store the speed setting for the current SIO
operation, 8 bytes are used to store the speed settings of the disk
drives D1: - D8:, and 4 bytes are needed as a temporary buffer when
the disk drive type has to be detected (when accessing a disk drive for
the first time).

The versions with keyboard control need one more byte which is used
to enable/disable the highspeed SIO code at all.

The "RAM versions" of the patch (HISIO, HISION) use the memory locations
at $CC0x for there variables, the ROM-able versions use memory locations
at the beginning of the stack area ($01xx) for these variables. In addition
to these locations the patch needs some more bytes to make the software
patch reset-proof. This reset routine is placed at the beginning of
the stack area and called via CASINI ($2/$3). Of course this reset-routine
is not needed when you install a patched OS ROM in your Atari, in this
case only the the 13 (or 14) bytes for the SIO variables is needed.
The reset routine is also not needed with the MyIDE "soft-OS", which
installs it's own reset routine (also using CASINI).

Here's an overview of the memory usage of the various versions:

Filename           SIO           RESET             Total lowmem
                variables       handler        RAM ver.       ROM ver. 
HISIO.COM      $CC00-$CC0D    $0108-$011A    $0108-$011A        n/a
HISIOK.COM     $CC00-$CC0C    $0108-$011A    $0108-$011A        n/a
HISIOR.COM     $0108-$0115    $0116-$0128    $0108-$0128    $0108-$0115
HISIORK.COM    $0108-$0114    $0115-$0127    $0108-$0127    $0108-$0114

The last two columns contain the total "standard" memory usage when
using the software patch ("RAM ver.") and when installing a patched
OS ROM in the Atari ("ROM ver."). Only very few programs use the very
beginning of the stack area, so compatibility is quite high.


How does this patch hook into the OS?

Most other patches intercept the SIO vector at $E459. This works fine
if you only have SIO disk drives attached, but fails if, for example,
you also want to use PBI devices or a MyIDE drive.

This patch uses another approach, it intercepts the SIO code in the
OS located at $E971. Starting at this location is the code to talk
to a serial (SIO) device. If a MyIDE drive (or PBI device) is to
be accessed, the OS code branches to other locations before and the
$E971 code isn't reached at all.

The highspeed SIO patch checks if the code at $E971 matches the one
of the original XL OS and replaces the first 4 bytes with a
"NOP" and a "JMP $CC30". The original code ("TSX" and "STX $0318")
is copied to $CC10, followed by a "JMP $E975".

The highspeed SIO code at $CC30 first checks if a drive (from
D1: to D8:) is to be accessed. If not, it jumps to $CC10 and thus
uses the standard OS code. This test is skipped if you patched
with SIO2BT support. In this case there is no fallback to standard OS code.

If you look at the source code, you'll notice that it is divided
into 2 parts: hisiodet.src and hisiocode.src. The first one is the
"official" entry point, the replacement for the disk drive SIO code.
It sets up the correct speed settings for a disk drive and then calls
the SIO code in the latter file.

At the very beginning, hisiodet.src checks if the highspeed SIO table
(SPEEDTB) entry of the current drive (DUNIT) is zero. If yes, the drive
hasn't been accessed before and therefore it's necessary to determine
which type of highspeed SIO to use.
With SIO2BT support the SPEEDTB is devided into two 4 bytes tables,
one storing HS indexes and one storing CDEVIC IDs, but the idea is the same.
If no HS Index is available for the current device, it has to be determined.

With SIO2BT support, the code first tries to send a $53 command (get status)
with HS Index = $08 (57600 Baud). If any answer comes (positive or NAK),
we are done, otherwise we try with $28 (19200). No answer at all means that
no device is connected, so the SIO request is ended with NAK,
otherwise we continue with highspeed detection.

First, the code tries to send a $3F command (get speed byte) to the
drive. All ultra-speed capable devices support this command and will
return the pokey-divisor byte. If this command succeeds, the byte is
stored in the table. Then it's checked if the byte is $0A. If this
is the case, the drive is most certainly a Happy 1050 and a $48 command
with DAUX=$0020 is sent. This enables fast writes and is needed
by the Happy drives, otherwise they might write corrupted data to
the disk when writing in highspeed mode (thanks to ijor for this info!).

After that a $53 (get status) command is sent in standard speed. This
is needed to work around issues with the Percom AT88-S1 drive (and
maybe others) which spins up on get status and would fail to boot
due to the following get status checks. The SIO detection code bails
out early, issues the other highspeed checks and issues the actual SIO
command all while the drive is still busy spinning up and won't react
to any of the commands - including the actual get status check issued
by OS boot code.

If the get status check fails the following highspeed checks are skipped.
This speeds up highspeed detection if no drive is present.

Then, the code tries to send a $53 command (get status) in 1050 Turbo
and XF551 mode. If it's a 1050 Turbo, $80 is stored in the speed table,
if it's a XF551 $40 is stored.

At last the code tries to send a $48 command ("Happy command") in
warp mode. Note: the Happy 810 didn't support ultra speed, only warp
speed. The Happy 1050 supports both ultra and warp speed.
If this command succeeded, a $41 is stored in the speed table.

If none of the highspeed SIO variants worked, the SIO detection code
assumes it is a stock drive that only operates at standard SIO speed
and stores a $28 (pokey divisor for ~19kbps) in the speed table.
The speed table stores information about up to 4 recently accessed devices.
Older entries are overwritten and such device would be rechecked,
when accessed again.

Once the SIO speed and type has been determined, only the code in
hisiocode.src is used.


Official locations and entry points:

$CFFF0-$CFFF: Highspeed Patch signature and version info

These locations contain a 16-byte ASCII string in the format
"Hias V.ER YYMMDD" where V.ER is the decimal version number
(eg 1.32) and YYMMDD the date of the last code change.

To detect presence of the highspeed SIO patch it's recommended
to verify that "Hias " (including the blank) is present in
$CFF0-$CFF4 and $CFF5-$CFF8 contain a valid decimal number.
The date of the last code change is provided only for informational
purposes.

$CFED: direct entry to highspeed SIO code (since version 1.32)

Note: highspeed patch versions before 1.32 don't contain this entry
point so make sure you verify the version before using it!

This entry point works like the standard JSR $E459 SIO call with
the exception that you need to pass in the highspeed SIO mode in
the A register. Highspeed SIO detection, as it's normally done
for D1:-D8: drives (DDEVIC=§31, DUNIT=1-8) by the highspeed SIO
code is bypassed and any device/unit number may be specified.

A values from $00-$3F select the POKEY divisor.

Other values as listed in hisio.inc (eg XFFLG / $40 for XF551 mode,
HAPFLG / $41 for Happy Warp mode, TURFLG / $80 for 1050 Turbo mode)
are only guaranteed to work in 1.xx versions of the highspeed SIO patch
and might change in the future. If you want to use this modes
verify that the version is >= 1.32 and < 2.00.

Note: The highspeed SIO code doesn't support cassette devices / FSK
mode and will send standard SIO command frames if DDEVIC is set to $60.


Implementation of the highspeed SIO code:

Compared to the original SIO code (which is completely IRQ driven)
this implementation doesn't use IRQs at all (note the "SEI" at the
very beginning of the SIO code). The code is therefore significantly
faster and can reliably operate at speeds up to ~80kbps (pokey divisor 4).
Higher speeds (up to 126kbit/sec) are possible, too, but require
a modified VBI handler code. See below for more details.

Note: I don't recommend using more than ~70kbps (pokey divisor 6)
for "everyday operations". First of all, if you have several
devices in your SIO chain the electrical signal on the SIO bus may
suffer and thus you might end up with occasional transmission errors.
Then, if you load a program with a title screen and this code uses
DLIs, PM graphics or wide display mode, the SIO code might miss some
bytes because the Atari is busy with other stuff...

Before I start describing the implementation details, here is a
description of how the SIO protocol works (at standard speed).
Don't be afraid, it is actually quite simple:

The transmission is divided into several parts, called frames.
Each frame consists of a number of bytes followed by a simple
checksum (just the bytes added one by one plus the carry bit, see
the "?ADDSUM" code in hisiocode.src). In addition to the frames
there are also single byte "blocks", ACK/NAK and COMPLETE/ERROR.

The SIO transmission starts with the so called "command frame".
The /COMMAND line on the SIO bus is set low during transmission of
the command frame which means that all devices should listen and
check if the command is directed to one of them.

The command frame consists of 5 bytes: First, the device number
(more or less just a combination of DDEVIC and DUNIT), the command
(DCOMND), 2 auxiliary bytes (DAUX1, DAUX2, for example the sector
number), and the checksum byte.

Now the computer waits for the response from a device. Only the
device addressed by device number in the command frame may respond,
other devices must stay quiet (a device must also stay quiet if
the checksum doesn't match). The device either sends back an
ACK (ASCII "A"), meaning that it can accept the command, or a
NAK (ASCII "N"), in case of an error (invalid command, invalid
sector number etc.).

In case of an ACK, the SIO protocol proceeds like this:

If bit 7 of DSTATS is set (meaning transmission from the computer
to the device), the computer sends the data frame (eg the sector
data plus the checksum byte) to the device and again waits for an
ACK or NAK. The device now verifies the checksum and transmits
either an ACK (if the checksum is OK) or a NAK. In case of a NAK
the next steps are skipped.

Now the device has some time to execute the command (eg read
a sector from disk, write a sector to disk, format the disk etc.).
The computer waits for a response (the maximum allowed time is set
by DTIMLO). When the device is finished with the command, it either
sends back a COMPLETE (ASCII "C"), meaning that the command succeeded,
or an ERROR (ASCII "E"). Note: in case of an error the SIO operation
is not terminated immediately, but the next step is still executed.
So, for example, if formatting a disk fails, the disk drive still
sends back a data block.

If bit 6 of DSTATS is 0, the SIO transmission ends here. If it is
1 (meaning transmission from the device to the computer), the computer
reads the data frame (eg sector data plus checksum) from the device.
At last the computer verifies the checksum. Depending on the check
DSTATS is set accordingly and the SIO operation ends.

Error handling in the SIO code:

The computer retries transmitting the command frame up to 13 times
until it receives an ACK from a device. If this fails, or if any
further steps fail, the whole SIO operation is retried a second
time (including up to 13 transmissions of the command frame).

Note: the highspeed SIO code falls back to standard speed in case
of a transmission error (i.e. any other error except a
"command ERROR") for the second retry.

Differences between standard, Ultra, Warp, XF551 and 1050 Turbo:

The simplest mode is "Ultra Speed". It is just like the standard
SIO mode, except that all transmission is done at a higher speed.

The other modes transmit the command frame in standard speed (~19kbps,
pokey divisor $28) and then later switch to the higher bitrate.
Additionally various bits in the command frame are set to indicate
highspeed mode.

In 1050 Turbo mode the bitrate is changed to ~70kbps (pokey divisor 6)
immediately after transmitting the command frame (i.e. before waiting
for the command frame ACK/NAK). Highspeed mode is indicated by setting
bit 7 of DAUX2.

XF551 and Warp mode both switch to ~38kbps (pokey divisor 16) after receiving
the command frame ACK.

In XF551 mode bit 7 of DCOMND is set in highspeed mode. This works for
all commands except $21/$22 (format single/enhanced). With these commands
bit 7 is only used to set highspeed sector skew, but all data transmission
is done at standard speed.

Happy (810) Warp mode only supports the commands $50, $52 and $57 (put,
read, write sector) in highspeed. Highspeed mode is indicated by setting
bit 5 of DCOMND.


Implementation of the keyboard IRQ patch:

The keyboard IRQ patch hooks into the IRQ handler at $FC20. The original
code contains a "LDA $D209" at this location, which is then replaced
by a "JMP $CFB7", the new keyboard hook. The new code reads the current
keyboard code (again, a "LDA $D209") and then checks if it matches one
of the special keystrokes. In any case the keyboard code read is preserved
and then passed on to the original IRQ handler. The end of the new
code contains a "JMP $FC23", which is the next instruction after the
original "LDA $D209".

Before patching the IRQ handler the patch checks if the instruction
at $FC20 is really a "LDA $D209". If not, you'll see a warning message
that the keyboard IRQ has not been patched. This is a precaution if
some later MyIDE OSes modify the code in this area (currently the
MyIDE OSes patch the IRQ handler at a lower memory location).


Implementation of the coldstart/powerup patch:

This patch hooks at the beginning of the RESET routine, just after
the short software delay, when PUPBT1..3 ($033D-$033F) are checked.
The first "LDA $033D" at $C2B3 is replaced with a "JMP $CC18".
The new reset code at $CC18 then enables POKEYs keyboard scanning
and checks if the SHIFT key is pressed. In this case the A register
contains $00. If SHIFT is not pressed, the contents of $033D (usually
$5C) are loaded. Then the original reset/powerup code is continued
with a "JMP $C2B6". Since A will be $00 (instead of $5C) when SHIFT
was pressed, the OS recognizes the mismatch, thinks the Atari was
just powered up and do a coldstart initialization.


Why is it necessary to patch the VBI handler?

Short answer: well, because it's too slow :-)

The original VBI handler needs too many CPU cycles. At every VBI
(50 or 60 times per second) it is executed and this may result in a
byte being missed (aka: overrun). At "normal" SIO speeds this is not
a problem, even the "highspeed" transfer rate of disk drives (up to
approx. 80kbit/sec) is fine. But at 92kbit/sec (pokey divisor 3)
problems start.

The highspeed SIO code uses a simple approach which works with
all currently available OSes:

During SIO it installs an immediate VBI handler (in $0222/$0223)
which handles SIO timeouts (using timeout counters in the zeropage,
to save cycles) and increments RTCLOK ($14, $13 - overflows of
$13 and incrementing $12 is handled outside of the VBI handler,
again to save some cycles). Then it exits NMI processing with
a "PLA TAY PLA TAX PLA RTI" sequence.

In the worst case (all counters overflowing) the immediate VBI
handler code needs 48 CPU cycles (best case is 38 cycles).
With the NMI/OS overhead of 38 cycles (stock XL OS) or 45 cycles
("old" rev. A OS) the maximum delay is 93 CPU cycles.

After SIO is finished the original immediate VBI handler
is restored, of course.

The only thing missing in the VBI code, compared to the
original OS VBI code is handling ATRACT mode. So, in theory,
it might be possible that running a long-copy session for
several hours may result in an image burned into the CRT.
Although this risk is not too high you have been warned,
so use this patch at your own risk.

Please note: At 126kbit/sec the Atari is extremely close to it's limit.
At standard "GRAPHICS 0" mode Antic steals a lot of cycles, but there
are just enough cycles left for the CPU to handle this rate. If you
enable PM graphics or widescreen (48 characters) mode, Antic steals too
many cycles and the CPU cannot handle the rate anymore. Other Antic
display modes (even "GRAPHICS 8") leave more cycles to the CPU so
it is not too critical. Graphics 0 is really one of the worst cases
(together with the multicolor text mode, Graphics 12).

Using DLI code (especially with a "STA WSYNC") during SIO may also
lead to transmission errors / overruns.


4. Some really nasty details about POKEY noone seemed to have noticed before:

During testing at very high speed (100 - 126 kbit) I noticed problems when
the transmission speed was slightly above the nominal speed. Usually
POKEY should accept speeds at some 3-5% above and below nominal speed.
But at higher speeds going slightly above nominal speed, or even reaching
nominal speed (at 126kbit) didn't work. But: if I added a short pause
after each transmitted byte (by transmitting 2 stopbits instead of 1),
I could get closer to the 126kbit limit (at 110kbit nominal speed wasn't
a problem).

I ran a number of tests and discovered several interesting things:

At divisor 0 a byte has to be at least 141 cycles long (expected length
was 10*14=140 cycles), otherwise Pokey doesn't recognize the start
bit of the following byte (and sync on the next hi->lo transition instead).

I also expected that Pokey samples the bits at cycle 7 or 8 (of 14),
but actually it samples at cycle 12 (of 14). This explains why there's
(almost) no headroom for faster transmission speeds.

If the first received byte was exactly 141 cycles long, some very
interesting things happen: Pokey samples the second byte at cycle
5 (of 14) and also the reception is signalled in IRQST 7 cycles earlier.
This means, the time between 2 received bytes is only 134 cycles,
not 141 cycles.

If the first byte was 141 cycles long, the second byte (plus all following
bytes) may be 134 cycles long and Pokey still receives them fine. So, in
theory, it would be possible to slightly "overclock" serial transmission.
But this isn't very practicable, the sender has to be synchronized with
the Atari clock, once a byte isn't exactly 134 cycles long the next byte
must be (at least) 141 cycles long.

Several other tests showed that the latest time to enable serial input
IRQ is the cycle immediately before Pokey signals the receipt in IRQST.

This means, the code has to read the received byte, disable serial input
IRQ (to acknowledge the receipt) and re-enable the serial input IRQ
within 134 cycles, otherwise the next byte is missed.

During my tests I was wondering why a (worst case) 133 cycle long code
worked, but a (calculated) 134 cycle long code resulted in very rare
transmission errors - actually 134 cycles should be fine.

I dug a little bit deeper into this and ran into a very interesting
"feature" of the 6502 CPU which wasn't documented before (although
I later found out some other people ran into this before):

If the CPU finishes a 3-cycle taken branch instruction
(to the same page) just before the NMI handler would normally be
started, NMI execution is delayed by another full instruction.

This had the consequence that my worst-case calculation was shifted
by a single cycle and the (calculated) 134 cycle long code caught another
refresh cycle was actually 135 cycles long.

Fortunately, the worst case critical path of the highspeed SIO code
is only 133 cycles, this was nothing I had to worry about, but
investigating this was a lot of fun :-)


