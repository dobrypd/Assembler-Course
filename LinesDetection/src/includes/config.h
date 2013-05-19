/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef CONFIG_H_
#define CONFIG_H_

#include <stdio.h>

#ifndef NDEBUG
#ifndef DBGLVL
#define DBGLVL 1
#endif
#else
#define DBGLVL 0
#endif


#define LVL_URGENT 0
#define LVL_ERROR 1
#define LVL_WARNING 2
#define LVL_INFO 3
#define LVL_LOW 4
#define LVL_LOWER 5
#define LVL_LOWEST 6
#define LVL_ALL 1000


/*
 * This macro (code where this macro is used)
 * should be removed by gcc optimizations if not in debug mode.
 */
#define debug_print(lvl, fmt, ...) \
    do { if (DBGLVL >= lvl) fprintf(stderr, "%s:%d:%s(): " fmt, __FILE__, \
            __LINE__, __func__, __VA_ARGS__); } while (0)

#endif /* CONFIG_H_ */
