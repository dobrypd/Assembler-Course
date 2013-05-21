/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <math.h>
//XXX:
#include <stdio.h>

#include "image.h"
#include "engine.h"

#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

void add_mask(raw_image_mono_8_t input, raw_image_mono_8_t output,
        int width, int height, int kernel_width, int kernel_height,
        kernel_t kernel)
{
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

                    val += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))] * kernel[kern_i][kern_j];
                }
            }
            if (norm > 1)
                val /= norm;

            output[i][j] = val;
        }
    }
}

void add_combinated_masks(raw_image_mono_8_t input, raw_image_mono_8_t output,
        int width, int height, int kernel_width, int kernel_height,
        kernel_t kernel1, kernel_t kernel2,
        uint8_t(*combinator)(long, long))
{
    int i, j;
    int kern_i, kern_j;
    int ii, jj;
    int cent_i, cent_j;
    long val1, val2;
    long norm1 = 0, norm2 = 0;

    for (kern_i = 0; kern_i < kernel_height; ++kern_i)
        for (kern_j = 0; kern_j < kernel_width; ++kern_j)
        {
            norm1 += kernel1[kern_i][kern_j];
            norm2 += kernel2[kern_i][kern_j];
        }

    cent_i = kernel_height / 2;
    cent_j = kernel_width / 2;

    for (i = cent_i; i < height - cent_i; ++i)
    {
        for (j = cent_j; j < width - cent_j; ++j)
        {
            val1 = 0;
            val2 = 0;
            for (kern_i = 0; kern_i < kernel_height; ++kern_i)
            {
                ii = i + (kern_i - cent_i);
                for (kern_j = 0; kern_j < kernel_width; ++kern_j)
                {
                    jj = j + (kern_j - cent_j);

                    if( ii >= 0 && ii < height && jj >= 0 && jj < width)
                    {
                        val1 += input[ii][jj] * kernel1[kern_i][kern_j];
                        val2 += input[ii][jj] * kernel2[kern_i][kern_j];
                    }
                    else
                    {
                        val1 += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))] * kernel1[kern_i][kern_j];
                        val2 += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))] * kernel2[kern_i][kern_j];
                    }
                }
            }
            if (norm1 > 1)
                val1 /= norm1;
            if (norm2 > 1)
                val2 /= norm2;
            output[i][j] = combinator(val1, val2);
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
            val1 = 0;
            val2 = 0;
            for (kern_i = 0; kern_i < kernel_height; ++kern_i)
            {
                ii = i + (kern_i - cent_i);
                for (kern_j = 0; kern_j < kernel_width; ++kern_j)
                {
                    jj = j + (kern_j - cent_j);

                    if( ii >= 0 && ii < height && jj >= 0 && jj < width)
                    {
                        val1 += input[ii][jj] * kernel1[kern_i][kern_j];
                        val2 += input[ii][jj] * kernel2[kern_i][kern_j];
                    }
                    else
                    {
                        val1 += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))] * kernel1[kern_i][kern_j];
                        val2 += input[(min(max(ii, 0), height - 1))][(min(max(jj, 0), width - 1))] * kernel2[kern_i][kern_j];
                    }
                }
            }
            if (norm1 > 1)
                val1 /= norm1;
            if (norm2 > 1)
                val2 /= norm2;
            output[i][j] = combinator(val1, val2);
        }
    }
}

uint8_t square_root_combinator(long a, long b)
{
    return sqrtl(a*a + b*b);
}

void find_lines(raw_image_mono_8_t raw_image, int width, int height,
        lines_t lines, void (*f_add_line) (lines_t, unsigned int, unsigned int,
                unsigned int, unsigned  int),
        unsigned int minimal_line_length, int return_outputs_on_stdout)
{
    raw_image_mono_8_t copy = copy_raw(raw_image, width, height);
    if (copy == NULL)
        return;

    kernel_t sobel1 = new_kernel(3, 3,
            -1, -2, -1,
             0,  0,  0,
             1,  2,  1);
    kernel_t sobel2 = new_kernel(3, 3,
             1,  0, -1,
             2,  0, -2,
             1,  0, -1);
    kernel_t gaussian_smooth = new_kernel(5, 5,
             1,  4,  7,  4,  1,
             4, 16, 26, 16,  4,
             7, 26, 41, 26,  7,
             4, 16, 26, 16,  4,
             1,  4,  7,  4,  1);
    kernel_t copying_kernel = new_kernel(1, 1, 1);

    add_mask(copy, raw_image, width, height, 5, 5, gaussian_smooth);
    add_combinated_masks(raw_image, copy, width, height, 3, 3, sobel1, sobel2,
            *square_root_combinator);
    add_mask(copy, raw_image, width, height, 1, 1, copying_kernel);


    free_kernel(sobel1, 3);
    free_kernel(sobel2, 3);
    free_kernel(gaussian_smooth, 5);
    free_kernel(copying_kernel, 1);

    free_raw(copy, height);
}
