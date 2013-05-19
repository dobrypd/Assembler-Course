/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <math.h>
#include <stdlib.h>
#include "image_operations.h"
#include "config.h"


void add_lines_to_image(image_t image, lines_t lines, uint8_t color_line,
        uint8_t color_bg)
{
    int i, j, line;
    double a, b, x1, x2, y1, y2;
    for (i = 0; i < image->height; ++i)
    {
        for (j = 0; j < image->width; ++j)
        {
            image->image_mono[i][j] = color_bg;
        }
    }

    for(line = 0; line < lines->size; ++line)
    {
        if (abs(lines->begin_x[line] - lines->end_x[line]) >
                abs(lines->begin_y[line] - lines->end_y[line]))
        {
            x1 = (double)lines->begin_x[line];
            y1 = (double)lines->begin_y[line];
            x2 = (double)lines->end_x[line];
            y2 = (double)lines->end_y[line];
            a = (y1-y2) / (x1-x2);
            b = y1 - x1*a;
            debug_print(LVL_INFO, "y=%fx+%f in (%d, %d)\n", a, b, lines->begin_x[line], lines->end_x[line]);

            for(i = lines->begin_x[line]; i <= lines->end_x[line]; ++i)
                image->image_mono[i][lround(a*i + b)] = color_line;
        }
        else
        {
            x1 = (double)lines->begin_y[line];
            y1 = (double)lines->begin_x[line];
            x2 = (double)lines->end_y[line];
            y2 = (double)lines->end_x[line];
            a = (y1-y2) / (x1-x2);
            b = y1 - x1*a;
            debug_print(LVL_INFO, "x=%fy+%f in (%d, %d)\n", a, b, lines->begin_x[line], lines->end_x[line]);

            for(i = lines->begin_y[line]; i <= lines->end_y[line]; ++i)
                image->image_mono[lround(a*i + b)][i] = color_line;
        }
    }
}
