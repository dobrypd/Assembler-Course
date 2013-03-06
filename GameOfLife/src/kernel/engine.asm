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


;; LIVE_OR_DEAD define
;; this macro writes proper destination[i][j]
;; source should be in rdx
;; destination - rcx
;; number of neibours in rbx
;; arguments first - register with row, second - register with collumn
%macro write_cell 2

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



    ;; Epilogue
    pop qword rbp
    ret
