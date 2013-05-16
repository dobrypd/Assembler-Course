/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef ENGINE_H_
#define ENGINE_H_

#include "image.h"

/*
 * if f_add_line is NULL then return on stdout
 */
extern void find_lines(raw_image_mono_8_t raw_image, lines_t lines,
        void (*f_add_line(lines_t, int, int, int, int)),
        unsigned int minimal_line_length, int return_outputs_on_stdout);

#endif /* ENGINE_H_ */
