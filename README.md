Westerley-Pool
==============

Westerley pool management system. 

Barcode Scanner Setup
---------------------

The barcode scanner should be configured with a preamble of F2 (that is,
the F2 on a PC keyboard, not the Code128 FUNC2) and a postamble of
return.

Tested with <http://www.amazon.com/dp/B00406YZGK> running firmware
LONGXIN V1.34. This scanner defaults to return as postamble; to program
F2 as a preamble, you can generate a barcode with the `barcode` program

    barcode -e code128 -b $'\xC30202002000$81'

That \xC3 is FUNC3.

The setup we use is

    barcode -t 3x10+36+36 -m 36x10 -e 'code128' -b $'\xC30B' -b $'\xC3013301' -b $'\xC30202002000$81'

which first resets the scanner to defaults, then turns it to trigger
once, scan until it finds a barcode, then finally sets F2 as a preamble.
A PDF of this output is included, see barcode-setup.pdf.

UDisks2
-------

The backup page uses UDisks2 to detect and mount removable drives for
backups. This means you need UDisks2 installed and running. Also, you
need to set up PolicyKit to allow the app to mount/unmount disks.


Setup Directions
----------------

Check the `LAPTOP-INSTALL.md` file for directions on setting it up on
the Westerley pool laptop. The same steps also work on a VM.
