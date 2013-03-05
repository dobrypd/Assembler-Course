/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "board.h"
#include "game.h"
#include "printer.h"

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

int parse_input(long* iterations, struct Board* board)
{
    return 0;
}

int main(int argc, char** argv)
{
    struct Arguments args;
    parse_args(&args, argc, argv);

    struct Board board;
    long iterations;

    if (parse_input(&iterations, &board))
        printf("Input error.\nInput schema:\n"
                "width height\n"
                "cell_0_0 cell_0_1 ... cell_0_width-1\n"
                "cell_1_0 cell_1_1 ... cell_1_width-1\n"
                "...\n"
                "cell_height-1_0 cell_height-1_1 ... cell_height-1_width-1\n"
                "where cell_x_y is 0 (dead) or 1 (alive)\n");

    initialize_board(&board);

    start_game(&board, iterations, ((args->summarize != 0) ? 0 : &print_board));

    if (args->summarize)
        print_board(&board);

    free_board(&board);

    return EXIT_SUCCESS;
}
