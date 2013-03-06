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


;; get_cell just checks if x and y is in board
;; it's not a function (calling conventions ommited)
;; int get_cell (int x, int y, int width, int height, cell_t** cells)
get_neighbour:
    push rbp



;; get no of neighbors
;; int get_neighbors(int last, int x, int y, int w, int h, cell_t** cells)
get_neighbors:
    mov rdi, debug_output
    call printf
    ret



;; main function
;; make_iteration(int width, int height, cell_t** source, cell_t** destination)
;; cell_t is defined in board.h
make_iteration:
    ;; rdi - width
    ;; rsi - height
    ;; rdx - source
    ;; rcx - destination
    call get_neighbors
    mov rax, [rcx]
    mov word [rax], 0
    ;mov word [rax+1], 0
    ;mov word [rax+2], 0
    ;mov word [rax+3], 0
    ;mov word [rax+4], 1
    ret
