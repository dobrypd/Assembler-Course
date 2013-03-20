;;
;; Author: Piotr Dobrowolski
;; pd291528@students.mimuw.edu.pl
;;
;;

;;    section .data

;;debug_output:
;;    db "DBG: %d"

    section .text
    global make_iteration


;; definitions
%define size_of_cell_t 2
%define ptr_size 8


;; get_cell_ptr
;; writes &cells[i][j] to %1
;; cells - %2
;; i - %3
;; j - %4
;; width - %5
;; using - %6
%macro get_cell_ptr 6
    mov %1, [%2 + %3 * %5 * ptr_size] ; cells[i] in %1
    lea %6, [%4 * size_of_cell_t]
    add %1, %6
%endmacro

;; with default location of variables
%macro get_cell_ptr 1
    get_cell_ptr rax, %1, r8, r9, rdi, r14
%endmacro

;; write_cell
;; writes proper destination[i][j]
;; source - rdx
;; destination - rcx
;; arguments: %1 - rowoffset, %2 - collumn offset, %3 - number of neibours
;; used registers: r13, r12, rax
%macro write_cell 3
        ;; & source[i][j] = *(source + rowoffset) + collumnoffset
        mov r13, rdx
        add r13, %1
        mov r13, [r13]
        add r13, %2 ; r13 == & source[i][j]
        mov r12, rcx
        add r12, %1
        mov r12, [r12]
        add r12, %2 ; r12 == & destination[i][j]

        mov r11, [r13]
        mov al, byte [r13] ; al = source[i][j]
        mov byte [r12], al ; destination[i][j] = source[i][j]

        ;; check if alive
        test al, al ; source[i][j] == 0
        je %%dead

        ;; source[i][j] is alive
        cmp %3, 2
        jl %%kill
        cmp %3, 3
        jg %%kill
        jump %%skip
    %%kill:
        mov [r12], byte 0
        jump %%skip

    %%dead:
        ;; source[i][j] is dead
        cmp %3, 3
        je %%skip
        ;; make alive
        mov [r12], byte 1
    %%skip:
%endmacro

;; main function
;; make_iteration(int width, int height, cell_t** source, cell_t** destination)
;; cell_t is defined in board.h
make_iteration:
    ;; rdi - width
    ;; rsi - height
    ;; rdx - source
    ;; rcx - destination

    ;; Prologue
    push rbp
    mov qword rbp, rsp


    ;; First Case - iteration without first and last collumn
    write_cell r8, r9
    
    
    ;;First column
    
    ;;Last column


    ;; Epilogue
    pop qword rbp
    ret
