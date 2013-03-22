/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdio.h>
#include "game.h"
#include "board.h"
#include "engine.h"

#ifndef NDEBUG
    const int debug=1;
#else
    const int debug=0;
#endif

void start_game(struct Board* board, long iterations,
        print_board_ft print_board)
{
    if (debug) fprintf(stderr, "Starting game...\n");
    long i;
    struct Board next_board;
    next_board.width = board->width;
    next_board.height = board->height;
    initialize_board(&next_board);

    for(i = 0; i < iterations; ++i) {
        if (debug) fprintf(stderr, "Starting iteration %ld\n", i);
        make_iteration(board->width, board->height, board->cells,
                next_board.cells);
        // swap
        cell_t** tmp_cells = board->cells;
        board->cells = next_board.cells;
        next_board.cells = tmp_cells;
        if (print_board != 0) {
            (*print_board)(board);
        }
    }

    free_board(&next_board);
}
