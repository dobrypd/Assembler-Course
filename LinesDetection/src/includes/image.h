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

typedef int * * kernel_t;
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
 * Allocating memory for monochromatic raw image.
 */
extern raw_image_mono_8_t alloc_raw(int width, int height);

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

/*
 * Frees raw monochromatic image.
 */
extern void free_kernel(kernel_t raw, int height);
extern void free_raw(raw_image_mono_8_t raw, int height);

/*
 * Copying raw monochromatic image.
 */
extern raw_image_mono_8_t copy_raw(raw_image_mono_8_t raw_image, int width,
        int height);

/*
 * Returns new kernel (mask).
 * ie.
 * -1  0  1
 *  1  2  3
 * -2  3  5
 * could be create by
 * raw_image_mono_8_t mask = new_kernel(3, 3, -1, 0, 1, 1, 2, 3, -2, 3, 5);
 */
extern kernel_t new_kernel(int width, int height, ...);

#endif /* IMAGE_H_ */
