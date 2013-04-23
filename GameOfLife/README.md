Game Of Life
------------

Typical Conway's game of life simulator,
goto 
[wiki](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life, "wiki link")
to see more specific information about problem.

My implementation assumptions:
------------------------------

 * Board has static size,
 * cell dies if: less than 2 or more than 3 neighbors,
 * cell comes alive if: has 3 neighbors.


Compilation, architectures:
---------------------------

 * Only x86_64, sse
 * To compile it you need NASM
 (tested on version 2.10.07 Feb 11 2013 and 2.10 Mar 20 2012),
 * GCC (tested on 4.7.1 20120810 and 4.7.2 20121109),
 * Compilation run `$ make`, or `$ make debug=1`,
 * Execution run `$ gol`.
 

Testing:
--------

 * Just run `$ make test`,
 * Tests are in `tests` directory.

 Single test involves:
 * running `gol` with parameters:
  * number of iterations
  * size of board (-x, -y),
  * summarized output (-s),
 * Output differences check.

Board size, arguments:
----------------------

Board has static size, but this size can be set in two ways:

 1. Static definition in `src/kernel/gol.c` (WIDTH and HEIGHT).
 2. By using arguments. (Run `$ ./gol -h` for help).

Output can be written on _stdout_ in two ways:

 1. Write board after every iteration.
 2. Write summarized, only last board (argument `-s`).
