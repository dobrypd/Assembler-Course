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

static int load_ascii_pgm();
static int load_binary_pgm();

image_t load_image_from_file(const char * filename)
{
    size_t bytes_read;
    size_t line_width;
    int is_ascii; // otherwise binary
    int tmp;

    debug_print(LVL_INFO, "Loading image from file %s.\n", filename);
    image_t image = (image_t)malloc(sizeof (struct _image_t));
    if (image == NULL)
    {
        fputs("malloc error\n", stderr);
        return NULL;
    }

    FILE* inputfile = fopen(filename, "rb");
    if (inputfile == NULL)
    {
        fputs("cannot open input file\n", stderr);
        free(image);
        return NULL;
    }

    // Check magic number.
    tmp = fgetc(inputfile);
    if ((tmp == EOF) || (tmp != (int)(unsigned char)'P'))
        goto FORMATERR;

    tmp = fgetc(inputfile);
    if (tmp == EOF)
        goto FORMATERR;
    is_ascii = tmp == (int)(unsigned char)'2'; // ASCII
    if ((!is_ascii) && (tmp != (int)(unsigned char)'5')) // or BINARY
        goto FORMATERR;

    // Check width and height.

    // TODO: XXX: finished here
    // getline
    // fscanf for size of picture
    // but wihout comments

    // Load image.
    if (is_ascii)
    {
        if (load_ascii_pgm() != 0)
            goto FORMATERR;
    }
    else
    {
        if (load_binary_pgm() != 0)
            goto FORMATERR;

    }

    fclose(inputfile);
    return image;

FORMATERR:
    fclose(inputfile);
    free_image(image);
    fputs("wrong input format, only pgm\n", stderr);
    return NULL;
}

image_t copy_image(image_t image)
{
    //XXX: implement
    return NULL;
}

int check_image(image_t image)
{
    int flag = !0;
    flag &&= (image != NULL);
    flag &&= (image->image_mono != NULL);
    return flag ? IMAGE_STATUS_OK : IMAGE_STATUS_BAD;
}

raw_image_mono_8_t get_raw_image_mono_8(image_t image)
{
    //XXX: implement
    return image->image_mono;
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
