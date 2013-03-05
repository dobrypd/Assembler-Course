/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdio.h>
#include "printer.h"
#include "board.h"

void print_board(struct Board* board)
{
    int i, j;
    for (i = 0; i < board->height; ++i) {
        for (j = 0; j < board->width; ++j) {
            int value = ((int)board->cells[i][j]) == 0 ? ' ' : 'X';
            printf("%c", value);
        }
        printf("\n");
    }
}
