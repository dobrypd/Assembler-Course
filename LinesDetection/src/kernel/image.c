/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "config.h"
#include "image.h"

const char * NETPBM_file_ext = "pgm";

static int load_ascii_pgm(image_t image, FILE* inputfile)
{
    unsigned int i, j;
    debug_print(LVL_INFO, "Scanning ascii file %p.\n", inputfile);
    for (i = 0; i < image->height; ++i)
        for (j = 0; j < image->width; ++j)
        {
            if (fscanf(inputfile, "%c", &(image->image_mono[i][j])) == EOF)
                return -1;
        }
    debug_print(LVL_INFO, "Scanned successfully file %p.\n", inputfile);
    return 0;
}

static int load_binary_pgm(image_t image, FILE* inputfile)
{
    unsigned int i, j;
    debug_print(LVL_INFO, "Scanning binnary file %p.\n", inputfile);
    uint8_t loaded;
    for (i = 0; i < image->height; ++i)
    {
        for (j = 0; j < image->width; ++j)
        {
            if (fread(&loaded, sizeof(uint8_t), 1, inputfile) < 1)
                return -1;
            image->image_mono[i][j] = loaded;
        }
        if ((i < (image->height - 1))
                && (fread(&loaded, sizeof(uint8_t), 1, inputfile) < 1))
            return -1;
    }
    debug_print(LVL_INFO, "Scanned successfully file %p.\n", inputfile);
    return 0;
}

image_t load_image_from_file(const char * filename)
{
    size_t scanned_bytes;
    size_t number_bytes;
    char * buf = NULL;
    char s_char;
    int is_ascii; // otherwise binary
    int scanned_args = 0;
    int i;

    debug_print(LVL_INFO, "Loading image from file %s.\n", filename);

    buf = (char *)malloc(sizeof (char) * 1024);
    image_t image = (image_t)malloc(sizeof (struct _image_t));
    if ((image == NULL) || (buf == NULL))
    {
        fputs("malloc error\n", stderr);
        return NULL;
    }
    image->type = NETPBM_PGM;

    FILE* inputfile = fopen(filename, "rb");
    if (inputfile == NULL)
    {
        fputs("cannot open input file\n", stderr);
        free(image);
        return NULL;
    }

    // Check magic number.
    debug_print(LVL_LOWER, "Scanning for MAGIC NUMBER %s.\n", filename);
    scanned_bytes = fread(buf, sizeof (char), 2, inputfile);
    if (scanned_bytes < 2)
        goto FORMATERR;
    buf[2] = '\0';
    debug_print(LVL_LOWER, "Scanned:>%s\n", buf);
    if (strcmp(buf, "P2") == 0)
        is_ascii = 1;
    else if (strcmp(buf, "P5") == 0)
        is_ascii = 0;
    else
        goto FORMATERR;
    debug_print(LVL_INFO, "Magic number is:%s\n", is_ascii ? ("P2") : ("P5"));

    number_bytes = 0;

    while (1)
    {
        scanned_bytes = fread(&s_char, sizeof (char), 1, inputfile);
        if (scanned_bytes == 0)
            goto FORMATERR;
        if (s_char == '#')
        {
            if (getline(&buf, &scanned_bytes, inputfile) == -1)
                goto FORMATERR;
            debug_print(LVL_INFO, "Scanned comment:%s\n", buf);
            continue;
        }
        else
        {
            if (isspace(s_char))
            {
                if (number_bytes > 0)
                {
                    buf[number_bytes] = '\0';
                    if (scanned_args == 0)
                    {
                        sscanf(buf, "%d", &(image->width));
                        scanned_args = 1;
                        debug_print(LVL_LOWER, "Scanned width:%d\n",
                                image->width);
                        number_bytes = 0;
                    }
                    else if (scanned_args == 1)
                    {
                        sscanf(buf, "%d", &(image->height));
                        scanned_args = 2;
                        debug_print(LVL_LOWER, "Scanned height:%d\n",
                                    image->height);
                        number_bytes = 0;
                    }
                    else if (scanned_args == 2)
                    {
                        sscanf(buf, "%d", &(image->max_deph));
                        scanned_args = 3;
                        debug_print(LVL_LOWER, "Scanned deph:%d\n",
                                    image->max_deph);
                        number_bytes = 0;
                    }
                }
                else
                {
                    number_bytes = 0;
                }
            }
            else
            {
                if (scanned_args == 3)
                {
                    fseek(inputfile, -1, SEEK_CUR);
                    break;
                }
                buf[number_bytes++] = s_char;
            }
        }

    }

    image->image_mono = (raw_image_mono_8_t)malloc(sizeof(uint8_t *) * image->height);
    if (image->image_mono == NULL)
    {
        free(buf);
        fclose(inputfile);
        free_image(image);
        fputs("malloc error\n", stderr);
        return NULL;
    }
    for (i = 0; i < image->height; ++i)
    {
        image->image_mono[i] = (uint8_t *)malloc(sizeof(uint8_t) * image->width);
        if (image->image_mono[i] == NULL)
        {
            free(buf);
            fclose(inputfile);
            free_image(image);
            fputs("malloc error\n", stderr);
            return NULL;
        }
    }

    if (is_ascii)
    {
        if (load_ascii_pgm(image, inputfile) != 0)
            goto FORMATERR;
    }
    else
    {
        if (load_binary_pgm(image, inputfile) != 0)
            goto FORMATERR;

    }

    free(buf);
    fclose(inputfile);
    return image;

FORMATERR:
    debug_print(LVL_WARNING, "Input error, bad format %s.\n", filename);
    free(buf);
    fclose(inputfile);
    free_image(image);
    fputs("wrong input format, only pgm\n", stderr);
    return NULL;
}

image_t copy_image(image_t image)
{
    int i;
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
    }

    fprintf(output, "P5\n%d %d\n%d\n", image->width, image->height,
            image->max_deph);
    for (i = 0; i < image->height; ++i)
        fwrite(image->image_mono[i], sizeof(uint8_t), image->width, output);
        fputc((int)'\n', output);
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
                }
            }
            free(image->image_mono);
        }
        free(image);
    }
}
