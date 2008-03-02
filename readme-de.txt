Highspeed SIO Patch V1.0
fuer MyIDE OS und XL/XE OS
(c) 2006 by ABBUC und Matthias Reichl

Dieser Patch erweitert das OS des
Atari XL/XE um eine Highspeed SIO
Routine fuer so ziemlich alle Floppies
und Floppy-Emulatoren:

- Ultra Speed (Speedy, Happy, 
  APE/SIO2PC/AtariSIO, ...)
- Turbo 1050
- XF551 2xSIO
- Warp Speed (Happy 810)

Das besondere an diesem Patch ist,
dass es speziell fuer den Einsatz
mit dem MyIDE OS entwickelt wurde.
Alle bisher existierenden Highspeed
SIO Patches (zB ape_warp, HappyXL etc)
haben Probleme damit, entweder legen
sie das MyIDE komplett lahm oder
Highspeed funktioniert nicht in
allen Faellen oder sie sind nicht
reset-fest.

Dieser Patch funktioniert mit dem
original XL/XE OS, mit dem
MyIDE OS 3.1, 4.x und 3.xF (also der
Flashcart Version). 

Hinweis: der Patch ist zur Zeit leider
noch nicht kompatibel mit TurboDOS.

Das Programm HIPATCH.COM installiert
den Highspeed SIO Patch. Dabei wird
zuerst ueberprueft, ob das OS
kompatibel ist. Falls noetig wird
das OS vom ROM ins RAM kopiert und
(wenn noetig) wird ein Reset-Handler
installiert.

Aus Platzgruenden verwendet der
Patch den Bereich $CC00-$CFFF in
dem sich sonst der internationale
Zeichensatz befindet. Der Reset-
Handler wird in der Page 1 von
$0100-$0108 installiert und verwendet
CASINI ($2/$3).

Wird HIPATCH.COM ein zweites Mal
geladen, wird die Geschwindigkeit
aller Floppies zurueckgesetzt.
Das ist nur dann noetig, wenn man
im laufenden Betrieb zB eine Speedy
durch eine XF551 ersetzt, was man
aber ohnehin nie machen sollte.

Speziell fuer MyIDE-User die MyDOS
verwenden empfielt sich der Einsatz
des MyDOS Batchfile Enhancements.
HIPATCH.COM kann dann automatisch
ueber die AUTOEXEC.BAT geladen werden,
ggf. mit einem kleinen BFE Menue
sodass es auch abschaltbar ist.
Man kann aber auch HIPATCH.COM in
AUTORUN.ARx umbenennen oder es bei
Bedarf manuell laden.

Fuer Programme, die das RAM unter dem
OS ROM benoetigen (zB SpartaDos, Turbo
Basic) gibt es eine zweite Variante:

HIPATCHR.COM aendert das OS ROM so,
dass es nachher in ein EPROM gebrannt
werden kann. Die neue SIO Routine
steht weiterhin im Bereich $CC00 bis
$CFFF, alle Variablen werden aber
im Bereich $0100-$010C gespeichert.
Ausserdem werden, falls noetig, die
Pruefsummen des OS-ROMs korrigiert.

Nach dem Laden von HIPATCHR.COM
kann mit dem Programm DUMPOS.COM
ein Image des aktuellen OS auf
Disk geschrieben werden. Dabei wird
man nach einem Filenamen gefragt,
diese Datei (ein 16k grosses
eins-zu-eins Abbild des OS, ohne
COM-Header) kann nun mit einem
EPROM Brenner direkt in ein 16k
EPROM programmiert werden.

DUMPOS.COM kann man uebrigens auch
dazu verwenden, das aktuelle ROM OS
oder ein selber gepatchtes OS im RAM
auf Disk zu speichern. Im letzteren
Fall muss man aber selber dafuer Sorge
tragen, dass die ROM Checksummen
stimmen, ansonsten landet man nach
dem Einschalten im Selftest.

Im Herbst 2006 (nach dem ABBUC Software
Wettbewerb) wird auf meiner Homepage
http://www.horus.com/%7Ehias/atari/
zusaetzlich ein Programm fuer PCs
(Linux und Windows) downloadbar sein,
mit dem direkt am PC ein OS-ROM Image
gepatcht werden kann (in erster Linie
fuer alle MyIDE OS Benutzer, um das
MyIDE 4.x OS direkt am PC mit der
Highspeed SIO Funktion zu erweitern).
In der Download-Version ist dann auch
der komplette Source Code aller
(Atari- und PC-) Programme enthalten.

Fuer alle Technik-Freaks, die wissen
wollen wie der Patch genau
funktioniert, gibt's hier noch ein
paar Hintergrund-Informationen:

Der Patch benoetigt insgesamt 13 Bytes
an RAM (bei HIPATCH.COM $CC00-$CC0C,
bei HIPATCHR.COM $0100-$010C). Das
erste Byte wird als temporaerer
Speicher fuer die aktuelle
Geschwindigkeit bei jedem Zugriff
verwendet. Darauf folgen 8 Bytes, die
die Geschwindigkeit der Laufwerke D1:
bis D8: enthalten. 0 bedeutet, dass
die Geschwindigkeit noch nicht
ermittelt wurde. Werte von 1 bis 63
(in der Praxis 8, 9, 10 oder 40)
bedeuten Standard oder Ultra Speed
SIO und werden direkt als Teiler in
das Pokey-Register geschrieben.
64 bedeutet XF551 Modus, 65 Happy
Warp Speed und 128 Turbo 1050.

Beim ersten Zugriff auf eine Floppy
(die Tabelle enthaelt den Wert 0) wird
automatisch die Geschwindigkeit der
Floppy ermittelt. Zuerst wird versucht
per Kommando $3F das Speed-Byte der
Floppy zu lesen (Ultra Speed SIO).
Danach wird versucht, im Turbo 1050
Modus, im XF551 Modus und im Happy
Warp Speed Modus ein "Get Status"
Kommando ($53) auszufuehren. Wenn dies
alles nicht klappt, wird die
Geschwindigkeit der Floppy auf
Standard SIO (Speed Byte 40) gesetzt.

Die meisten anderen Highspeed SIO
Patches klinken sich direkt in SIOV
($E459) ein. Das Problem dabei ist
dann allerdings, dass entweder MyIDE
lahmgelegt wird (wenn der Patch alle
Diskzugriffe abfaengt) oder der
Highspeed SIO Zugriff auf Laufwerke,
die durch MyIDE Partitionen verdeckt
wurden, nicht klappen. Auch diese
Patches stellen beim ersten Zugriff
auf ein Laufwerk die Geschwindigkeit
fest. Da MyIDE aber keine der bei
Floppies ueblichen Highspeed-Funktionen
unterstuetzt, wird angenommen, dass
es sich um eine "langsame" Floppy
handelt. Deaktiviert man nun MyIDE
(durch SHIFT-CONTROL-D) um auf die
zuvor "verdeckten" Floppies
zuzugreifen, so geschieht dies in
(langsamer) Standard Geschwindigkeit.

Dieser Patch umgeht die Probleme
dadurch, dass er sich nicht in SIOV
einklinkt sondern in den Teil des SIO-
Codes, der direkt die "richtigen"
SIO-Floppies anspricht. Dieser Code
wird nur dann im MyIDE OS verwendet,
wenn ein Zugriff auf eine SIO-Floppy
stattfindet, nicht aber wenn eine
MyIDE Partition abgesprochen wird.
Im XL/XE und MyIDE OS liegt diese
Routine bei $E971. Dieser Patch
ueberprueft die ersten 4 Bytes ab
der Adresse um festzustellen, ob das
OS kompatibel ist. Stimmen die
Bytes nicht mit den Originalwerten
ueberein, bricht der Patch die
Installation ab und gibt
"incompatible OS" aus. Somit ist
einigermassen sichergestellt, dass
nicht versehentlich ein alternatives
OS "zerschossen" wird.

Der Reset-Handler ($0100-$0108 bei
HIPATCH.COM bzw $010D-$0115 bei
HIPATCHR.COM) wird nur dann
installiert, wenn CASINI noch nicht
benutzt wird. Das MyIDE Flashcart
OS installiert einen eigenen Reset-
Handler in CASINI, der dafuer sorgt,
dass nach einem Reset automatisch
wieder das OS im RAM aktiviert wird.

DUMPOS.COM ist so einfach und
kompatibel wie nur moeglich
geschrieben. Einzig beim Speichern
des Selftest-ROMs wird das OS-ROM
kurz eingeschaltet (bei deaktiviertem
OS-ROM kann der Selftest nicht
eingeblendet werden). Beim Abspeichern
von $C000-$CFFF und $D800-$FFFF wird
der Wert in $D301 nicht veraendert.
Damit ist sowohl das Speichern des
aktuellen OS ROMs moeglich als auch
das Speichern des OS im RAM inklusive
Selftest aus dem ROM OS und es wird
immer das gerade aktuell laufende
OS gespeichert.

