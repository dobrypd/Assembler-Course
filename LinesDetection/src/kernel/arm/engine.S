// XXX: implementation


#warning "EVEN MOCK IS NOT IMPLEMENTED"

    .file   "engine.S"
    .section    .rodata
    .align  2
.LC0:
    .ascii  "Hello world!\012\000"
    .text
    .align  2
    .global main
    .type   main, %function
find_lines:
    mov ip, sp
    stmfd   sp!, {fp, ip, lr, pc}
    sub fp, ip, #4
    ldr r3, .L3
    ldr r3, [r3, #0]
    ldr r0, .L3+4
    mov r1, #1
    mov r2, #13
    bl  fwrite
    mov r3, #0
    mov r0, r3
    ldmfd   sp, {fp, sp, pc}
.L4:
    .align  2
.L3:
    .word   stdout
    .word   .LC0
    .size   main, .-main
    .ident  "GCC: (Debian 4.3.2-1.1) 4.3.2"
    .section    .note.GNU-stack,"",%progbits