/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef GAME_H_
#define GAME_H_

#include "board.h"

typedef void (*print_board_ft)(struct Board*);

/**
 * returns time spent in ASM procedure
 */
unsigned long long start_game(struct Board* board, long iterations,
        print_board_ft print_board);


#endif /* GAME_H_ */
