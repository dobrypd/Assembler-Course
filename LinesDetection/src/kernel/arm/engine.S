/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

    .arch armv5
//    .eabi_attribute /*sth*/

    .file   "engine.S"
    .global __aeabi_idiv
    //.global __divsi3
    .section    .rodata
    .align  2

#ifndef NDEBUG
.debug_output:
    .ascii ">DBG: (line:%4d) val: %-12d : %#x\012\000"
#endif

    .text
    .align  2
    .global find_lines
    .type   find_lines, %function


#ifndef NDEBUG
#define pushall \
    stmfd sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
#define popall \
    ldmfd sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
#define debug_print(REGISTER) \
    pushall ;\
    mov r4, REGISTER ;\
    ldr r0, .DBG_OUT ;\
    mov r1, #__LINE__ ;\
    mov r2, r4 ;\
    mov r3, r4 ;\
    bl printf ;\
    popall
#endif

#define prologue \
    stmfd   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}

#define epilogue \
    ldmfd   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

/**
 *
 * Arguments:
 *    r0    uint8_t * * raw_image
 *    r1    int width
 *    r2    int height
 *    r3    struct _lines_t * lines
 *    r4    void (*f_add_line) (lines_t, uint, uint, uint, uint)
 *    r5    unsigned int minimal_line_length
 *    r6    uint8_t threshold
 *    r7    float sigma
 *    r8    int radius
 *
 */
find_lines:

#ifndef NDEBUG
    //ldr r0, [sp]
    debug_print(r3)
#endif
    prologue
    epilogue


#ifndef NDEBUG
.DBG_OUT:
    .word .debug_output
#endif
.LEND_TEXT_DATA:
    .size   find_lines, .-find_lines
    .ident  "Piotr Dobrowolski"
    .section    .note.GNU-stack,"",%progbits
