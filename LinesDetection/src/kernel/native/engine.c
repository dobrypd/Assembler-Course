/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <math.h>
#include <stdlib.h>

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
        int height, int kernel_size, kernel_t kernel)
{
    int i, j;
    int kern_i, kern_j;
    int ii, jj;
    int central;
    long val;
    long norm = 0;

    for (kern_i = 0; kern_i < kernel_size; ++kern_i)
        for (kern_j = 0; kern_j < kernel_size; ++kern_j)
            norm += kernel[kern_i][kern_j];

    central = kernel_size / 2;

    for (i = central; i < height - central; ++i)
    {
        for (j = central; j < width - central; ++j)
        {
            val = 0;
            for (kern_i = 0; kern_i < kernel_size; ++kern_i)
            {
                ii = i + (kern_i - central);
                for (kern_j = 0; kern_j < kernel_size; ++kern_j)
                {
                    jj = j + (kern_j - central);
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
        if (i == central + 1)
            i = height - 1 - central;
        for (j = 0; j < width; ++j)
        {
            if (j == central + 1)
                j = width - 1 - central;
            val = 0;
            for (kern_i = 0; kern_i < kernel_size; ++kern_i)
            {
                ii = i + (kern_i - central);
                for (kern_j = 0; kern_j < kernel_size; ++kern_j)
                {
                    jj = j + (kern_j - central);

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


static inline int calc_angle(long val1, long val2)
{
    /*
     * From http://www.pages.drexel.edu/~nk752/cannyTut2.html
     */
    double this_angle;
    uint8_t new_angle;
    // Calculate actual direction of edge
    this_angle = (atan2(val1, val2)/M_PI) * 180.0;

    /* Convert actual edge direction to approximate value */
    if ( ( (this_angle < 22.5) && (this_angle > -22.5) ) || (this_angle > 157.5) || (this_angle < -157.5) )
        new_angle = 0;
    if ( ( (this_angle > 22.5) && (this_angle < 67.5) ) || ( (this_angle < -112.5) && (this_angle > -157.5) ) )
        new_angle = 45;
    if ( ( (this_angle > 67.5) && (this_angle < 112.5) ) || ( (this_angle < -67.5) && (this_angle > -112.5) ) )
        new_angle = 90;
    if ( ( (this_angle > 112.5) && (this_angle < 157.5) ) || ( (this_angle < -22.5) && (this_angle > -67.5) ) )
        new_angle = 135;

    return new_angle;
}
static void edge_gradient(raw_image_mono_8_t input, raw_image_mono_8_t output,
        raw_image_mono_8_t angles, int width, int height)
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
            angles[i][j] = calc_angle(val1, val2);
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
            angles[i][j] = calc_angle(val1, val2);
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
        raw_image_mono_8_t output, raw_image_mono_8_t angles, int width,
        int height)
{
    debug_print(LVL_ERROR, "\n\n\nNot implemented yet!\n\n%c", '\n');
    int i, j;
    for (i = 0; i < height; ++i)
        for (j = 0; j < width; ++j)
            output[i][j] = input[i][j];
}


static inline int fy(int x, double a, double r)
{
    return -(double)x * (cos(a)) / sin(a) + r / sin(a);
}
static inline int fx(int y, double a, double r)
{
    return -(double)y * (sin(a)) / cos(a) + r / cos(a);
}
static inline void get_max_distance(double * max_distance, int * horizontally,
        int width, int height, double angle)
{
    const double diagonal = sqrt(width * width + height * height);
    if (angle <= M_PI_2)
    {
        *max_distance = diagonal * cos(fabs(angle - atan2(height, width)));
        *horizontally = (angle >= M_PI_4);
    }
    else if (angle <= M_PI)
    {
        *max_distance = height * cos(angle - M_PI_2);
        *horizontally = (angle <= ((3.0 / 4.0) * M_PI));
    }
    else
    {
        *max_distance = width * cos(2 * M_PI - angle);
        *horizontally = (angle <= ((7.0 / 4.0) * M_PI));
    }
    debug_print(LVL_LOWEST, "Angle %f, max distance %f, is %s horizontally\n",
            angle * 180.0 / M_PI, *max_distance, (*horizontally) ? "" : "not");
}
static inline void get_extrema(int * x_min, int * x_max,
        int * y_min, int * y_max, double a, double r, int width, int height)
{
    // x
    if (fy(0, a, r) <= 0)
    {
        *x_min = fx(0, a, r);
    }
    else if (fy(0, a, r) < height)
    {
        *x_min = 0;
    }
    else // y > h
    {
        *x_min = fx(height, a, r);
    }

    if (fy(width, a, r) <= 0)
    {
        *x_max = fx(0, a, r);
    }
    else if (fy(width, a, r) < height)
    {
        *x_max = width;
    }
    else // y > h
    {
        *x_max = fx(height, a, r);
    }

    *x_min = max(*x_min, 0);
    *x_max = min(*x_max, width);

    // y
    if (fx(0, a, r) <= 0)
    {
        *y_min = fy(0, a, r);
    }
    else if (fy(0, a, r) < width)
    {
        *y_min = 0;
    }
    else // x > w
    {
        *y_min = fx(width, a, r);
    }

    if (fx(height, a, r) <= 0)
    {
        *y_max = fy(0, a, r);
    }
    else if (fx(height, a, r) < width)
    {
        *y_max = height;
    }
    else // x > w
    {
        *y_max = fy(width, a, r);
    }

    *y_min = max(*y_min, 0);
    *y_max = min(*y_max, height);

    debug_print(LVL_LOWEST,
            "Extremas: a %f r %f: y_min %d x_min %d y_max %d x_max %d\n",
            a * 180.0 / M_PI, r, *y_min, *x_min, *y_max, *x_max);
}
static inline double len(int x1, int y1, int x2, int y2)
{
    int x = abs(x1 - x2);
    int y = abs(y1 - y2);
    return sqrt(x * x + y * y);
}

static void find_segments(raw_image_mono_8_t image, int width, int height,
        lines_t lines,
        void (*f_add_line)(lines_t, unsigned int, unsigned int, unsigned int,
                unsigned int), unsigned int minimal_line_length)
{
    int horizontally; // is line is horizontally (|x1 - x2| >= |y1 - y2|)
    double angle; // angle between abscissa (0X) and normal to analyzed line
    double distance; // distance between line and point (0, 0)
    double max_distance; // maximum distance for current angle
    int x_min, x_max, x, y_min, y_max, y;
    double angle_component = (2.0 * M_PI) / 1000.0; // TODO: try to do the math
    // Found line
    int begin_x, begin_y, end_x, end_y;

    for (angle = 0; angle < 2 * M_PI; angle += angle_component)
    {
        if ((angle >= M_PI) && (angle < (3.0/2.0) * M_PI))
        {
            angle += M_PI_2; // Third part has max_distance always equals 0
            continue;
        }

        get_max_distance(&max_distance, &horizontally, width, height, angle);

        for (distance = 0; distance < max_distance; distance += M_SQRT1_2)
        {
            get_extrema(&x_min, &x_max, &y_min, &y_max, angle, distance, width,
                    height);
            if (horizontally)
            {
                begin_x = -1;
                for (x = x_min; x < x_max; ++x)
                {
                    y = fy(x, angle, distance);
                    if (y < 0 || y >= height)
                        continue;

                    if (image[y][x] == WHITE)
                    {
                        if (begin_x < 0) // Line start
                        {
                            begin_x = x;
                            begin_y = y;
                        }
                        end_x = x;
                        end_y = y;
                    }
                    else
                    {
                        if (begin_x > -1)
                        {
                            if (len(begin_x, begin_y, end_x, end_y) > minimal_line_length)
                                add_line(lines, begin_x, begin_y, end_x, end_y);
                            begin_x = -1;
                        }
                    }
                }
                if (begin_x > -1)
                    if (len(begin_x, begin_y, end_x, end_y) > minimal_line_length)
                        add_line(lines, begin_x, begin_y, end_x, end_y);
            }
            else
            { // vertically
                begin_y = -1;
                for (y = y_min; y < y_max; ++y)
                {
                    x = fx(y, angle, distance);
                    if (x < 0 || x >= width)
                        continue;

                    if (image[y][x] == WHITE)
                    {
                        if (begin_y < 0) // Line start
                        {
                            begin_x = x;
                            begin_y = y;
                        }
                        end_x = x;
                        end_y = y;
                    }
                    else
                    {
                        if (begin_y > -1)
                        {
                            if (len(begin_x, begin_y, end_x, end_y) > minimal_line_length)
                                add_line(lines, begin_x, begin_y, end_x, end_y);
                            begin_y = -1;
                        }
                    }
                }
                if (begin_y > -1)
                    if (len(begin_x, begin_y, end_x, end_y) > minimal_line_length)
                        add_line(lines, begin_x, begin_y, end_x, end_y);
            } /* horizontal / vertival */
        } /* distance */
    } /* angle */
}

void find_lines(raw_image_mono_8_t raw_image, int width, int height,
        lines_t lines,
        void (*f_add_line)(lines_t, unsigned int, unsigned int, unsigned int,
                unsigned int), unsigned int minimal_line_length,
        uint8_t threshold, float sigma, int radius)
{
    raw_image_mono_8_t image_tmp1 = alloc_raw(width, height);
    raw_image_mono_8_t image_tmp2 = alloc_raw(width, height);
    raw_image_mono_8_t angles = alloc_raw(width, height);
    kernel_t gaussian_smooth = new_gaussian(radius * 2 + 1, sigma);

    if ((image_tmp1 == NULL )|| (image_tmp2 == NULL) || (angles == NULL)
            || (gaussian_smooth == NULL))
    {
        debug_print(LVL_ERROR,
                "Cannot continue: error while creating objects.%c", '\n');
        return;
    }

    // 1 - smoothing.
    debug_print(LVL_INFO, "Phase 1: smoothing...%c", '\n');
    add_mask(raw_image, image_tmp1, width, height, radius * 2 + 1,
            gaussian_smooth);

    // 2 - sobel edge detection, generate gradients.
    debug_print(LVL_INFO, "Phase 2: edge detection...%c", '\n');
    edge_gradient(image_tmp1, image_tmp2, angles, width, height);

    // 3 - tresholding or trace along the edges. TODO: choose one.
    debug_print(LVL_INFO, "Phase 2.5: thresholding...%c", '\n');
    thresholding(image_tmp2, image_tmp1, width, height, threshold); // XXX: saves to raw image

    // 4 - suppress non-maximum edges.
    debug_print(LVL_INFO, "Phase 3: suppress non-maximum edges...%c", '\n');
    suppress_non_max_edges(image_tmp1, image_tmp2, angles, width, height);

    // 5 - find lines segments using Hough Transform.
    debug_print(LVL_INFO, "Phase 4: find line segments...%c", '\n');
    find_segments(image_tmp2, width, height, lines, f_add_line,
            minimal_line_length);


    free_raw(image_tmp1, height);
    free_raw(image_tmp2, height);
    free_raw(angles, height);
    free_kernel(gaussian_smooth, radius * 2 + 1);
}
