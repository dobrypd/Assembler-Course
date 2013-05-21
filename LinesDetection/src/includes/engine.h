/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef ENGINE_H_
#define ENGINE_H_

#include "image.h"
#include "detector.h"

/*
 * if f_add_line is NULL then return on stdout
 */
extern void find_lines(raw_image_mono_8_t raw_image, int width, int height,
        lines_t lines, void (*f_add_line) (lines_t, unsigned int, unsigned int,
                unsigned int, unsigned int), unsigned int minimal_line_length,
        uint8_t threshold, int return_outputs_on_stdout);

#endif /* ENGINE_H_ */
