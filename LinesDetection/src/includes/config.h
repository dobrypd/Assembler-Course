/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef CONFIG_H_
#define CONFIG_H_

#ifndef NDEBUG
#ifdef DBGLVL
    static const int dbg_lvl = DNGLVL;
#else
    static const int dbg_lvl = 1;
#endif
#else
    static const int dbg_lvl = 0;
#endif

static const char * text_file_ext = "txt";
static const char * NETPBM_file_ext = "pgm";

#endif /* CONFIG_H_ */
