/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef ENGINE_H_
#define ENGINE_H_

#include "board.h"

// Engine is written in assembly.
void make_iteration(int width, int height, cell_t** source, cell_t** destination);

#endif /* ENGINE_H_ */
