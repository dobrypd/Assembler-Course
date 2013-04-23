/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "board.h"

unsigned int proper_row_size(unsigned int size)
{
    return size + 16 - 1;
}

int initialize_board(struct Board* board)
{
    board->cells = (cell_t**)malloc(board->height * sizeof(cell_t*));
    if (board->cells == 0) return -1;

    int i;
    for (i = 0; i < board->height; ++i)
    {
        // calloc because it zeroes allocated memmory
        board->cells[i] = (cell_t*)calloc(proper_row_size(board->width), sizeof(cell_t));
        if (board->cells[i] == 0) return -1;
    }

#ifndef NDEBUG
    fprintf(stderr, "Allocating board finished with success.\n");
#endif

    return 0;
}

int free_board(struct Board* board)
{
    int i;
    for (i = 0; i < board->height; ++i) {
        free(board->cells[i]);
        board->cells[i] = 0;
    }
    free(board->cells);
    board->cells = 0;
    return 0;
}

