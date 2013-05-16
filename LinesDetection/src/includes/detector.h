/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

#ifndef DETECTOR_H_
#define DETECTOR_H_

#define DETECTION_STATUS_OK 0
#define DETECTION_STATUS_BAD 1

typedef int * lines_t;

extern lines_t detect_lines(image_t image);
extern void add_line(lines_t lines, int fst_line_begin, int fst_line_end,
        int snd_line_begin, int snd_line_end);
extern void save_lines_to_file(lines_t lines);
extern void free_lines(lines_t lines);

#endif /* DETECTOR_H_ */
