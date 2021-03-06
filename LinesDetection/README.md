Line Detection
---------------

With given monochromatic image, program should return edges.


Architecture:
--------------

Main function, which is wrote in assembly, works only on ARM architecture.
But all functionality was rewrote in C, go to "Compilation, architectures" to
see how to compile to your `native` architecture. 


Compilation, architectures:
-------------------------

You will need `gcc` (tested on 4.3.2, and 4.7.2) with arm capability, 
working `arm-linux-gnu-gcc` command in case of cross-compilation.
Cross-compilation could not work in this Makefile version.

 * If your native architecture is arm, or you want to cross-compile to arm:
 * * `$ make`
 * If you want native version (i.e. x86), will not compile assembly optimizations:
 * * `$ make arch=native`
 * * Remember that this will produce not optimal version. Mainly for testing purpose.
 * You can add `debug={1..10}` if you want to see debug outputs.
 `debug=1` shows less than `debug=2`, etc.

Testing:
---------

 * Tests are in `tests` directory.

Input:
-------

Only monochromatic image in Netpbm format, [wiki](http://en.wikipedia.org/wiki/Netpbm_format "PGM").

Output:
--------

Default output will be placed on stdout.
Text file with pairs of points (line_begin, line_end).
Example, two lines, from (0,2) to (4,10), and from (32, 42) to (42, 44)

    0 2 4 10
    32 42 42 44

Can return monochromatic image in Netpbm format,
[wiki](http://en.wikipedia.org/wiki/Netpbm_format "PGM").



Run `./linedetect --help` for more informations.

