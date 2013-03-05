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
    *iterations = 0;

    char* line = 0;
    size_t size = 0;

    while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
    sscanf(line, "%d %d", &(board->width), &(board->height));
    free(line); line = 0;
    while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
    sscanf(line, "%ld", iterations);
    free(line); line = 0;

    if (debug) fprintf(stderr, "Iterations: %ld, board size: %d x %d\n",
            *iterations, board->width, board->height);

    if (initialize_board(board)) {
        printf("Cannot initialize board, exiting.\n");
        exit(EXIT_FAILURE);
    }

    int i, j;
    char* sub_line;
    for (i = 0; i < board->height; ++i) {
        while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
        sub_line = line;
        for (j = 0; j < board->width; ++j){
            char value;
            sscanf(sub_line, "%c", &value);
            board->cells[i][j] = value == ' ' ? (cell_t)0 : (cell_t)1;
            sub_line += 1; // one character
        }
        free(line); line = 0;
    }

    free(line);
    return 0;
}

int main(int argc, char** argv)
{
    struct Arguments args;
    parse_args(&args, argc, argv);

    struct Board board;
    long iterations;

    if (parse_input(&iterations, &board)) {
        printf("Input error.\nInput schema:\n\twidth height\n\t"
                "cell_0_0 cell_0_1 ... cell_0_width-1\n\t"
                "cell_1_0 cell_1_1 ... cell_1_width-1\n\t...\n\t"
                "cell_height-1_0 cell_height-1_1 ... cell_height-1_width-1\n"
                "where cell_x_y is ' ' (dead) or 'X' (alive).\nExiting.\n");
        return EXIT_FAILURE;
    }

    if (debug) fprintf(stderr, "Starting game.\n");
    start_game(&board, iterations, ((args.summarize != 0) ? 0 : &print_board));
    if (args.summarize) print_board(&board);

    if (free_board(&board)) {
        if (debug) fprintf(stderr, "Cannot free board.\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
