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
;; number of neibours - rbx
;; arguments: %1 - row (i), %2 - collumn (j)
;; used registers: r9, r10, r11, r12, rax
%macro write_cell 2
        ;; source[i][j] = source + i * width * ptr_size + j * size_of_cell_t
        lea r10, [%1 * ptr_size] ; offset
        add r10, [%2 * size_of_cell_t]
        mov r9, rdx ; source
        add r9, r10  ; &source[i][j]
        mov r11, rcx ; destination
        add r11, r10 ; &destination[i][j]
        mov al, [r9] ; source[i][j]
        mov byte [r11], al ; destination[i][j] = source[i][j]

        ;; check if alive
        cmp byte 0, al ; source[i][j] == 0
        je %%dead
        ;; source[i][j] is alive

        cmp 2,
    %%dead:


        jmp %%skip
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


    ;; Epilogue
    pop qword rbp
    ret
