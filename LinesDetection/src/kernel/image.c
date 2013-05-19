/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#define _GNU_SOURCE

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "config.h"
#include "image.h"

#define PGM_ASCII 2
#define PGM_BIN 5


static int scann_image_properties(image_t image, FILE * inputfile, char * * buf,
        size_t * bufsize)
{
    int scanned_args;
    int pgmtype;
    debug_print(LVL_INFO, "Loading image properties from file %p.\n",
            inputfile);
    pgmtype = -1;

    for (scanned_args = 0; scanned_args < 4;)
    {
        if (getline(buf, bufsize, inputfile) == -1)
        {
            return -1;
        }

        if ((*buf)[0] == '#')
        {
            debug_print(LVL_INFO, "comment:%s", (*buf));
            continue;
        }

        switch (scanned_args) {
            case 0:
                sscanf(*buf, "P%d\n", &(pgmtype));
                break;
            case 1:
                sscanf(*buf, "%d %d\n", &(image->width), &(image->height));
                scanned_args++;
                break;
            case 3:
                sscanf(*buf, "%d\n", &(image->max_deph));
                break;
        }

        scanned_args++;
    }
    debug_print(LVL_INFO,
            "PGM file info MAGIC:%d, WIDTH:%d, HEIGHT:%d, DEPH:%d.\n",
                pgmtype, image->width, image->height, image->max_deph);

    return pgmtype;
}

static int load_ascii_pgm(image_t image, FILE * inputfile)
{
    unsigned int i, j;
    int value;
    debug_print(LVL_INFO, "Scanning ascii file %p.\n", inputfile);
    for (i = 0; i < image->height; ++i)
    {
        for (j = 0; j < image->width; ++j)
        {
            if (fscanf(inputfile, "%d", &(value)) == EOF)
                return -1;
            image->image_mono[i][j] = (uint8_t)value;
        }
        fscanf(inputfile, "\n");
    }
    debug_print(LVL_INFO, "Scanned successfully file %p.\n", inputfile);
    return 0;
}

static int load_binary_pgm(image_t image, FILE * inputfile, char * * buf,
        size_t * bufsize)
{
    int i, j;
    size_t read;
    debug_print(LVL_INFO, "Scanning binnary file %p.\n", inputfile);
    if ((buf == NULL) || ((*bufsize) < image->width))
    {
        (*buf) = realloc((*buf), image->width + 1);
        (*bufsize) = image->width;
    }
    for (i = 0; i < image->height;)
    {
        if ((read = fread(*buf, sizeof(uint8_t), *bufsize, inputfile)) == -1)
            return -1;

        if (read != image->width)
        {
            debug_print(LVL_WARNING, "Read %d\n", (int)read);
            return -1;
        }

        for (j = 0; j < image->width; ++j)
        {
            image->image_mono[i][j] = (uint8_t)((*buf)[j]);
        }

        i++;
    }
    debug_print(LVL_INFO, "Scanned successfully file %p.\n", inputfile);
    return 0;
}

image_t load_image_from_file(const char * filename)
{
    char * buf = NULL;
    size_t bufsize;
    int pgm_type = -1;
    int i;
    debug_print(LVL_INFO, "Loading image from file %s.\n", filename);

    // Alloc buffer and image structure).
    image_t image = (image_t)malloc(sizeof (struct _image_t));
    if (image == NULL)
        goto MALLOC_ERR;
    image->type = NETPBM_PGM;

    // Open file and scann image properties)
    FILE* inputfile = fopen(filename, "rb");
    if (inputfile == NULL)
    {
        fputs("cannot open input file\n", stderr);
        free_image(image);
        return NULL;
    }
    if ((pgm_type = scann_image_properties(image, inputfile, &buf, &bufsize))
            < 0)
        goto FORMAT_ERR;
    if (image->max_deph > 255)
    {
        fputs("in this version cannot load images with deph > 255\n", stderr);
        goto FORMAT_ERR;
    }

    // Alloc raw image.
    image->image_mono = (raw_image_mono_8_t)malloc(sizeof(uint8_t *) * image->height);
    if (image->image_mono == NULL)
        goto MALLOC_ERR;
    for (i = 0; i < image->height; ++i)
    {
        image->image_mono[i] = (uint8_t *)malloc(sizeof(uint8_t) * image->width);
        if (image->image_mono[i] == NULL)
            goto MALLOC_ERR;
    }

    // Load pixels. (2 types of pgm file, binary or ascii).
    if (pgm_type == PGM_ASCII)
    {
        if (load_ascii_pgm(image, inputfile) != 0)
            goto FORMAT_ERR;
    }
    else if (pgm_type == PGM_BIN)
    {
        if (load_binary_pgm(image, inputfile, &buf, &bufsize) != 0)
            goto FORMAT_ERR;

    }
    else
    {
        fputs("pgm magic number not recognized, only P2 or P5\n", stderr);
        goto FORMAT_ERR;
    }

    if (buf != NULL)
        free(buf);
    fclose(inputfile);
    return image;

FORMAT_ERR:
    if (buf != NULL)
        free(buf);
    fclose(inputfile);
    free_image(image);
    fputs("wrong input format, only pgm\n", stderr);
    return NULL;
MALLOC_ERR:
    if (buf != NULL)
        free(buf);
    fclose(inputfile);
    free_image(image);
    fputs("malloc error\n", stderr);
    return NULL;
}

image_t copy_image(image_t image)
{
    int i, j;

    image_t new_image = (image_t)malloc(sizeof (struct _image_t));
    new_image->width = image->width;
    new_image->height = image->height;
    new_image->max_deph = image->max_deph;
    new_image->type = image->type;

    new_image->image_mono = (raw_image_mono_8_t)malloc(sizeof(uint8_t *) * image->height);
    if (new_image->image_mono == NULL )
    {
        free_image(new_image);
        fputs("malloc error\n", stderr);
        return NULL;
    }

    for (i = 0; i < image->height; ++i)
    {
        new_image->image_mono[i] = (uint8_t *) malloc(
                sizeof(uint8_t) * image->width);
        if (new_image->image_mono[i] == NULL )
        {
            free_image(new_image);
            fputs("malloc error\n", stderr);
            return NULL ;
        }

        for (j = 0; j < image->width; ++j)
        {
            new_image->image_mono[i][j] = image->image_mono[i][j];
        }
    }

    return new_image;
}

int check_image(image_t image)
{
    return (image != NULL) && (image->image_mono != NULL)
            ? IMAGE_STATUS_OK : IMAGE_STATUS_BAD;
}

raw_image_mono_8_t get_raw_image_mono_8(image_t image)
{
    return image->image_mono;
}

void save_image_to_file(image_t image, const char * filename)
{
    int i;
    debug_print(LVL_INFO, "Writing to file %s\n", filename);
    FILE* output = fopen(filename, "wb");
    if (output == NULL)
    {
        debug_print(LVL_ERROR, "malloc error%c", '\n');
        fputs("cannot create or open output file\n", stderr);
        return;
    }

    fprintf(output, "P5\n%d %d\n%d\n", image->width, image->height,
            image->max_deph);
    for (i = 0; i < image->height; ++i)
    {
        fwrite(image->image_mono[i], sizeof(uint8_t), image->width, output);
    }

    fclose(output);
}

void free_image(image_t image)
{
    int i;
    if (image != NULL)
    {
        if (image->image_mono != NULL)
        {
            for (i = 0; i < image->height; ++i)
            {
                if (image->image_mono[i] != NULL)
                {
                    free(image->image_mono[i]);
                    image->image_mono[i] = NULL;
                }
            }
            free(image->image_mono);
            image->image_mono = NULL;
        }
        free(image);
        image = NULL;
    }
}
