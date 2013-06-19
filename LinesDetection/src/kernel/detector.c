/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "config.h"
#include "detector.h"
#include "engine.h"


lines_t detect_lines(image_t image, unsigned int minimal_line_length,
        uint8_t threshold, float sigma, int radius,
        int return_outputs_on_stdout)
{
    debug_print(LVL_INFO, "Detecting lines %p\n", image);
    lines_t lines = (lines_t)malloc(sizeof(struct _lines_t));
    if (lines == NULL)
    {
        fputs("malloc error\n", stderr);
        return NULL;
    }
    lines->size = 0;
    lines->mem_size = 0;
    lines->begin_x = NULL;
    lines->begin_y = NULL;
    lines->end_x = NULL;
    lines->end_y = NULL;

#ifndef NDEBUG
    printf("Arguments:\n\t%p\t%d\t%d\t%p\t%p\t%d\t%d\t%f\t%d\n",
            get_raw_image_mono_8(image), image->width, image->height,
            lines, &add_line, minimal_line_length, threshold, sigma, radius);
#endif

    find_lines(get_raw_image_mono_8(image), image->width, image->height, lines,
            &add_line, minimal_line_length, threshold, sigma, radius);

    return lines;
}

int check_lines(lines_t lines)
{
    return (lines != NULL) && ((lines->size == 0)
            || ((lines->begin_x != NULL)
                    && (lines->begin_y != NULL)
                    && (lines->end_x != NULL)
                    && (lines->end_y != NULL)));
}

int lines_how_many(lines_t lines)
{
    return lines->size;
}

void add_line(lines_t lines, unsigned int begin_x, unsigned int begin_y,
        unsigned int end_x, unsigned int end_y)
{
    unsigned int tmp;
    debug_print(LVL_INFO, "Found new line: (%d, %d) - (%d, %d)\n",
            begin_x, begin_y, end_x, end_y);
    if (begin_x > end_x) {
        tmp = end_x;
        end_x = begin_x;
        begin_x = tmp;
        tmp = end_y;
        end_y = begin_y;
        begin_y = tmp;
    }
    if (((lines->size + 1) * sizeof(unsigned int)) >= lines->mem_size)
    {
        lines->mem_size = lines->mem_size
                + sizeof(unsigned int) * lines_len_add_size;
        lines->begin_x = realloc(lines->begin_x, lines->mem_size);
        lines->begin_y = realloc(lines->begin_y, lines->mem_size);
        lines->end_x = realloc(lines->end_x, lines->mem_size);
        lines->end_y = realloc(lines->end_y, lines->mem_size);
        if ((lines->begin_x == NULL) || (lines->begin_y == NULL)
                || (lines->end_x == NULL) || (lines->end_y == NULL))
        {
            fputs("malloc error\n", stderr);
            return;
        }
    }
    lines->begin_x[lines->size] = begin_x;
    lines->begin_y[lines->size] = begin_y;
    lines->end_x[lines->size] = end_x;
    lines->end_y[lines->size] = end_y;
    lines->size++;
}

void save_lines_to_file(lines_t lines, const char * filename)
{
    int i;
    debug_print(LVL_INFO, "Writing lines to file %s\n", filename);
    FILE* output = fopen(filename, "wb");
    if (output == NULL)
    {
        debug_print(LVL_ERROR, "malloc error%c", '\n');
        fputs("cannot create or open output file\n", stderr);
        return;
    }

    for (i = 0; i < lines->size; ++i)
    {
        fprintf(output, "(%d,%d)-(%d,%d)\n", lines->begin_x[i], lines->begin_y[i],
                lines->end_x[i], lines->end_y[i]);
    }
    fclose(output);
}

void free_lines(lines_t lines)
{
    if (lines != NULL)
    {
        if (lines->begin_x != NULL)
        {
            free(lines->begin_x);
            lines->begin_x = NULL;
        }
        if (lines->begin_y != NULL)
        {
            free(lines->begin_y);
            lines->begin_y = NULL;
        }
        if (lines->end_x != NULL)
        {
            free(lines->end_x);
            lines->end_x = NULL;
        }
        if (lines->end_y != NULL)
        {
            free(lines->end_y);
            lines->end_y = NULL;
        }
        free(lines);
        lines = NULL;
    }
}
