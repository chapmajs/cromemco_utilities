Cromemco Utilities
==================

These are the utilities I've written for working with my Cromemco Z2-D, a S-100 system using the Cromemco ZPU and 4FDC.

diskloader.pl
-------------

Bare metal disk loader for the Cromemco 4FDC and RDOS 1.x. Requires formatted SSSD 5.25" floppies. Images are "typed" into RDOS one track at a time, and saved to disk using RDOS's disk commands. Quite slow, but functional! Usage:

  `./diskloader.pl image.bin /dev/ttyS0`

Where `image.bin` is a raw Cromemco binary disk image, and `/dev/ttyS0` is a serial port connected to the 4FDC's console. Before running `diskloader.pl`, connect to the console port and autobaud.
