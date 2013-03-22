;;
;; Author: Piotr Dobrowolski
;; pd291528@students.mimuw.edu.pl
;;
;;



%ifndef NDEBUG
    section .data
debug_output:
    db `>DBG:%d\n`, 0
%endif


    section .text
    global make_iteration
%ifndef NDEBUG
    extern printf
%endif


;; definitions
%define size_of_cell_t 2
%define ptr_size 8


%ifndef NDEBUG
;; pushallimusing\0 popallimusing\0
;; simmilar to pusha, but with registers which I'm using
%macro pushallimusing 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
%endmacro
%macro popallimusing 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro
;; dbg_print/1
;; very simple debugging procedure, prints argument
;; saving->restoring registers
%macro dbg_print 1
    pushallimusing
    mov rax, %1
    mov rdi, debug_output
    mov rsi, rax
    xor rax, rax
    call printf
    popallimusing
%endmacro
%endif

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
    jmp %%skip
%%kill:
    mov [%2], byte 0
    jmp %%skip

%%dead:
    ;; source[i][j] is dead
    cmp %3, 3
    jne %%skip
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

;; save(restore)_across_functions_reg
;; what registers in gcc need to be saved across functions
;; without rbp and rsp
%macro save_across_functions_reg 0
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro
%macro restore_across_functions_reg 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

%macro prologue 0
    push rbp
    mov rbp, rsp
    sub rsp, 16 ;; RED ZONE
    save_across_functions_reg
%ifndef NDEBUG
    dbg_print rdi
    dbg_print rsi
    dbg_print rdx
    dbg_print rcx
%endif
%endmacro

%macro epilogue 0
    restore_across_functions_reg
    mov rsp, rbp
    pop rbp
    ret
%endmacro

;; main function
;; make_iteration(int width, int height, cell_t** source, cell_t** destination)
;; cell_t is defined in board.h
;; rdi - width
;; rsi - height
;; rdx - source
;; rcx - destination
make_iteration:
    prologue

    ;; First Case - iteration without first and last collumn
    ; r10 row offset
    ; r9  collumn offset

    ;; TODO: calculate width-1 offset, save to rdi
    ;; TODO: calculate height-1 offset, save to rsi
    mov r10, 0
.while_row:
    cmp r10, (width-1 offset)
    jge .while_row_end

    mov r8, 0 ; r8 <- nbrs

    ; begin loop by row
    mov r14, 0 ; r14 <- top
    mov r15, 0 ; r15 <- center
    ; r11 <- bottom
    ;TODO: sub r10, ptr_size ; j-1

    mov r9, 0
.while_column:
    cmp r9, (height-1 offset)
    jge .while_column_end

    ; begin loop by column



    ; end loop by column

    add r9, size_of_cell_t
    jmp .while_column
.while_column_end:

    ; end loop by row

    add r10, ptr_size
    jmp .while_row
.while_row_end:

    ;;First column
    
    ;;Last column

    epilogue
