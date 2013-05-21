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

static double calc_gauss(int x, int y, float sigma)
{
    double counter;
    double denominator;

    counter = pow(M_E, -((x*x + y*y) / (2 * sigma * sigma)));
    denominator = (2 * M_PI * sigma * sigma);

    return counter / denominator;
}

kernel_t new_gaussian(int size, float sigma)
{
    int i, j;

    debug_print(LVL_INFO, "New gauss kernel, size %d, sigma %f.\n", size,
        sigma);

    kernel_t kernel = (kernel_t)malloc(sizeof(int *) * size);
    if (kernel == NULL)
    {
        fputs("malloc error\n", stderr);
        return NULL;
    }

    for (i = 0; i < size; ++i)
    {
        kernel[i] = (int *) malloc(sizeof(int) * size);
        if (kernel[i] == NULL)
        {
            free_kernel(kernel, size);
            fputs("malloc error\n", stderr);
            return NULL ;
        }

        for (j = 0; j < size; ++j)
        {
            kernel[i][j] = calc_gauss(i - (size / 2), j - (size / 2), sigma) * size * 100;
        }
    }
    return kernel;
}
