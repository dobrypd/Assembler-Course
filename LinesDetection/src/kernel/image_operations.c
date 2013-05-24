/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <assert.h>
#include <math.h>
#include <stdlib.h>

#include "image_operations.h"
#include "config.h"

#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

static inline void fill_bg(image_t image, int color_bg)
{
    int i, j;

    if (color_bg >= 0)
    {
        for (i = 0; i < image->height; ++i)
        {
            for (j = 0; j < image->width; ++j)
            {
                image->image_mono[i][j] = color_bg;
            }
        }
    }
}

static inline void sort_points(int horizontally, int * x1, int * y1, int * x2,
        int * y2)
{
    int tmp;
    if (horizontally)
    {
        if ((*x1) > (*x2))
        {
            tmp = *x1;
            *x1 = *x2;
            *x2 = tmp;
            tmp = *y1;
            *y1 = *y2;
            *y2 = tmp;
        }
    }
    else
    {
        if ((*y1) > (*y2))
        {
            tmp = *x1;
            *x1 = *x2;
            *x2 = tmp;
            tmp = *y1;
            *y1 = *y2;
            *y2 = tmp;
        }
    }
}

static inline void get_function(double * a, double * b, int x1, int y1, int x2,
        int y2)
{
    double dx1 = (double) x1;
    double dy1 = (double) y1;
    double dx2 = (double) x2;
    double dy2 = (double) y2;

    assert(x1 - x2 != 0);

    *a = (dy1 - dy2) / (dx1 - dx2);
    *b = dy1 - dx1 * (*a);
}

static inline int draw_when_one_point(image_t image, int color_line, int x1,
        int y1, int x2, int y2)
{
    if ((x1 == x2) && (y1 == y2))
    {
        image->image_mono[x1][y1] = color_line;
        return 1;
    }
    else
    {
        return 0;
    }
}

static inline void draw_vertically(image_t image, int color_line, int x1,
        int y1, int x2, int y2)
{
    // abs(y1 - y2) >= abs(x1 - x2)
    double a, b;
    int round_j;
    int i;
    sort_points(0, &x1, &y1, &x2, &y2);
    if (!draw_when_one_point(image, color_line, x1, y1, x2, y2))
    {
        get_function(&a, &b, y1, x1, y2, x2);
        debug_print(LVL_INFO, "x=%fy+%f in (%d, %d)\n", a, b, y1, y2);
        for (i = y1; i <= y2; ++i)
        {
            round_j = round(a * i + b);
            round_j = max(min(round_j, image->width - 1), 0);
            image->image_mono[i][round_j] = color_line;
        }

    }
}

static inline void draw_horizontaly(image_t image, int color_line, int x1,
        int y1, int x2, int y2)
{
    // abs(x1 - x2) > abs(y1 - y2)
    double a, b;
    int round_j;
    int i;
    sort_points(1, &x1, &y1, &x2, &y2);
    if (!draw_when_one_point(image, color_line, x1, y1, x2, y2))
    {
        get_function(&a, &b, x1, y1, x2, y2);
        debug_print(LVL_INFO, "y=%fx+%f in (%d, %d)\n", a, b, x1, x2);
        for (i = x1; i <= x2; ++i)
        {
            round_j = round(a * i + b);
            round_j = max(min(round_j, image->height - 1), 0);
            image->image_mono[round_j][i] = color_line;
        }

    }
}

static inline void draw_line(image_t image, int color_line, int x1, int y1,
        int x2, int y2)
{
    if (abs(x1 - x2) > abs(y1 - y2))
    {
        draw_horizontaly(image, color_line, x1, y1, x2, y2);
    }
    else
    {
        draw_vertically(image, color_line, x1, y1, x2, y2);
    }
}

void add_lines_to_image(image_t image, lines_t lines, int color_line,
        int color_bg)
{
    int line;

    fill_bg(image, color_bg);
    for (line = 0; line < lines->size; ++line)
    {
        draw_line(image, color_line, lines->begin_x[line], lines->begin_y[line],
                lines->end_x[line], lines->end_y[line]);
    }
}

static double calc_gauss(int x, int y, float sigma)
{
    double counter;
    double denominator;

    counter = pow(M_E, -((x * x + y * y) / (2 * sigma * sigma)));
    denominator = (2 * M_PI * sigma * sigma);

    return counter / denominator;
}

kernel_t new_gaussian(int size, float sigma)
{
    int i, j;

    debug_print(LVL_INFO, "New gauss kernel, size %d, sigma %f.\n",
            size, sigma);

    kernel_t kernel = (kernel_t) malloc(sizeof(int *) * size);
    if (kernel == NULL )
    {
        fputs("malloc error\n", stderr);
        return NULL ;
    }

    for (i = 0; i < size; ++i)
    {
        kernel[i] = (int *) malloc(sizeof(int) * size);
        if (kernel[i] == NULL )
        {
            free_kernel(kernel, size);
            fputs("malloc error\n", stderr);
            return NULL ;
        }

        for (j = 0; j < size; ++j)
        {
            kernel[i][j] = calc_gauss(i - (size / 2), j - (size / 2), sigma)
                    * size * 100;
        }
    }
    return kernel;
}
