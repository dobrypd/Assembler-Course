/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef CONFIG_H_
#define CONFIG_H_

#ifndef NDEBUG
#ifndef DBGLVL
#define DBGLVL 1
#endif
#else
#define DBGLVL 0
#endif


/*
 * This macro should be removed by gcc optimizations if not in debug mode.
 */
#define debug_print(lvl, fmt, ...) \
    do { if (DBGLVL >= lvl) fprintf(stderr, "%s:%d:%s(): " fmt, __FILE__, \
            __LINE__, __func__, __VA_ARGS__); } while (0)

#endif /* CONFIG_H_ */
