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
static const char * default_output_filename = "out.pgm";
static const int default_minimum_line_length = 25;
static const int default_threshold = 40;
static const float default_sigma = 1.0;
static const int default_radius = 4;

enum output_format_t
{
    NETPBM,
    TEXTFILE
};

static struct global_args_t {
    unsigned int min_line_length;
    uint8_t threshold;
    float sigma;
    int radius;
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
    { "threshold", no_argument, NULL, 't' },
    { "sigma", no_argument, NULL, 's' },
    { "radius", no_argument, NULL, 'r' },
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
    global_args.threshold = default_threshold;
    global_args.sigma = default_sigma;
    global_args.radius = default_radius;
    global_args.output_format = TEXTFILE;
    global_args.out_filename = NULL;
    global_args.verbosity = 0;
    global_args.input_filename = NULL;
    global_args.color_line = 150;
    global_args.color_bg = -1;
}

static void parse_args(int argc, char * argv[])
{
    debug_print(LVL_INFO, "Parsing arguments %d\n", argc);
    int opt;
    while (1)
    {
        int oi = -1;
        opt = getopt_long(argc, argv, "m:t:s:r:fo:v", long_options, &oi);
        if (opt == -1)
            break;

        switch(opt)
        {
        unsigned long int tmp_ulong;
        float tmp_float;
        case 'm':
            if (((tmp_ulong = strtoul(optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UINT_MAX))
                usage(EXIT_FAILURE);
            global_args.min_line_length = tmp_ulong;
            debug_print(LVL_INFO, "Setting minimal len to %lu\n", tmp_ulong);
            break;
        case 't':
            if (((tmp_ulong = strtoul(optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UCHAR_MAX))
                usage(EXIT_FAILURE);
            global_args.threshold = tmp_ulong;
            debug_print(LVL_INFO, "Setting threshold to %lu\n", tmp_ulong);
            break;
        case 's':
            if ((tmp_float = strtod(optarg, NULL)) == 0)
                usage(EXIT_FAILURE);
            global_args.sigma = tmp_float;
            debug_print(LVL_INFO, "Setting sigma to %f\n", tmp_float);
            break;
        case 'r':
            if (((tmp_ulong = strtoul(optarg, NULL, 0)) == 0)
                    || (tmp_ulong > UCHAR_MAX))
                usage(EXIT_FAILURE);
            global_args.radius = tmp_ulong;
            debug_print(LVL_INFO, "Setting radius to %lu\n", tmp_ulong);
            break;
        case 'f':
            global_args.output_format = NETPBM;
            break;
        case 'o':
            global_args.out_filename = optarg;
            debug_print(LVL_INFO, "Setting output filename to %s\n", optarg);
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

    if (global_args.verbosity > 0)
        puts("verbose flag is set\n");

    if (optind != (argc - 1))
    {
        puts("You must declare one input file.\n");
        usage(EXIT_FAILURE);
    }
    else
    {
        global_args.input_filename = argv[optind];
        debug_print(LVL_INFO, "Input filename %s\n", argv[optind]);
    }
}

int main(int argc, char * argv[])
{
    debug_print(LVL_LOWEST, "Starting with %d args.\n", argc);
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
    if (global_args.verbosity > 0)
        printf("Loaded %s.\nBeggining line detection.\n",
                global_args.input_filename);

    lines_t lines;
    lines = detect_lines(image, global_args.min_line_length,
            global_args.threshold, global_args.sigma, global_args.radius,
            global_args.out_filename == NULL);
    if (check_lines(lines) != DETECTION_STATUS_OK)
    {
        free_image(image);
        free_lines(lines);
        fputs("Cannot continue: error while detecting lines.\n\n", stderr);
        exit(EXIT_FAILURE);
    }

    if (global_args.verbosity > 0)
        printf("Detected %d lines.\n", lines_how_many(lines));

    if (global_args.output_format == NETPBM)
    {
        debug_print(LVL_INFO, "Saving pgm %s\n", global_args.out_filename);
        if (global_args.verbosity > 0)
            printf("Will save pgm file in %s.\n", global_args.out_filename);
        // XXX: Commented for testing purpose. Uncomment it!
        add_lines_to_image(image, lines, global_args.color_line,
                global_args.color_bg);
        save_image_to_file(image, ((global_args.out_filename == NULL)
                ? (default_output_filename) : (global_args.out_filename)));
    }
    else if (global_args.out_filename != NULL)
    {
        debug_print(LVL_INFO, "Saving txt %s\n", global_args.out_filename);
        if (global_args.verbosity > 0)
            printf("Will save txt file in %s.\n", global_args.out_filename);
        save_lines_to_file(lines, global_args.out_filename);
    }

    free_lines(lines);
    free_image(image);

    if (global_args.verbosity > 0)
        printf("Finished with success!\n");
    debug_print(LVL_LOWEST, "Finished %s.\n", program_name);
    return EXIT_SUCCESS;
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
  Few words about used algorithm: firstly, to reduce noise, is used\n\
Gaussian blur filter. You can change arguments of this smoothing:\n\
sigma, and radius.\n\
After this operation thresholding will be applied. You can change value of\n\
threshold color.\n\
Last step is to do the Hough Transform, and find lines (sections).\n\
You can change the minimum length of segment to find.\n\
\n\
Mandatory arguments to long options are mandatory for short options too.\n\
  -m, --min-line-len SIZE    declare minimum length of all lines\n\
  -t, --threshold COLOR      declare threshold in edge detection\n\
                               from [0, 256), default=40\n\
  -s, --sigma VALUE          set float value of Gaussian kernel\n\
                               default=1.0\n\
  -r, --radius VALUE         set radius of Gaussian kernel\n\
                               default=4\n\
  -f, --pgm-format           output as Netpbm file, instead of textfile\n\
      --line-color COLOR     set color of the lines,\n\
                               only with --pgm-format, default=255\n\
      --bg-color COLOR       set the color of background,\n\
                               only with --pgm-format, default=-1\n\
                               (transparent to original image)\n\
  -o, --output FILE          save in filename, if exists will be override\n\
                               (out.pgm by default, if not set and without -f\n\
                               then lines will be returned to stdout)\n\
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
