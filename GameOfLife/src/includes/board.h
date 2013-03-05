/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef BOARD_H_
#define BOARD_H_

struct Board {
    int width;
    int height;
    int** cells;
};

int initialize_board(struct Board* board);


#endif /* BOARD_H_ */
