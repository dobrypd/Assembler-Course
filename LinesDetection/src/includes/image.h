/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef IMAGE_H_
#define IMAGE_H_

#include <stdint.h>

typedef uint8_t * * raw_image_mono_8_t;
typedef uint8_t * * image_t;

#define IMAGE_STATUS_OK 0
#define IMAGE_STATUS_BAD 1

enum image_file_type
{
    NETPBM_PGM
};

extern image_t load_image_from_file(const char * filename);
extern image_t copy_image(image_t image);
extern int check_image(image_t image);
extern raw_image_mono_8_t get_raw_image_mono_8(image_t image);
extern void save_image_to_file(image_t image, const char * filename);
extern void free_image(image_t image);

#endif /* IMAGE_H_ */
