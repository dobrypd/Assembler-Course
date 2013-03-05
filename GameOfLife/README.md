Game Of Life
------------

Typical Conway's game of life simulator,
goto 
http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
to see more specific information about problem.

My implementation assumptions:
------------------------------

 * Board has static size,
 * cell dies if: less than 2 or more than 3 neighbors,
 * cell comes alive if: has 3 neighbors,


Compilation, architectures:
---------------------------

 * Only x86_64,
 * To compile it you need NASM
 (tested on version 2.10.07 Feb 11 2013 and 2.10 Mar 20 2012),
 * GCC (tested on 4.7.1 20120810 and 4.7.2 20121109),
 * Compilation run `$ make`, or `$ make debug=1`.
 * Execution run `$ gol`.
 * Pack with tests is located in `/tests`, to run tests execute `$ make test`.
 