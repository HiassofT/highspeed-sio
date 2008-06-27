Highspeed SIO patch V1.12 for Atari XL/XE OS and MyIDE OS

Copyright (c) 2006-2008 Matthias Reichl <hias@horus.com> and ABBUC

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

This patch works with the following OSes:

- Stock Atari XL/XE OS
- MyIDE OS versions 3.x and 4.x


2. How to use the patch

You can either patch the currently active OS (which needs the RAM under
the OS ROM) or install a patched OS ROM into your Atari (which doesn't
use the RAM under the OS ROM and therefore also works with Turbo Basic
and SpartaDos).

The files "HISIO.COM", "HISION.COM", "HISIOR.COM", "HISIORN.COM"
and "DUMPOS.COM" can be found in the ZIP as separate files and also
in the included "hipatch.atr".

To patch the currently active OS, either use "HISIO.COM" or
"HISION.COM". The difference between these two is that the
first one also patches the keyboard IRQ handler so that you
can control the highspeed code with various keystrokes (see
next section). The "HISION.COM" doesn't touch the keyboard IRQ,
use this if you don't like the keyboard control or in the
rare case where other software uses the keystrokes.

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
beginning of the stack area ($100).

At last the OS in the RAM is patched and the highspeed SIO code is
installed at $CC00-$CFFF. Please note: this memory region is originally
used by the international character set, so if you switch to this
character set you'll just get garbage on the screen.

If you want to burn a replacement ROM and install it into your Atari
you first need to create a patched ROM. Currently there are two methods
to do this:

Start "HISIOR.COM" (please note the "R" at the end!) or "HISIORN.COM"
(without keyboard IRQ handler, like HISIO/HISION) to patch the ROM.
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

To create a patched ROM file without the keyboard IRQ handler, use
the "-n" option (this has to be the first option passed to patchrom).
For example:

patchrom -n xl.rom xlhi.rom

Now you can use your EPROM burner to create a ROM replacement for
your Atari.


3. List of keystrokes

If you decided to also patch the keyboard IRQ handler, the following
keystrokes are available to control the highspeed SIO patch:

SHIFT+CONTROL+S    Clear SIO speed table
SHIFT+CONTROL+N    Disable highspeed SIO (normal speed)
SHIFT+CONTROL+H    Enable highspeed SIO
SHIFT+CONTROL+DEL  Coldstart Atari


4. Technical details

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

The "RAM version" of the patch (HISIO.COM) uses the memory locations
$CC00-$CC0D for this variables (HISION: $CC00-$CC0C), the ROMable
version (HISIOR.COM) uses memory locations $0100-$010D (HISIORN:$0100-$010C,
the beginning of the stack area). Only very few programs use the very
beginning of the stack area, so compatibility is quite high.

To make the software patch reset-proof (the ROM OS is activated when
pressing the reset button), it also needs some more bytes to install
a reset handler. HISIO.COM and HISION.COM use $0100-$0108, the ROMable
patch HISIOR.COM uses $010E-$0116 (HISIORN.COM. $010D-$0115) for this
code.  The reset code is activated by pointing CASINI ($2/$3) to this
memory location, but only if CASINI was not already used before.
Note: The MyIDE soft-OS installs it's own reset-handler that switches
to RAM-OS using CASINI, so there's no need to install another handler.
Of course, there's also no need for a reset handler if you use a
patched ROM installed into your Atari.

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
"NOP" and a "JMP $CC20". The original code ("TSX" and "STX $0318")
is copied to $CC10, followed by a "JMP $E974".

The highspeed SIO code at $CC20 first checks if a drive (from
D1: to D8:) is to be accessed. If not, it jumps to $CC10 and thus
uses the standard OS code.

If you look at the source code, you'll notice that it is divided
into 2 parts: hisiodet.src and hisiocode.src. The first one is the
"official" entry point, the replacement for the disk drive SIO code.
It sets up the correct speed settings for a disk drive and then calls
the SIO code in the latter file.

At the very beginning, hisiodet.src checks if the highspeed SIO table
(SPEEDTB) entry of the current drive (DUNIT) is zero. If yes, the drive
hasn't been accessed before and therefore it's necessary to determine
which type of highspeed SIO to use.

First, the code tries to send a $3F command (get speed byte) to the
drive. All ultra-speed capable devices support this command and will
return the pokey-divisor byte. If this command succeeds, the byte is
stored in the table. In addition to that, a $48 command with DAUX
set to $0020 (Happy 1050: enable fast writes) is also sent to the drive.
Although other drives don't need this (and, most likely, don't even
support this command), Happy drives might corrupt data when writing
to disk in highspeed mode if fast write is disabled (thanks to ijor
for pointing this out!).

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

Once the SIO speed and type as been determined, only the code in
hisiocode.src is used.

Implementation of the highspeed SIO code:

Compared to the original SIO code (which is completely IRQ driven)
this implementation doesn't use IRQs at all (note the "SEI" at the
very beginning of the SIO code). The code is therefore significantly
faster and can reliably operate at speeds up to ~80kbps (pokey divisor 4).

Note: Although the code works fine at this speed I don't recommend
using more than ~70kbps (pokey divisor 6). First of all, if you have several
devices in your SIO chain the electrical signal on the SIO bus may
suffer and thus you might end up with occasional transmission errors.
Then, if you load a program with a title screen and this code uses
either a lot of DLIs or hooks into the immediate VBI, the SIO code
might miss some bytes because the Atari is busy with other stuff...

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
ACK or NAK. The devices now verifies the checksum and transmits
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
by a "JMP $CF80", the new keyboard hook. The new code reads the current
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

