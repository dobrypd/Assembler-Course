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
.float_debug_output:
    .ascii ">DBG: (line:%4d) val: %-12f : %#x\012\000"
#endif

    .text
    .align  2
    .global find_lines
    .type   find_lines, %function


#ifndef NDEBUG
#define pushall \
    stmfd sp!, {r0-r12}
#define popall \
    ldmfd sp!, {r0-r12}
#define pushallf \
    stmfd sp!, {f0, f1}
#define popallf \
    lfmfd sp!, 1, f0
#define debug_print(REGISTER) \
    pushall ;\
    mov r4, REGISTER ;\
    ldr r0, .DBG_OUT ;\
    mov r1, #0 ;\
    mov r2, r4 ;\
    mov r3, r4 ;\
    bl printf ;\
    popall
#define fdebug_print(REGISTER) \
    pushall ;\
    pushallf ;\
    mvfd f2, REGISTER @ float ;\
    mvfd f0, f2 ;\
    mvfd f1, f2 ;\
    ldr r0, .DBG_OUT + 4 ;\
    mov r1, #__LINE__ ;\
    bl printf ;\
    popallf ;\
    popall
#endif

#define FRAME 264
#define prologue \
    stmfd   sp!, {r4-r11, lr} ;\
    sfmfd   f4, 4, [sp]! ;\
    sub sp, #FRAME

#define epilogue \
    add sp, #FRAME ;\
    lfmfd   f4, 4, [sp]! ;\
    ldmfd   sp!, {r4-r11, pc}

/**
 *
 * Arguments:
 *    r0    uint8_t * * raw_image
 *    r1    int width
 *    r2    int height
 *    r3    struct _lines_t * lines
 *    [sp, #FRAME + 84]   void (*f_add_line) (lines_t, uint, uint, uint, uint)
 *    [sp, #FRAME + 88]   unsigned int minimal_line_length
 *    [sp, #FRAME + 92]   uint8_t threshold
 *    [sp, #FRAME + 96]   float sigma NOPE
 *    [sp, #FRAME + 100]  int radius
 *
 */
find_lines:
    prologue

    // Save all arguments in stack.
    str r0, [sp, #100]
    str r1, [sp, #96]
    str r2, [sp, #92]
    str r3, [sp, #88]

    // Alloc temporary images.
    // Call alloc_raw (width, height)
    mov r6, r0
    mov r4, r0
    mov r0, r1
    mov r1, r2
    bl alloc_raw
    mov r5, r0
    str r0, [sp, #84]
    mov r0, r4
    bl alloc_raw
    str r0, [sp, #80]
    mov r7, r0

    // Alloc gaussian smoothing kernel.
    // Call new_gaussian (radius * 2 + 1, sigma)
    ldr r0, [sp, #FRAME + 100]
    mov r0, r0, asl #1 // *2
    add r0, #1 // +1
    mov r8, r0
    ldr r1, [sp, #FRAME + 96] @ float
    bl new_gaussian
    str r0, [sp, #76]

    // Return if error with allocating.
    teq r0, #0
    beq .EXIT
    teq r5, #0
    beq .EXIT
    teq r7, #0
    beq .EXIT

#ifndef NDEBUG
    debug_print(r5)
    debug_print(r7)
    debug_print(r0)
#endif

    /**
     * Phase 1: Add gaussian mask. Smoothing.
     */
.ADD_MASK:
    // Sum kernel cells to normalize.
    mov r7, #0
    mov r1, #0
.FOR_NORM_BEGIN_ROW:
    cmp r1, r8
    bge .NORM_DONE
    mov r9, #0
.FOR_NORM_BEGIN_COLUMN:
    cmp r9, r8
    bge .FOR_NORM_END_COLUMN
    ldr r3, [r0, r1, asl #2]
    ldrb r3, [r3, r9, asl #2]
    add r7, r3
    add r9, #1
    b .FOR_NORM_BEGIN_COLUMN
.FOR_NORM_END_COLUMN:
    add r1, #1
    b .FOR_NORM_BEGIN_ROW
.NORM_DONE:
#ifndef NDEBUG
    debug_print(r7)
#endif

    mov r1, r8, asr #1 // central
#ifndef NDEBUG
    debug_print(r1)
#endif
    ldr r2, [sp, #92]
    ldr r4, [sp, #96]
    sub r2, r1
    sub r4, r1
    str r1, [sp, #16]
    str r2, [sp, #20]
    str r4, [sp, #24]
    str r8, [sp, #28]
#ifndef NDEBUG
    debug_print(r2)
    debug_print(r4)
#endif

    str r7, [sp, #4] // store norm
    mov r3, r1 // i = central
    str r3, [sp, #8] // store i
.FOR_SMOOTH1_BEGIN_ROW:
    cmp r3, r2
    bge .SMOOTH1_DONE
    mov r3, r1
    str r3, [sp, #12] // store j
.FOR_SMOOTH1_BEGIN_COLUMN:
    cmp r3, r4
    bge .FOR_SMOOTH1_END_COLUMN

    mov r3, #0 // kernel_i
    ldr r5, [sp, #8] // i
    sub r5, r1 // ii = i-central
    mov r9, #0 // val = 0
.FOR_SMOOTH1_KERN_BEGIN_ROW:
    cmp r3, r8
    bge .SMOOTH1_KERN_DONE
    mov r7, #0 // kernel_j
    ldr r4, [sp, #12] // j
    sub r4, r1 // jj = j-central
.FOR_SMOOTH1_KERN_BEGIN_COLUMN:
    cmp r7, r8
    bge .FOR_SMOOTH1_KERN_END_COLUMN

    //val += input[ii][jj] * kernel[kern_i][kern_j];
    ldr r6, [sp, #76] // kernel
    ldr r6, [r6, r3, asl #2]
    ldrb r6, [r6, r7, asl #2]
    ldr r2, [sp, #100] // input (raw_image)
    ldr r2, [r2, r5, asl #2]
    ldrb r2, [r2, r4, asl #2]
    mul r0, r2, r6
    add r9, r0 // val+=r0

    add r7, #1
    add r4, #1
    b .FOR_SMOOTH1_KERN_BEGIN_COLUMN
.FOR_SMOOTH1_KERN_END_COLUMN:
    add r3, #1
    add r5, #1
    b .FOR_SMOOTH1_KERN_BEGIN_ROW
.SMOOTH1_KERN_DONE:
    // norm
    ldr r1, [sp, #4]
    mov r0, r9
    bl __divsi3 // val in r0
    ldr r3, [sp, #12] // load j to r3
    ldr r2, [sp, #8] // load i to r2
    ldr r9, [sp, #84] // tmp1 to r9
    ldr r9, [r9, r2, asl #2]
    strb r0, [r9, r3, asl #2]
    add r3, #1
    str r3, [sp, #12] // store j
    ldr r1, [sp, #16] // central
    ldr r4, [sp, #24] // width - central
    b .FOR_SMOOTH1_BEGIN_COLUMN
.FOR_SMOOTH1_END_COLUMN:
    // Load for line 178.
    ldr r2, [sp, #20] // height - central
    ldr r8, [sp, #28] // kernel size
    ldr r3, [sp, #8] // load i
    add r3, #1
    str r3, [sp, #8] // sore i
    b .FOR_SMOOTH1_BEGIN_ROW
.SMOOTH1_DONE:

// Frame
    str r7, [sp, #4] // store norm
    mov r3, #0 // i = 0
    str r3, [sp, #8] // store i
.FOR_SMOOTH2_BEGIN_ROW:
    ldr r2, [sp, #92]
    cmp r3, r2
    bge .SMOOTH2_DONE
//if i == central + 1
    ldr r0, [sp, #16]
    add r0, #1
    cmp r3, r0
    bne .DO_NOT_ADD_TO_I
    ldr r3, [sp, #92]
    sub r3, #1
    sub r3, r1 // i = height - 1 - central
    str r3, [sp, #8]
.DO_NOT_ADD_TO_I:
    mov r3, #0
    str r3, [sp, #12] // store j
.FOR_SMOOTH2_BEGIN_COLUMN:
    ldr r4, [sp, #96]
    cmp r3, r4
    bge .FOR_SMOOTH2_END_COLUMN
//if j == central + 1
    ldr r0, [sp, #16]
    add r0, #1
    cmp r3, r0
    bne .DO_NOT_ADD_TO_J
    ldr r3, [sp, #92]
    sub r3, #1
    sub r3, r1 // i = height - 1 - central
    str r3, [sp, #12]
.DO_NOT_ADD_TO_J:
    mov r3, #0 // kernel_i
    ldr r5, [sp, #8] // i
    sub r5, r1 // ii = i-central
    mov r9, #0 // val = 0
.FOR_SMOOTH2_KERN_BEGIN_ROW:
    cmp r3, r8
    bge .SMOOTH2_KERN_DONE
    mov r7, #0 // kernel_j
    ldr r4, [sp, #12] // j
    sub r4, r1 // jj = j-central
.FOR_SMOOTH2_KERN_BEGIN_COLUMN:
    cmp r7, r8
    bge .FOR_SMOOTH2_KERN_END_COLUMN

    //val += input[ii][jj] * kernel[kern_i][kern_j];
    //min max
    cmp r4, #0
    bge .J_IS_OK_0
    mov r4, #0
.J_IS_OK_0:
    cmp r5, #0
    bge .I_IS_OK_0
    mov r5, #0
.I_IS_OK_0:
    ldr r0, [sp, #96]
    cmp r4, r0
    blt .J_IS_OK_MAX
    sub r0, #1
    mov r4, r0
.J_IS_OK_MAX:
    ldr r0, [sp, #92]
    cmp r5, r0
    blt .I_IS_OK_MAX
    sub r0, #1
    mov r5, r0
.I_IS_OK_MAX:
    debug_print(r4)
    debug_print(r5)
    ldr r6, [sp, #76] // kernel
    ldr r6, [r6, r3, asl #2]
    ldrb r6, [r6, r7, asl #2]
    ldr r2, [sp, #100] // input (raw_image)
    ldr r2, [r2, r5, asl #2]
    ldrb r2, [r2, r4, asl #2]
    mul r0, r2, r6
    add r9, r0 // val+=r0

    add r7, #1
    add r4, #1
    b .FOR_SMOOTH2_KERN_BEGIN_COLUMN
.FOR_SMOOTH2_KERN_END_COLUMN:
    add r3, #1
    add r5, #1
    b .FOR_SMOOTH2_KERN_BEGIN_ROW
.SMOOTH2_KERN_DONE:
    // norm
    ldr r1, [sp, #4]
    mov r0, r9
    bl __divsi3 // val in r0
    ldr r3, [sp, #12] // load j to r3
    ldr r2, [sp, #8] // load i to r2
    ldr r9, [sp, #84] // tmp1 to r9
    ldr r9, [r9, r2, asl #2]
    strb r0, [r9, r3, asl #2]
    add r3, #1
    str r3, [sp, #12] // store j
    ldr r1, [sp, #16] // central
    ldr r4, [sp, #96] // width
    b .FOR_SMOOTH2_BEGIN_COLUMN
.FOR_SMOOTH2_END_COLUMN:
    // Load for line 178.
    ldr r2, [sp, #92] // height
    ldr r8, [sp, #28] // kernel size
    ldr r3, [sp, #8] // load i
    add r3, #1
    str r3, [sp, #8] // sore i
    b .FOR_SMOOTH2_BEGIN_ROW
.SMOOTH2_DONE:

    // Free temporary images
    // TODO: tmp1 tmp2
    // Free gaussian gernel
    // TODO: gaussian
.EXIT:
    epilogue


#ifndef NDEBUG
.DBG_OUT:
    .word .debug_output
    .word .float_debug_output
#endif
.LEND_TEXT_DATA:
    .size   find_lines, .-find_lines
    .ident  "Piotr Dobrowolski"
    .section    .note.GNU-stack,"",%progbits
