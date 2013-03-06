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

#define WIDTH   50
#define HEIGHT  60

void show_help(char* prog_name)
{
    printf("using %s [options]\n"
            "options:\n"
            "-x value\t- declare board width (default %d),\n"
            "-y value\t- declare board height (default %d),\n"
            "-h\t- show this help message,\n"
            "-s\t- summarize, display only last board,\n",
            prog_name, WIDTH, HEIGHT);
}

struct Arguments {
    int summarize;
    int width;
    int height;
};

void parse_args(struct Arguments* args, int argc, char** argv)
{
    args->summarize = 0;
    args->width = WIDTH;
    args->height = HEIGHT;
    int c;
    while ((c = getopt(argc, argv, "hsx:y:")) != -1)
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
        case 'x':
            args->width = atoi(optarg);
            break;
        case 'y':
            args->height = atoi(optarg);
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
    int input_width = 0, input_height = 0;

    while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
    sscanf(line, "%ld", iterations);
    free(line); line = 0;
    while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
    sscanf(line, "%d %d", &input_width, &input_height);
    free(line); line = 0;

#ifndef NDEBUG
    fprintf(stderr, "Iterations: %ld, input board size: %d x %d\n",
            *iterations, input_width, input_height);
#endif
    if ((input_width > board->width) || (input_height > board->height)) {
        fprintf(stderr, "Input is too large, maximum board size is: %d x %d",
                board->width, board->height);
        return -1;
    }

    int i, j;
    char* sub_line;
    for (i = 0; i < input_height; ++i) {
        while ((line == 0) || (line[0] == '#')) getline(&line, &size, stdin);
        sub_line = line;
        for (j = 0; j < input_width; ++j){
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

    board.width = args.width;
    board.height = args.height;

    if (initialize_board(&board)) {
        fprintf(stderr, "Cannot initialize board, exiting.\n");
        exit(EXIT_FAILURE);
    }

    if (parse_input(&iterations, &board)) {
        fprintf(stderr, "Input error.\nInput schema:\n\twidth height\n\t"
                "cell_0_0 cell_0_1 ... cell_0_width-1\n\t"
                "cell_1_0 cell_1_1 ... cell_1_width-1\n\t...\n\t"
                "cell_height-1_0 cell_height-1_1 ... cell_height-1_width-1\n"
                "where cell_x_y is ' ' (dead) or 'X' (alive).\nExiting.\n");
        return EXIT_FAILURE;
    }

    start_game(&board, iterations, ((args.summarize != 0) ? 0 : &print_board));
    if (args.summarize) print_board(&board);

    if (free_board(&board)) {
#ifndef NDEBUG
        fprintf(stderr, "Cannot free board.\n");
#endif
        return EXIT_FAILURE;
    }

#ifndef NDEBUG
    fprintf(stderr, "Exiting with success!\n");
#endif
    return EXIT_SUCCESS;
}
