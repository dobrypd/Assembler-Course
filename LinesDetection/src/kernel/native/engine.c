/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include "engine.h"


void find_lines(raw_image_mono_8_t raw_image, int width, int height,
        lines_t lines, void (*f_add_line) (lines_t, unsigned int, unsigned int,
                unsigned int, unsigned  int),
        unsigned int minimal_line_length, int return_outputs_on_stdout)
{
    // TEST:
    f_add_line(lines, 0, 0, 100, 100);
    f_add_line(lines, 0, 0, 100, 50);
    f_add_line(lines, 0, 0, 100, 25);
    f_add_line(lines, 0, 0, 50, 100);
}
