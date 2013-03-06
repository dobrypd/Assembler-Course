/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

// game of life, function for one iteration
// ;; only for testing


#include <stdint.h>

#define LIVE_OR_DEAD(i, j) \
    do { \
        destination[i][j] = source[i][j]; \
        if (source[i][j] == 1) { \
            if ((nbrs < 2) || (nbrs > 3)) { \
                destination[i][j] = 0; \
            } \
        } else { \
            if (nbrs == 3) { \
                destination[i][j] = 1; \
            } \
        } \
    } while(0)

int make_iteration(int width, int height, uint8_t** source, uint8_t** destination)
{
    int i, j;
    int top, center, bottom;
    int nbrs;
    for (j = 1; j < width-1; ++j)
    {
        top = 0;
        center = 0; // tourus case
        bottom = source[0][j-1] + source[0][j] + source[0][j+1];
        for (i = 0; i < height-1; ++i)
        {
            top = center;
            center = bottom;
            bottom = source[i+1][j-1] + source[i+1][j] + source[i+1][j+1];
            nbrs = top + center + bottom - source[i][j];
            LIVE_OR_DEAD(i, j);
        }
        // right part of frame
        nbrs = center + bottom - source[width-1][j]; // tourus case
        LIVE_OR_DEAD(i, j);
    }

    // j = 0
    top = 0;
    center = 0;
    bottom = source[0][0] + source[0][1];
    for (i = 0; i < height - 1; ++i)
    {
        top = center;
        center = bottom;
        bottom = source[i+1][0] + source[i+1][1];
        nbrs = top + center + bottom - source[i][0];
        LIVE_OR_DEAD(i, 0);
    }
    nbrs = center + bottom - source[width-1][0];
    LIVE_OR_DEAD(height - 1, 0);

    // j = width -1
    top = 0;
    center = 0;
    bottom  = source[0][width-2] + source[0][width-2];
    for (i = 0; i < height - 1; ++i)
    {
        top = center;
        center = bottom;
        bottom = source[i+1][width-2] + source[i+1][width-1];
        nbrs = top + center + bottom - source[i][width-1];
        LIVE_OR_DEAD(i, width-1);
    }
    nbrs = center + bottom - source[width-1][height-1];
    LIVE_OR_DEAD(height - 1, width - 1);

    return 0;
}

