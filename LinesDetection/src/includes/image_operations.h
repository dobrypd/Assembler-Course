/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef IMAGE_OPERATIONS_H_
#define IMAGE_OPERATIONS_H_

#include <stdint.h>

#include "image.h"
#include "detector.h"

/*
 * Map colors from (0, MAX_COLOR) to (0, max_spectrum). Map by linear function.
 */
extern void image_segmentation(image_t image, unsigned int max_spectrum);

/*
 * Adds lines to image, to visualize.
 */
extern void add_lines_to_image(image_t image, lines_t lines, uint8_t color_line,
        uint8_t color_bg);


#endif /* IMAGE_OPERATIONS_H_ */
