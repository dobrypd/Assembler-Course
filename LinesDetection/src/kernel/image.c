/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include "config.h"
#include "image.h"

const char * NETPBM_file_ext = "pgm";


image_t load_image_from_file(const char * filename)
{
    //XXX: implement
    return NULL;
}

image_t copy_image(image_t image)
{
    //XXX: implement
    return NULL;
}

int check_image(image_t image)
{
    //XXX: implement
    return IMAGE_STATUS_BAD;
}

raw_image_mono_8_t get_raw_image_mono_8(image_t image)
{
    //XXX: implement
    return image;
}

void save_image_to_file(image_t image, const char * filename)
{
    fputs(NETPBM_file_ext, stderr);
    //XXX: implement
}

void free_image(image_t image)
{
    //XXX: implement
    free(image);
}
