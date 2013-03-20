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

;; write_cell/3
;; writes proper destination[i][j]
;; arguments:
;;      %1 - &source[i][j],
;;      %2 - &destination[i][j],
;;      %3 - number of neibours
;; used registers: rax
;; registers after macro:
;;      al  - source[i][j]
%macro write_cell 3
        mov al, byte [%1] ; al = source[i][j]
        mov byte [%2], al ; destination[i][j] = source[i][j]

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
        mov [%2], byte 0
        jump %%skip

    %%dead:
        ;; source[i][j] is dead
        cmp %3, 3
        je %%skip
        ;; make alive
        mov [%2], byte 1
    %%skip:
%endmacro

;; find_and_write_cell/3
;; writes proper destination[i][j]
;; source - rdx
;; destination - rcx
;; arguments:
;;      %1 - row offset,
;;      %2 - collumn offset,
;;      %3 - number of neibours
;; used registers: r13, r12, rax
;; registers after macro:
;;      r13 - &source[i][j],
;;      r12 - &destination[i][j]
;;      al  - source[i][j]
%macro find_and_write_cell 3
        ;; & source[i][j] = *(source + rowoffset) + collumnoffset
        mov r13, rdx
        add r13, %1
        mov r13, [r13]
        add r13, %2 ; r13 == & source[i][j]
        mov r12, rcx
        add r12, %1
        mov r12, [r12]
        add r12, %2 ; r12 == & destination[i][j]

        write_cell r13, r12, %3
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
