/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef DETECTOR_H_
#define DETECTOR_H_

#include <stddef.h>
#include "image.h"

#define DETECTION_STATUS_OK 1
#define DETECTION_STATUS_BAD 0

#define lines_len_add_size 1024

struct _lines_t
{
    unsigned int size;
    size_t mem_size;

    unsigned int * begin_x;
    unsigned int * begin_y;
    unsigned int * end_x;
    unsigned int * end_y;
};

typedef struct _lines_t * lines_t;

/*
 * Main compuing function, will call engine function.
 * Allocating lines.
 */
extern lines_t detect_lines(image_t image, unsigned int minimal_line_length,
        uint8_t threshold, int return_outputs_on_stdout);

/*
 * Check if lines exists. Try to check if detection works.
 */
extern int check_lines(lines_t lines);

/*
 * Returns number of detected lines.
 */
extern int lines_how_many(lines_t lines);

/*
 * Function which will be send to engine to add line to lines.
 */
extern void add_line(lines_t lines, unsigned int begin_x, unsigned int begin_y,
        unsigned int end_x, unsigned int end_y);

/*
 * Saves lines to textfile.
 */
extern void save_lines_to_file(lines_t lines, const char * filename);

/*
 * Frees lines.
 */
extern void free_lines(lines_t lines);

#endif /* DETECTOR_H_ */
