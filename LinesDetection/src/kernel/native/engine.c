/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <math.h>

#include "image_operations.h"
#include "image.h"
#include "engine.h"
#include "config.h"

#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

#define WHITE 255
#define BLACK 0

static void add_mask(raw_image_mono_8_t input, raw_image_mono_8_t output, int width,
        int height, int kernel_width, int kernel_height, kernel_t kernel)
{
    debug_print(LVL_INFO, "Adding mask size: %dx%d\n",
            kernel_height, kernel_width);
    int i, j;
    int kern_i, kern_j;
    int ii, jj;
    int cent_i, cent_j;
    long val;
    long norm = 0;

    for (kern_i = 0; kern_i < kernel_height; ++kern_i)
        for (kern_j = 0; kern_j < kernel_width; ++kern_j)
            norm += kernel[kern_i][kern_j];

    cent_i = kernel_height / 2;
    cent_j = kernel_width / 2;

    for (i = cent_i; i < height - cent_i; ++i)
    {
        for (j = cent_j; j < width - cent_j; ++j)
        {
            val = 0;
            for (kern_i = 0; kern_i < kernel_height; ++kern_i)
            {
                ii = i + (kern_i - cent_i);
                for (kern_j = 0; kern_j < kernel_width; ++kern_j)
                {
                    jj = j + (kern_j - cent_j);
                    val += input[ii][jj] * kernel[kern_i][kern_j];
                }
            }
            if (norm > 1)
                val /= norm;

            output[i][j] = val;
        }
    }

    for (i = 0; i < height; ++i)
    {
        if (i == cent_i + 1)
            i = height - 1 - cent_i;
        for (j = 0; j < width; ++j)
        {
            if (j == cent_j + 1)
                j = width - 1 - cent_j;
            val = 0;
            for (kern_i = 0; kern_i < kernel_height; ++kern_i)
            {
                ii = i + (kern_i - cent_i);
                for (kern_j = 0; kern_j < kernel_width; ++kern_j)
                {
                    jj = j + (kern_j - cent_j);

                    val += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0),
                            width - 1))] * kernel[kern_i][kern_j];
                }
            }
            if (norm > 1)
                val /= norm;

            output[i][j] = val;
        }
    }
}

/*
 * Kernels must be normalized.
 */
static void edge_gradient(raw_image_mono_8_t input, raw_image_mono_8_t output,
        raw_image_mono_8_t gradients, int width, int height)
{
    const int sobel_kernel_size = 3;
    const int sobel_kernel_center = sobel_kernel_size / 2;

    int i, j;
    int kern_i, kern_j;
    int ii, jj;
    long val1, val2;

    kernel_t sobel1 = new_kernel(sobel_kernel_size, sobel_kernel_size, -1, -2,
            -1, 0, 0, 0, 1, 2, 1);
    kernel_t sobel2 = new_kernel(sobel_kernel_size, sobel_kernel_size, 1, 0, -1,
            2, 0, -2, 1, 0, -1);

    for (i = sobel_kernel_center; i < height - sobel_kernel_center; ++i)
    {
        for (j = sobel_kernel_center; j < width - sobel_kernel_center; ++j)
        {
            val1 = 0;
            val2 = 0;
            for (kern_i = 0; kern_i < sobel_kernel_size; ++kern_i)
            {
                ii = i + (kern_i - sobel_kernel_center);
                for (kern_j = 0; kern_j < sobel_kernel_size; ++kern_j)
                {
                    jj = j + (kern_j - sobel_kernel_center);

                    val1 += input[ii][jj] * sobel1[kern_i][kern_j];
                    val2 += input[ii][jj] * sobel2[kern_i][kern_j];
                }
            }
            output[i][j] = sqrt(val1 * val1 + val2 * val2);
        }
    }

    for (i = 0; i < height; ++i)
    {
        if (i == sobel_kernel_center + 1)
            i = height - 1 - sobel_kernel_center;
        for (j = 0; j < width; ++j)
        {
            if (j == sobel_kernel_center + 1)
                j = width - 1 - sobel_kernel_center;
            val1 = 0;
            val2 = 0;
            for (kern_i = 0; kern_i < sobel_kernel_size; ++kern_i)
            {
                ii = i + (kern_i - sobel_kernel_center);
                for (kern_j = 0; kern_j < sobel_kernel_size; ++kern_j)
                {
                    jj = j + (kern_j - sobel_kernel_center);

                    val1 +=
                            input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))]
                                    * sobel1[kern_i][kern_j];
                    val2 +=
                            input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))]
                                    * sobel2[kern_i][kern_j];
                }
            }
            output[i][j] = sqrt(val1 * val1 + val2 * val2);
        }
    }

    free_kernel(sobel1, 3);
    free_kernel(sobel2, 3);
}

static void thresholding(raw_image_mono_8_t input, raw_image_mono_8_t output,
        int width, int height, int threshold)
{
    int i, j;

    debug_print(LVL_INFO, "Thresholding: %d\n", threshold);

    for (i = 0; i < height; ++i)
        for (j = 0; j < width; ++j)
            output[i][j] = (input[i][j] >= threshold) ? WHITE : BLACK;
}

static void suppress_non_max_edges(raw_image_mono_8_t input,
        raw_image_mono_8_t output, raw_image_mono_8_t gradients, int width,
        int height)
{
    debug_print(LVL_ERROR, "\n\n\nNot implemented yet!\n\n%c", '\n');
}

static void find_segments(raw_image_mono_8_t image, int width, int height,
        lines_t lines,
        void (*f_add_line)(lines_t, unsigned int, unsigned int, unsigned int,
                unsigned int), unsigned int minimal_line_length)
{
    const double diagonal = sqrt(width * width + height * height);
    int horizontally;
    double angle;
    double distance;
    double begin_distance;
    double max_distance;
    int x_min, x_max, x, y;
    double angle_component = (2 * M_PI) / 1000; // TODO: try to do the math
    int begin_x, begin_y, end_x, end_y;

    for (angle = 0; angle <= 2 * M_PI; angle += angle_component)
    {
        if (angle >= M_PI)
        {
            angle += M_PI_2; // Third part has max_distance always equals 0
            continue;
        }


        if (angle )
        {
            //max_distance
            // x_min, x_max
        }

        for (distance = 0; distance < max_distance; distance += M_SQRT1_2)
        {
            begin_distance = -1;
            for (x = x_min; x < x_max; ++x)
            {
                y = (-(double) x) * (cos(angle) / sin(angle))
                        + (distance / sin(angle));
                if (y < 0 || y >= width)
                    continue;

                if (image[y][x] == WHITE)
                {
                    if (begin_distance < 0)
                    {
                        begin_distance = distance;
                        begin_x = x;
                        begin_y = y;
                    }
                    end_x = x;
                    end_y = y;
                }
                else
                {
                    if (begin_distance > -1)
                    {
                        if ((distance - begin_distance) > minimal_line_length)
                            add_line(lines, begin_x, begin_y, end_x, end_y);
                        begin_distance = -1;
                    }
                }
            }
            if (begin_distance > -1)
                if (distance - begin_distance > minimal_line_length)
                    add_line(lines, begin_x, begin_y, end_x, end_y);

        }
    }
}

void find_lines(raw_image_mono_8_t raw_image, int width, int height,
        lines_t lines,
        void (*f_add_line)(lines_t, unsigned int, unsigned int, unsigned int,
                unsigned int), unsigned int minimal_line_length,
        uint8_t threshold, float sigma, int radius)
{
    raw_image_mono_8_t image_tmp1 = alloc_raw(width, height);
    raw_image_mono_8_t image_tmp2 = alloc_raw(width, height);
    raw_image_mono_8_t gradients = alloc_raw(width, height);
    kernel_t gaussian_smooth = new_gaussian(radius * 2 + 1, sigma);

    if ((image_tmp1 == NULL )|| (image_tmp2 == NULL) || (gradients == NULL)
            || (gaussian_smooth == NULL))
    {
        debug_print(LVL_ERROR,
                "Cannot continue: error while creating objects.%c", '\n');
        return;
    }

    // 1 - smoothing.
    debug_print(LVL_INFO, "Phase 1: smoothing...%c", '\n');
    add_mask(raw_image, image_tmp1, width, height, radius * 2 + 1,
            radius * 2 + 1, gaussian_smooth);

    // 2 - sobel edge detection, generate gradients.
    debug_print(LVL_INFO, "Phase 2: edge detection...%c", '\n');
    edge_gradient(image_tmp1, image_tmp2, gradients, width, height);

    // 3 - tresholding or trace along the edges. TODO: choose one.
    debug_print(LVL_INFO, "Phase 2.5: thresholding...%c", '\n');
    thresholding(image_tmp2, image_tmp1, width, height, threshold); // XXX: saves to raw image

    // 4 - suppress non-maximum edges.
    debug_print(LVL_INFO, "Phase 3: suppress non-maximum edges...%c", '\n');
    suppress_non_max_edges(image_tmp1, image_tmp2, gradients, width, height);

    // 5 - find lines segments using Hough Transform.
    debug_print(LVL_INFO, "Phase 4: find line segments...%c", '\n');
    find_segments(image_tmp2, width, height, lines, f_add_line,
            minimal_line_length);

    free_raw(image_tmp1, height);
    free_raw(image_tmp2, height);
    free_raw(gradients, height);
    free_kernel(gaussian_smooth, radius * 2 + 1);
}
