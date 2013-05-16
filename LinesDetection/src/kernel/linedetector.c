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

#ifndef NDEBUG
#ifdef DBGLVL
    static const int dbg_lvl = DNGLVL;
#endif
#endif

enum output_format_t
{
    NETPBM,
    TEXTFILE
};

static const char * default_output_filename = "out";

static struct global_args_t {
    int min_line_length;
    enum output_format_t output_format;
    const char *out_filename;
    FILE *out_file;
    int verbosity;
    char *input_filename;
    FILE *in_file;
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


static void initialize_global_args()
{
    global_args.min_line_length = 25;
    global_args.output_format = TEXTFILE;
    global_args.out_filename = default_output_filename;
    global_args.out_file = NULL;
    global_args.verbosity = 0;
    global_args.input_filename = NULL;
    global_args.in_file = NULL;
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
        case 'm':
            break;
        case 'f':
            break;
        case 'o':
            break;
        case 'v':
            break;
        case LINE_COLOR_OPTION:
            break;
        case BG_COLOR_OPTION:
            break;
        case VERSION_OPTION:
            break;
        case HELP_OPTION:
            break;
        default:
            usage(EXIT_FAILURE);
        }
    }
}

int main(int argc, char * argv[])
{
    program_name = argv[0];
    initialize_global_args();
    parse_args(argc, argv);
    return 0;
}

static void usage(int status)
{
    if (status == EXIT_SUCCESS)
    {
        //emit_try_help();
    }
    else
    {
        printf("Usage: %s [OPTION]... FILE\n", program_name);
        fputs("\
Find all lines in monochromatic picture. If non of --pgm_format, or --output\n\
declared it returns list of pairs, (point_start, point_stop).\n\
Where point_start, and point_stop are pairs of integers.\n\
\n\
Mandatory arguments to long options are mandatory for short options too.\n\
  -m, --min-line-len SIZE    declare minimum length of all lines\n\
  -f, --pgm-format           output as NETPBM file, instead of textfile\n\
      --line-color COLOR     set color of the lines,\n\
                               only with --pgm-format, default=255\n\
      --bg-color COLOR       set the color of background,\n\
                               only with --pgm-format, default=0\n\
  -o, --output FILENAME      save in filename, if exists will be override\n\
                               (default=out)\n\
  -v, --verbose              increase verbosity\n\
      --help                 display this help and exit\n\
      --version              output version information and exit\n\
", stdout);
    }
    exit(status);
}
