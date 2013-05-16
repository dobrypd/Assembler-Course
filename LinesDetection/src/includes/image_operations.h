/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef IMAGE_OPERATIONS_H_
#define IMAGE_OPERATIONS_H_

#include <types.h>
#include "image.h"
#include "detector.h"

extern void image_segmentation(image_t image, unsigned int max_spectrum);
extern void add_lines_to_image(image_t image, lines_t lines, uint8_t color_line,
        uint8_t color_bg);


#endif /* IMAGE_OPERATIONS_H_ */
