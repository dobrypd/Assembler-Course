/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef BOARD_H_
#define BOARD_H_

#include <stdint.h>

typedef uint8_t cell_t;

struct Board {
    int width;
    int height;
    cell_t** cells;
};

int initialize_board(struct Board* board);

int free_board(struct Board* board);


#endif /* BOARD_H_ */
