/*
 * Author: Piotr Dobrowolski
 * pd291528@students.mimuw.edu.pl
 *
 */

    .arch armv5

    .file   "engine.S"
    .global __aeabi_idiv
    .global __divsi3
    .section    .rodata
    .align  2

#ifndef NDEBUG
.debug_output:
    .ascii ">DBG: (line:%4d) val: %-12d : %#x\012\000"
.float_debug_output:
    .ascii ">DBG: (line:%4d) val: %-12f : %#x\012\000"
.debug_phase_1:
    .ascii "Phase 1: smoothing...\012\000"
.debug_phase_2:
    .ascii "Phase 2: edge detection...\012\000"
.debug_phase_3:
    .ascii "Phase 3: thresholding...\012\000"
.debug_phase_4:
    .ascii "Phase 4: find line segments...\012\000"
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
#define debug_print(REGISTER) \
    pushall ;\
    mov r4, REGISTER ;\
    ldr r0, .DBG_OUT ;\
    ldr r1, =__LINE__ ;\
    mov r2, r4 ;\
    mov r3, r4 ;\
    bl printf ;\
    popall
#define fdebug_print(REGISTER) \
    pushall ;\
    mvfd f2, REGISTER @ float ;\
    stfd    f2, [sp, #-8]! ;\
    ldmfd   sp!, {r2, r3} ;\
    ldr r0, .DBG_OUT + 4 ;\
    ldr r1, =__LINE__ ;\
    bl printf ;\
    popall
#define debug_phase_print_1 \
    pushall ;\
    ldr r0, .DBG_OUT + 8 ;\
    bl printf ;\
    popall
#define debug_phase_print_2 \
    pushall ;\
    ldr r0, .DBG_OUT + 12 ;\
    bl printf ;\
    popall
#define debug_phase_print_3 \
    pushall ;\
    ldr r0, .DBG_OUT + 16 ;\
    bl printf ;\
    popall
#define debug_phase_print_4 \
    pushall ;\
    ldr r0, .DBG_OUT + 20 ;\
    bl printf ;\
    popall
#endif

#define FRAME 264

#define WHITE #255
#define BLACK #0

#define SOBEL_SIZE #3
#define SOBEL_CENTER #1


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
    ldr r0, [sp, #96]
    ldr r1, [sp, #92]
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
#ifndef NDEBUG
    debug_phase_print_1;
#endif
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
    str r2, [sp, #20] // distance
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
    ldr r6, [r6, r7, asl #2]
    ldr r2, [sp, #100] // input (raw_image)
    ldr r2, [r2, r5, asl #2]
    ldrb r2, [r2, r4]
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
    ldr r9, [r9, r2, lsl #2]
    strb r0, [r9, r3]
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
    ldr r6, [sp, #76] // kernel
    ldr r6, [r6, r3, asl #2]
    ldr r6, [r6, r7, asl #2]
    ldr r2, [sp, #100] // input (raw_image)
    ldr r2, [r2, r5, asl #2]
    ldrb r2, [r2, r4]
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
    strb r0, [r9, r3]
    add r3, #1
    str r3, [sp, #12] // store j
    ldr r1, [sp, #16] // central
    ldr r4, [sp, #96] // width
    b .FOR_SMOOTH2_BEGIN_COLUMN
.FOR_SMOOTH2_END_COLUMN:
    ldr r2, [sp, #92] // height
    ldr r8, [sp, #28] // kernel size
    ldr r3, [sp, #8] // load i
    add r3, #1
    str r3, [sp, #8] // sore i
    b .FOR_SMOOTH2_BEGIN_ROW
.SMOOTH2_DONE:

    /**
     * Phase 1 finished
     */


    /**
     * Phase 2: Add sobel masks.
     */
.ADD_SOBEL:
#ifndef NDEBUG
    debug_phase_print_2;
#endif
    mov r0, SOBEL_SIZE
    mov r1, SOBEL_SIZE
    mov r2, #-1
    mov r3, #-2
    mov r4, #-1
    str r4, [sp]
    mov r4, #0
    str r4, [sp, #4]
    str r4, [sp, #8]
    str r4, [sp, #12]
    mov r4, #1
    str r4, [sp, #16]
    str r4, [sp, #24]
    mov r4, #2
    str r4, [sp, #20]
    bl new_kernel
    str r0, [sp, #72] // sobel 1
    mov r0, SOBEL_SIZE
    mov r1, SOBEL_SIZE
    mov r2, #1
    mov r3, #0
    mov r4, #-1
    str r4, [sp]
    str r4, [sp, #24]
    mov r4, #2
    str r4, [sp, #4]
    mov r4, #0
    str r4, [sp, #8]
    str r4, [sp, #20]
    mov r4, #-2
    str r4, [sp, #12]
    str r2, [sp, #16]
    bl new_kernel
    str r0, [sp, #68] // sobel 2

    // Ok, have 2 new kernels - sobel1 and sobel2 saved on stack.
    // Now input is tmp1(84), and output is tmp2(80).

    ldr r2, [sp, #92]
    sub r2, SOBEL_CENTER // height - center
    ldr r4, [sp, #96]
    sub r4, SOBEL_CENTER // width - center
    mov r3, SOBEL_CENTER // i = central
    str r3, [sp, #8] // store i
.FOR_SOBEL1_BEGIN_ROW:
    cmp r3, r2
    bge .SOBEL1_DONE
    mov r3, SOBEL_CENTER
    str r3, [sp, #12] // store j
.FOR_SOBEL1_BEGIN_COLUMN:
    cmp r3, r4
    bge .FOR_SOBEL1_END_COLUMN
    mov r3, #0 // kernel_i
    ldr r5, [sp, #8] // i
    sub r5, SOBEL_CENTER // ii = i-center
    mov r9, #0 // val1 = 0
    mov r8, #0 // val2 = 0
.FOR_SOBEL1_KERN_BEGIN_ROW:
    cmp r3, SOBEL_SIZE
    bge .SOBEL1_KERN_DONE
    mov r7, #0 // kernel_j
    ldr r4, [sp, #12] // j
    sub r4, SOBEL_CENTER // jj = j-center
.FOR_SOBEL1_KERN_BEGIN_COLUMN:
    cmp r7, SOBEL_SIZE
    bge .FOR_SOBEL1_KERN_END_COLUMN

    //val1 += input[ii][jj] * sobel1[kern_i][kern_j];
    //val2 += input[ii][jj] * sobel2[kern_i][kern_j];
    ldr r6, [sp, #72] // sobel1
    ldr r6, [r6, r3, lsl #2]
    ldr r6, [r6, r7, lsl #2]
    ldr r2, [sp, #84] // input (tmp1)
    ldr r2, [r2, r5, lsl #2]
    ldrb r2, [r2, r4]
    mul r0, r2, r6
    add r9, r0 // val1+=r0
    ldr r6, [sp, #68] // sobel2
    ldr r6, [r6, r3, asl #2]
    ldr r6, [r6, r7, asl #2]
    mul r0, r2, r6
    add r8, r0 // val2+=r0

    add r7, #1
    add r4, #1
    b .FOR_SOBEL1_KERN_BEGIN_COLUMN
.FOR_SOBEL1_KERN_END_COLUMN:
    add r3, #1
    add r5, #1
    b .FOR_SOBEL1_KERN_BEGIN_ROW
.SOBEL1_KERN_DONE:
    fltd f0, r9
    fltd f1, r8
    fmld f0, f0, f0
    fmld f1, f1, f1
    adfd f0, f0, f1
    stfd f0, [sp, #-8]!
    ldmfd sp!, {r0, r1}
    bl sqrt
    fixz r0, f0
    ldr r3, [sp, #12] // load j to r3
    ldr r2, [sp, #8] // load i to r2
    ldr r9, [sp, #80] // tmp2 to r9
    ldr r9, [r9, r2, asl #2]
    strb r0, [r9, r3]
    ldr r4, [sp, #96]
    sub r4, SOBEL_CENTER // width - center
    add r3, #1
    str r3, [sp, #12] // store j
    b .FOR_SOBEL1_BEGIN_COLUMN
.FOR_SOBEL1_END_COLUMN:
    ldr r4, [sp, #96]
    sub r4, SOBEL_CENTER // width - center
    ldr r2, [sp, #92]
    sub r2, SOBEL_CENTER // height - center
    ldr r3, [sp, #8] // load i
    add r3, #1
    str r3, [sp, #8] // sore i
    b .FOR_SOBEL1_BEGIN_ROW
.SOBEL1_DONE:

//Frame
    str r7, [sp, #4] // store norm
    mov r3, #0 // i = 0
    str r3, [sp, #8] // store i
.FOR_SOBEL2_BEGIN_ROW:
    cmp r3, r2
    bge .SOBEL2_DONE
    //if i == central + 1
    cmp r3, #2
    bne .DO_NOT_ADD_TO_I_SOBEL
    ldr r3, [sp, #92]
    sub r3, #1
    sub r3, SOBEL_CENTER // i = height - 1 - center
    str r3, [sp, #8]
.DO_NOT_ADD_TO_I_SOBEL:
    mov r3, #0
    str r3, [sp, #12] // store j
.FOR_SOBEL2_BEGIN_COLUMN:
    cmp r3, r4
    bge .FOR_SOBEL2_END_COLUMN
    //if j == central + 1
    cmp r3, #2
    bne .DO_NOT_ADD_TO_J_SOBEL
    ldr r3, [sp, #96]
    sub r3, #1
    sub r3, SOBEL_CENTER // h = width - 1 - center
    str r3, [sp, #12]
.DO_NOT_ADD_TO_J_SOBEL:
    mov r3, #0 // kernel_i
    ldr r5, [sp, #8] // i
    sub r5, SOBEL_CENTER // ii = i-center
    mov r9, #0 // val1 = 0
    mov r8, #0 // val2 = 0
.FOR_SOBEL2_KERN_BEGIN_ROW:
    cmp r3, SOBEL_SIZE
    bge .SOBEL2_KERN_DONE
    mov r7, #0 // kernel_j
    ldr r4, [sp, #12] // j
    sub r4, SOBEL_CENTER // jj = j-center
.FOR_SOBEL2_KERN_BEGIN_COLUMN:
    cmp r7, r8
    bge .FOR_SOBEL2_KERN_END_COLUMN
    //min max
    cmp r4, #0
    bge .J_IS_OK_0_SOBEL
    mov r4, #0
.J_IS_OK_0_SOBEL:
    cmp r5, #0
    bge .I_IS_OK_0_SOBEL
    mov r5, #0
.I_IS_OK_0_SOBEL:
    ldr r0, [sp, #96]
    cmp r4, r0
    blt .J_IS_OK_MAX_SOBEL
    sub r0, #1
    mov r4, r0
.J_IS_OK_MAX_SOBEL:
    ldr r0, [sp, #92]
    cmp r5, r0
    blt .I_IS_OK_MAX_SOBEL
    sub r0, #1
    mov r5, r0
.I_IS_OK_MAX_SOBEL:
    //val1 += input[ii][jj] * sobel1[kern_i][kern_j];
    //val2 += input[ii][jj] * sobel2[kern_i][kern_j];
    ldr r6, [sp, #72] // sobel1
    ldr r6, [r6, r3, lsl #2]
    ldr r6, [r6, r7, lsl #2]
    ldr r2, [sp, #84] // input (tmp1)
    ldr r2, [r2, r5, lsl #2]
    ldrb r2, [r2, r4]
    mul r0, r2, r6
    add r9, r0 // val1+=r0
    ldr r6, [sp, #68] // sobel2
    ldr r6, [r6, r3, asl #2]
    ldr r6, [r6, r7, asl #2]
    mul r0, r2, r6
    add r8, r0 // val2+=r0

    add r7, #1
    add r4, #1
    b .FOR_SOBEL2_KERN_BEGIN_COLUMN
.FOR_SOBEL2_KERN_END_COLUMN:
    add r3, #1
    add r5, #1
    b .FOR_SOBEL2_KERN_BEGIN_ROW
.SOBEL2_KERN_DONE:
    fltd f0, r9
    fltd f1, r8
    fmld f0, f0, f0
    fmld f1, f1, f1
    adfd f0, f0, f1
    stfd f0, [sp, #-8]!
    ldmfd sp!, {r0, r1}
    bl sqrt
    fixz r0, f0
    ldr r3, [sp, #12] // load j to r3
    ldr r2, [sp, #8] // load i to r2
    ldr r9, [sp, #80] // tmp2 to r9
    ldr r9, [r9, r2, asl #2]
    strb r0, [r9, r3]
    ldr r4, [sp, #96]
    sub r4, SOBEL_CENTER // width - center
    add r3, #1
    str r3, [sp, #12] // store j
    b .FOR_SOBEL2_BEGIN_COLUMN
.FOR_SOBEL2_END_COLUMN:
    ldr r4, [sp, #96]
    ldr r2, [sp, #92]
    ldr r3, [sp, #8] // load i
    add r3, #1
    str r3, [sp, #8] // sore i
    b .FOR_SOBEL2_BEGIN_ROW
.SOBEL2_DONE:
    /**
     * Phase 2 finished.
     */




    /**
     * Phase 3 thresholding.
     */
.THRESHOLDING:
#ifndef NDEBUG
    debug_phase_print_3;
#endif

    ldr r7, [sp, #80] // tmp2 as input
    ldr r8, [sp, #84] // tmp1 as output
    ldr r6, [sp, #96] // width
    ldr r5, [sp, #92] // height
    ldr r2, [sp, #FRAME + 92]

    mov r3, #0
.THRESHOLDING_ROW:
    mov r4, #0
    ldr r1, [r8, r3, asl #2]
    ldr r9, [r7, r3, asl #2]
.THRESHOLDING_COL:
    ldrb r0, [r9, r4]
    cmp r0, r2
    bge .MAKE_WHITE
    mov r0, BLACK
    b .DONE_THIS_THRESHOLD
.MAKE_WHITE:
    mov r0, WHITE
.DONE_THIS_THRESHOLD:
    strb r0, [r1, r4]
    add r4, #1
    cmp r4, r6
    blt .THRESHOLDING_COL

    add r3, #1
    cmp r3, r5
    blt .THRESHOLDING_ROW
    /**
     * Phase 3 finished.
     */





    /**
     * Phase 4 find lines segments.
     */
.FIND_LINES:
#ifndef NDEBUG
    debug_phase_print_4;
#endif
    ldr r9, [sp, #96] // width
    ldr r2, [sp, #92] // height
    mul r1, r9, r9
    mla r1, r2, r2, r1
    mov sl, r2
    str r1, [sp, #52] // w * w + h * h (for max distance)
    mov r2, #0
    mov r1, #0
    str r1, [sp, #24] // angle
    str r2, [sp, #28] // angle has double type!
    b   .ANGLE_CHECK
.ANGLE_ADD_COMPONENT:
    ldfd    f0, .L_CONSTANTS
    adfd    f4, f2, f0
    stfd    f4, [sp, #24] // angle
.ANGLE_CHECK_FINISH:
    ldfd    f1, [sp, #24] // angle
    ldfd    f0, .L_CONSTANTS+8
    adfd    f1, f1, f0
    stfd    f1, [sp, #24]
    ldfd    f2, [sp, #24]
    ldfd    f1, .L_CONSTANTS+16
    cmfe    f2, f1
    bpl .SEARCH_DONE
.ANGLE_CHECK:
    ldfd    f0, [sp, #24] // angle
    ldfd    f1, .L_CONSTANTS+24
    cmfe    f0, f1
    blt .GET_MAX_DISTANCE
    mvfd    f2, f0
    ldfd    f0, .L_CONSTANTS+32
    cmfe    f2, f0
    bmi .ANGLE_ADD_COMPONENT
.GET_MAX_DISTANCE:
    ldr r1, [sp, #52]
    fltd    f0, r1
    sqtd    f4, f0
    cmf f4, f4
    beq .SQRT_SINGLE_COMP
    stfd    f0, [sp, #-8]!
    ldmfd   sp!, {r0, r1}
    bl  sqrt // get diagonal
    mvfd    f4, f0
.SQRT_SINGLE_COMP:
    ldfd    f0, .L_CONSTANTS // M_PI_2
    ldfd    f1, [sp, #24]   // angle
    cmfe    f1, f0
    bls .COUNT_MAX_DIST_ANGLE_LESS_THAN_PI_2
    ldfd    f2, .L_CONSTANTS+24
    cmfe    f1, f2
    bhi .COUNT_MAX_DIST_ANGLE_LESS_THAN_PI
    sufd    f4, f1, f0
    stfd    f4, [sp, #-8]!
    ldmfd   sp!, {r0, r1}
    bl  cos
    ldfd    f2, [sp, #24]
    ldfd    f1, .L_CONSTANTS+40
    cmfe    f2, f1
    fltd    f2, sl
.COUNT_DISTANCE_FINISH:
    mufd    f2, f2, f0
    stfd    f2, [sp, #40] // max distance
    movhi   r1, #0
    movls   r1, #1
    str r1, [sp, #20]  // add distance
    mvfd    f0, f2
.CHECK_EXTREMA:
    cmfe    f0, #0
    ble .ANGLE_CHECK_FINISH
    add r0, sp, #24
    ldmia   r0, {r0-r1}
    add r2, sp, #124
    add r3, sp, #116
    bl  sincos
    fltd    f1, r9
    ldfd    f5, [sp, #116]
    fltd    f0, sl
    ldfd    f6, [sp, #124]
    mnfd    f1, f1
    mnfd    f3, #0
    stfd    f1, [sp, #64]
    mnfd    f0, f0
    mufd    f1, f5, f3
    mov r1, #0
    mov r2, #0
    dvfd    f1, f1, f6
    mufd    f0, f0, f6
    str r1, [sp, #32]
    str r2, [sp, #36]
    stfd    f1, [sp, #56]
    stfd    f0, [sp, #4]
    ldfd    f0, [sp, #32]
    ldfd    f1, [sp, #56]
    dvfd    f7, f0, f6
    ldfd    f4, [sp, #64]
    adfd    f0, f1, f7
    fixz    r0, f0
    mufd    f2, f4, f5
    dvfd    f2, f2, f6
    cmp r0, #0
    stfd    f2, [sp, #48]
    ble .PREPARE_DIST
.DIST_2:
    cmp sl, r0
    ble .FINISH_DISTANCE_ITERATION
    mnfd    f2, #0
    mufd    f0, f6, f2
    ldfd    f1, [sp, #32]
    ldfd    f2, [sp, #4]
    dvfd    f4, f1, f5
    dvfd    f0, f0, f5
    dvfd    f1, f2, f5
    adfd    f0, f0, f4
    adfd    f1, f1, f4
    fixz    r2, f0
    fixz    r1, f1
    mov r5, #0
.DIST_3:
    ldfd    f1, [sp, #48]
    adfd    f0, f7, f1
    fixz    r3, f0
    cmp r3, #0
    movle   ip, r2
    ble .DIST_3_NO_2
    cmp sl, r3
    movle   ip, r1
    movgt   ip, r9
.DIST_3_NO_2:
    cmp r2, #0
    ble .NOT_NEW
    cmp r9, r0
    ldfled  f2, [sp, #64]
    mufled  f0, f2, f6
    dvfled  f0, f0, f5
    adfled  f0, f4, f0
    fixlez  r4, f0
    movgt   r4, #0
    bicle   r4, r4, r4, asr #31
.NEXT_ITER:
    cmp r1, #0
    movle   r3, r0
    ble .NEXT_ITER_OLD
    cmp r9, r1
    movgt   r3, sl
.NEXT_ITER_OLD:
    ldr r1, [sp, #20] // distance
    cmp r1, #0
    bne .HORIZONTAL_VERTICAL_CHECK
    cmp r3, sl
    movlt   r8, r3
    movge   r8, sl
    cmp r8, r4
    mvnle   r6, #0
    ble .CHECK_ITER_DIST
    ldr r1, [sp, #84]
    mov r3, r4, asl #2
    add r5, r1, r3
    mvn r6, #0
.CHECK_HORIZONTALY:
    fltd    f0, r4
    mnfd    f0, f0
    mufd    f0, f6, f0
    dvfd    f0, f0, f5
    adfd    f0, f4, f0
    fixz    r1, f0
    cmp r9, r1
    movgt   r3, #0
    movle   r3, #1
    orrs    r3, r3, r1, lsr #31
    bne .CHECK_HORIZONTALY_CHECK_ITERATION
    ldr r3, [r5, #0]
    ldrb    r2, [r3, r1]    @ zero_extendqisi2
    cmp r2, WHITE
    beq .CHECK_START_OF_LINE
    cmn r6, #1
    beq .CHECK_HORIZONTALY_CHECK_ITERATION
    ldr r2, [sp, #44]
    rsb r3, r2, r7
    cmp r3, #0
    rsblt   r3, r3, #0
    mul r1, r3, r3
    rsb r2, fp, r6
    cmp r2, #0
    rsblt   r2, r2, #0
    mla r3, r2, r2, r1
    fltd    f1, r3
    sqtd    f0, f1
    cmf f0, f0
    stfned  f1, [sp, #-8]!
    ldmnefd sp!, {r0, r1}
    blne    sqrt // distance
    // Check horizontally
    ldr r3, [sp, #FRAME+88]
    cmp r3, #0
    fltd    f1, r3
    ldfltd  f2, .L_CONSTANTS+48
    adfltd  f1, f1, f2
    cmfe    f1, f0
    bpl .DO_NOT_ADD_LINE
    mov r2, r6
    ldr r0, [sp, #88]
    mov r1, r7
    ldr r3, [sp, #44]
    str fp, [sp, #0]
    bl  add_line
.DO_NOT_ADD_LINE:
    mvn r6, #0
.CHECK_HORIZONTALY_CHECK_ITERATION:
    add r4, r4, #1
    cmp r4, r8
    add r5, r5, #4
    blt .CHECK_HORIZONTALY
    cmn r6, #1
    beq .CHECK_ITER_DIST
.ITERATION_DISTANCE:
    ldr r1, [sp, #44]
    rsb r3, r1, r7
    cmp r3, #0
    rsblt   r3, r3, #0
    mul r1, r3, r3
    rsb r2, fp, r6
    cmp r2, #0
    rsblt   r2, r2, #0
    mla r3, r2, r2, r1
    fltd    f1, r3
    sqtd    f0, f1
    cmf f0, f0
    stfned  f1, [sp, #-8]!
    ldmnefd sp!, {r0, r1}
    blne    sqrt
    ldr r2, [sp, #FRAME+88]
    cmp r2, #0
    fltd    f1, r2
    ldfltd  f2, .L_CONSTANTS+48
    adfltd  f1, f1, f2
    cmfe    f1, f0
    bpl .CHECK_ITER_DIST
    ldr r0, [sp, #88]
    mov r1, r7
    mov r2, r6
    ldr r3, [sp, #44]
    str fp, [sp, #0]
    bl  add_line
.CHECK_ITER_DIST:
    ldfd    f4, [sp, #32]
    ldfd    f0, [sp, #40] // max distance
    adfd    f4, f4, #1
    cmfe    f4, f0
    stfd    f4, [sp, #32]
    bpl .ANGLE_CHECK_FINISH
    ldfd    f0, [sp, #32]
    ldfd    f1, [sp, #56]
    dvfd    f7, f0, f6
    adfd    f0, f1, f7
    fixz    r0, f0
    cmp r0, #0
    bgt .DIST_2
.PREPARE_DIST:
    ldfd    f0, [sp, #32]
    mnfd    f2, #0
    mufd    f1, f6, f2
    dvfd    f4, f0, f5
    dvfd    f1, f1, f5
    adfd    f1, f1, f4
    fixz    r2, f1
    ldfd    f1, [sp, #4]
    dvfd    f0, f1, f5
    adfd    f0, f0, f4
    fixz    r1, f0
    bic r5, r2, r2, asr #31
    b   .DIST_3
// It's here because of length of jumps
.L_CONSTANTS_ALIGNMENT:
    .align  2
.L_CONSTANTS:
    // All of those is double (every two words contains single double value)
    .word   1073291771  // +0   M_PI_2
    .word   1413754136  // +4
    .word   1068504511  // +8   -angle component
    .word   -1843976422 // +12
    .word   1075388923  // +16  M_2_Pi
    .word   1413754136  // +20
    .word   1074340347  // +24  M_PI_4
    .word   1413754136  // +28
    .word   1074977148  // +32  max angle
    .word   2134057426  // +36
    .word   1073928572  // +40  3 / 4
    .word   2134057426  // +44
    .word   1106247680  // +48  float 0
    .word   0           // +52
    .word   1075388923  // +56  7 / 4
    .word   1413754136  // +60
    .word   1075183035  // +64   - M_PI_2
    .word   -373577867  // +68
    .word   1072243195  // +72  angle component
    .word   1413754136  // +76
.CHECK_START_OF_LINE:
    cmn r6, #1
    moveq   r7, r1
    moveq   r6, r4
    streq   r7, [sp, #44]
    moveq   fp, r4
    strne   r1, [sp, #44]
    movne   fp, r4
    b   .CHECK_HORIZONTALY_CHECK_ITERATION
.HORIZONTAL_VERTICAL_CHECK:
    cmp ip, r9
    movlt   r4, ip
    movge   r4, r9
    cmp r4, r5
    mvnle   r7, #0
    ble .CHECK_ITER_DIST
    mvn r7, #0
.CHECK_VERTICALLY:
    fltd    f0, r5
    mnfd    f0, f0
    mufd    f0, f5, f0
    dvfd    f0, f0, f6
    adfd    f0, f7, f0
    fixz    r1, f0
    cmp sl, r1
    movgt   r3, #0
    movle   r3, #1
    orrs    r3, r3, r1, lsr #31
    bne .NEW_ITER_VERT
    ldr r2, [sp, #84]
    ldr r3, [r2, r1, asl #2]
    ldrb    r2, [r3, r5]    @ zero_extendqisi2
    cmp r2, WHITE
    beq .ADD_LINE_BEGIN_VERTICALLY
    cmn r7, #1
    beq .NEW_ITER_VERT
    ldr r1, [sp, #44]
    rsb r3, r1, r7
    cmp r3, #0
    rsblt   r3, r3, #0
    mul r1, r3, r3
    rsb r2, fp, r6
    cmp r2, #0
    rsblt   r2, r2, #0
    mla r3, r2, r2, r1
    fltd    f1, r3
    sqtd    f0, f1
    cmf f0, f0
    stfned  f1, [sp, #-8]!
    ldmnefd sp!, {r0, r1}
    blne    sqrt
    // Add line vertivally
    ldr r2, [sp, #FRAME+88]
    cmp r2, #0
    fltd    f1, r2
    ldfltd  f2, .L_CONSTANTS+48
    adfltd  f1, f1, f2
    cmfe    f1, f0
    bpl .DO_NOT_ADD_LINE_VERTICALLY
    mov r1, r7
    ldr r0, [sp, #88]
    mov r2, r6
    ldr r3, [sp, #44]
    str fp, [sp, #0]
    bl  add_line
.DO_NOT_ADD_LINE_VERTICALLY:
    mvn r7, #0
.NEW_ITER_VERT:
    add r5, r5, #1
    cmp r5, r4
    blt .CHECK_VERTICALLY
    cmn r7, #1
    bne .ITERATION_DISTANCE
    b   .CHECK_ITER_DIST
.ADD_LINE_BEGIN_VERTICALLY:
    cmn r7, #1
    moveq   r6, r1
    moveq   r7, r5
    streq   r5, [sp, #44]
    moveq   fp, r6
    movne   fp, r1
    strne   r5, [sp, #44]
    b   .NEW_ITER_VERT
.NOT_NEW:
    bic r4, r0, r0, asr #31
    b   .NEXT_ITER
.FINISH_DISTANCE_ITERATION:
    ldfd    f0, [sp, #32]
    ldfd    f2, [sp, #4]
    dvfd    f4, f0, f5
    dvfd    f1, f2, f5
    adfd    f1, f1, f4
    fixz    r1, f1
    mnfd    f2, #0
    mufd    f0, f6, f2
    dvfd    f0, f0, f5
    adfd    f0, f0, f4
    fixz    r2, f0
    bic r5, r1, r1, asr #31
    b   .DIST_3
.COUNT_MAX_DIST_ANGLE_LESS_THAN_PI:
    ldfd    f0, .L_CONSTANTS+56
    sufd    f1, f0, f1
    stfd    f1, [sp, #-8]!
    ldmfd   sp!, {r0, r1}
    bl  cos
    ldfd    f2, [sp, #24] // angle
    ldfd    f1, .L_CONSTANTS+64
    cmfe    f2, f1
    fltd    f2, r9
    b   .COUNT_DISTANCE_FINISH
.COUNT_MAX_DIST_ANGLE_LESS_THAN_PI_2:
    fltd    f2, sl
    fltd    f0, r9
    stfd    f2, [sp, #-8]!
    ldmfd   sp!, {r0, r1}
    stfd    f0, [sp, #-8]!
    ldmfd   sp!, {r2, r3}
    bl  atan2
    ldfd    f1, [sp, #24]
    sufd    f1, f1, f0
    stfd    f1, [sp, #-8]!
    ldmfd   sp!, {r0, r1}
    bl  cos
    ldfd    f1, .L_CONSTANTS+72
    ldfd    f2, [sp, #24]  // angle
    cmfe    f2, f1
    mufd    f4, f4, f0
    movlt   r1, #0
    movge   r1, #1
    stfd    f4, [sp, #40]  // max_distance
    str r1, [sp, #20] // distance
    mvfd    f0, f4
    b   .CHECK_EXTREMA
.SEARCH_DONE:
    /**
     * Phase 4 finished.
     */

    // Free temporary images
    ldr r0, [sp, #FRAME + 100]
    mov r0, r0, asl #1 // *2
    add r0, #1 // +1
    mov r1, r0
    ldr r0, [sp, #76]
    bl free_kernel
    // gaussian freed
    ldr r0, [sp, #72]
    mov r1, SOBEL_SIZE
    bl free_kernel
    ldr r0, [sp, #68]
    mov r1, SOBEL_SIZE
    bl free_kernel
    // sobels freed
    ldr r0, [sp, #84]
    ldr r1, [sp, #92]
    bl free_raw
    // tmp freed

.EXIT:
    epilogue

#ifndef NDEBUG
.DBG_OUT:
    .word .debug_output
    .word .float_debug_output
    .word .debug_phase_1
    .word .debug_phase_2
    .word .debug_phase_3
    .word .debug_phase_4
#endif
.LEND_TEXT_DATA:
    .size   find_lines, .-find_lines
    .ident  "Piotr Dobrowolski"
    .section    .note.GNU-stack,"",%progbits
