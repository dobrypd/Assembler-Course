/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <limits.h>

#include "config.h"
#include "image.h"
#include "detector.h"
#include "image_operations.h"

static const char * version_no = "0.0.alpha";
static const char * default_output_filename = "out";
static const int default_minimum_line_length = 25;

enum output_format_t
{
    NETPBM,
    TEXTFILE
};

static struct global_args_t {
    unsigned int min_line_length;
    enum output_format_t output_format;
    const char *out_filename;
    int verbosity;
    char *input_filename;
    int color_line;
    int color_bg;
} global_args;

enum
{
    LINE_COLOR_OPTION = CHAR_MAX + 1,
    BG_COLOR_OPTION,
    HELP_OPTION,
    VERSION_OPTION
};

static const struct option long_options[] = {
    { "min-line-len", no_argument, NULL, 'm' },
    { "pgm-format", no_argument, NULL, 'f' },
    { "output", required_argument, NULL, 'o' },
    { "verbose", no_argument, NULL, 'v' },
    { "line-color", required_argument, NULL, LINE_COLOR_OPTION },
    { "bg-color", required_argument, NULL, BG_COLOR_OPTION },
    { "help", no_argument, NULL, HELP_OPTION },
    { "version", no_argument, NULL, VERSION_OPTION },
    { NULL, no_argument, NULL, 0 }
};

static char * program_name;

static void initialize_global_args();
static void parse_args(int argc, char * argv[]);
static void usage(int status);
static void version();

static void initialize_global_args()
{
    global_args.min_line_length = default_minimum_line_length;
    global_args.output_format = TEXTFILE;
    global_args.out_filename = NULL;
    global_args.verbosity = 0;
    global_args.input_filename = NULL;
    global_args.color_line = 255;
    global_args.color_bg = 0;
}

static void parse_args(int argc, char * argv[])
{
    int opt;
    while (1)
    {
        int oi = -1;
        opt = getopt_long(argc, argv, "m:fo:v", long_options, &oi);
        if (opt == -1)
            break;

        switch(opt)
        {
        unsigned long int tmp_ulong;
        case 'm':
            if (((tmp_ulong = strtoul (optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UINT_MAX))
                usage(EXIT_FAILURE);
            global_args.min_line_length = tmp_ulong;
            break;
        case 'f':
            global_args.output_format = NETPBM;
            break;
        case 'o':
            global_args.out_filename = optarg;
            break;
        case 'v':
            global_args.verbosity = 1;
            break;
        case LINE_COLOR_OPTION:
            if (((tmp_ulong = strtoul (optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UCHAR_MAX))
                usage(EXIT_FAILURE);
            global_args.color_line = tmp_ulong;
            break;
        case BG_COLOR_OPTION:
            if (((tmp_ulong = strtoul (optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UCHAR_MAX))
                usage(EXIT_FAILURE);
            global_args.color_bg = tmp_ulong;
            break;
        case VERSION_OPTION:
            version();
            exit(EXIT_SUCCESS);
            break;
        case HELP_OPTION:
            usage(EXIT_SUCCESS);
            break;
        default:
            usage(EXIT_FAILURE);
            /* no break */
        }
    }
}

int main(int argc, char * argv[])
{
    debug_print(3, "Starting with %d args.\n", argc);
    program_name = argv[0];
    initialize_global_args();
    parse_args(argc, argv);

    if (global_args.verbosity > 0)
        version();

    image_t image;
    image = load_image_from_file(global_args.input_filename);
    if (check_image(image) != IMAGE_STATUS_OK)
    {
        free_image(image);
        fputs("Cannot continue: error while loading image.\n\n", stderr);
        exit(EXIT_FAILURE);
    }

    lines_t lines;
    lines = detect_lines(image);
    if (check_lines(lines) != DETECTION_STATUS_OK)
    {
        free_image(image);
        free_lines(lines);
        fputs("Cannot continue: error while detecting lines.\n\n", stderr);
        exit(EXIT_FAILURE);
    }

    if (global_args.output_format == NETPBM)
    {
        image_t output_image;
        output_image = copy_image(image);
        if (check_image(output_image) != IMAGE_STATUS_OK)
        {
            free_image(image);
            free_image(output_image);
            free_lines(lines);
            fputs("Cannot continue: error while copying image.\n\n", stderr);
            exit(EXIT_FAILURE);
        }
        add_lines_to_image(output_image, lines, global_args.color_line,
                global_args.color_bg);
        save_image_to_file(output_image, ((global_args.out_filename == NULL)
                ? (default_output_filename) : (global_args.out_filename)));
        free_image(output_image);
    }
    else if (global_args.out_filename != NULL)
    {
        save_lines_to_file(lines, global_args.out_filename);
    }

    free_lines(lines);
    free_image(image);

    return 0;
}

static void usage(int status)
{
    printf("Usage: %s [OPTION]... FILE\n", program_name);
    fputs("\
Find all lines in monochromatic picture. If non of --pgm_format, or --output\n\
declared it returns list of pairs, (point_start, point_stop).\n\
Where point_start, and point_stop are pairs of integers.\n\
\n\
Input FILE must be Netpbm grayscale image.\n\
\n\
Mandatory arguments to long options are mandatory for short options too.\n\
  -m, --min-line-len SIZE    declare minimum length of all lines\n\
  -f, --pgm-format           output as Netpbm file, instead of textfile\n\
      --line-color COLOR     set color of the lines,\n\
                               only with --pgm-format, default=255\n\
      --bg-color COLOR       set the color of background,\n\
                               only with --pgm-format, default=0\n\
  -o, --output FILE          save in filename, if exists will be override\n\
                               (out.txt or out.pgm by default)\n\
  -v, --verbose              increase verbosity\n\
      --help                 display this help and exit\n\
      --version              output version information and exit\n\
", stdout);
    exit(status);
}

static void version()
{
    fprintf(stdout, "\
Line Detector %s\n\
Piotr Dobrowolski (c) 2013\n\
", version_no);
}
