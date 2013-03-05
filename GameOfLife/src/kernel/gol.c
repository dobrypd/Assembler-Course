/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "game.h"

#ifndef NDEBUG
    const int debug=1;
#else
    const int debug=0;
#endif

void show_help(char* prog_name)
{
    printf("using %s [options]\n"
            "options:\n"
            "-h\t- show this help message,\n"
            "-s\t- summarize, display only last board,\n", prog_name);
}

struct Arguments {
    int summarize;
};

void parse_args(struct Arguments* args, int argc, char** argv)
{
    args->summarize = 0;
    int c;
    while ((c = getopt(argc, argv, "hs")) != -1)
    {
        switch (c)
        {
        case 'h':
            show_help(argv[0]);
            exit(EXIT_SUCCESS);
            break;
        case 's':
            args->summarize = 1;
            break;
        case '?':
            show_help(argv[0]);
            exit(EXIT_FAILURE);
            break;
        default:
            show_help(argv[0]);
            exit(EXIT_FAILURE);
            break;
        }
    }
}

//int parse_input(Board* board);

int main(int argc, char** argv)
{
    struct Arguments args;
    parse_args(&args, argc, argv);
    //parse_input(state);
    //init_board(state);
    return EXIT_SUCCESS;
}
