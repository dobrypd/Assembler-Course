/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef IMAGE_H_
#define IMAGE_H_

#include <stdint.h>

#define IMAGE_STATUS_OK 1
#define IMAGE_STATUS_BAD 0

enum image_file_type
{
    // In this version only one image file format.
    NETPBM_PGM
};

typedef uint8_t * * raw_image_mono_8_t;
struct _image_t
{
    unsigned int width;
    unsigned int height;
    unsigned int max_deph;
    enum image_file_type type;

    raw_image_mono_8_t image_mono;
};
typedef struct _image_t * image_t;

/*
 * Loading file from file, allocating necessary structures.
 */
extern image_t load_image_from_file(const char * filename);

/*
 * Copying whole image and returns it. Allocating memory for structures.
 */
extern image_t copy_image(image_t image);

/*
 * Check if image exists.
 */
extern int check_image(image_t image);

/*
 * Returns 2 dimensional array of uint8_t with monochromatic colors.
 */
extern raw_image_mono_8_t get_raw_image_mono_8(image_t image);

/*
 * Save image to file.
 */
extern void save_image_to_file(image_t image, const char * filename);

/*
 * Frees image.
 */
extern void free_image(image_t image);

#endif /* IMAGE_H_ */
