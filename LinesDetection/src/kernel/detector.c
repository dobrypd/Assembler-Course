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

static const char * text_file_ext = "txt";


lines_t detect_lines(image_t image)
{
    //XXX: implement
    return NULL;
}

int check_lines(lines_t lines)
{
    //XXX: implement
    return DETECTION_STATUS_BAD;
}

void add_line(lines_t lines, int fst_line_begin, int fst_line_end,
        int snd_line_begin, int snd_line_end)
{
    //XXX: implement
}

void save_lines_to_file(lines_t lines, const char * filename)
{
    fputs(text_file_ext, stderr);
    //XXX: implement
}

void free_lines(lines_t lines)
{
    //XXX: implement
    free(lines);
}
