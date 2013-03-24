;;
;; Author: Piotr Dobrowolski
;; pd291528@students.mimuw.edu.pl
;;
;;

%if __BITS__!=64
    %error WORKS ONLY ON x86_64 ARCHITECTURE
%endif


%ifndef NDEBUG
    section .data
debug_output:
    db `>DBG: (line:%-4llu) val: %-12llu : %-12p\n`, 0
%endif


    section .text
    global make_iteration
%ifndef NDEBUG
    extern printf
%endif


;; definitions
%define size_of_cell_t 1
%define ptr_size 8 ; __BITS__ / 8


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
%endmacro
%macro popallimusing 0
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
;; dbg_print/2
;; very simple debugging procedure, prints argument
;; saving->restoring registers
%macro dbg_print 1
    pushallimusing
    mov rbx, %1
    mov rdi, debug_output
    mov rsi, __LINE__
    mov rdx, rbx
    mov rcx, rbx
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

;; get_cell/4
;; save &cells[i][j] to %1
;; agruments:
;;      %1 - row offset
;;      %2 - column offset
;;      %3 - cells
;;      %4 - output
%macro get_cell 4
    mov %4, %3
    add %4, %1
    mov %4, [%4]
    add %4, %2 ; %4 == & cells[i][j]
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
    get_cell %1, %2, rdx, r13 ; r13 == & source[i][j]
    get_cell %1, %2, rcx, r12 ; r12 == & destination[i][j]
    write_cell r13, r12, %3
%endmacro

;; summs_next_three_nbrs/2
;; Look out! This could be kind a tricky, because I'm saving cell as byte
;; when getting [%1] I could have 8 cells returned.
;; (used only 3 in this implementation).
;; I want sum cells[_][j-1] + cells[_][j] + cells[_][j+1]
;; Lets say that cells[_][j-1] is on adress 100 (it equals %1)
;; | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | <- adresses
;; | j-1 |   j | j+1 |  SOMETHING, MAYBE NEXT CELLS, MAYBE TRASH
;; LITTLE ENDIAN assumption!!!
;; after mov rbx, [%1] -> rbx: 0x(TRASH)(j+1)(j)(j-1)
;; arguments:
;;      %1 - address of this part of cells,
;;      %2 - summs to this,
;; used registers: rax, rbx
%macro summs_next_three_nbrs 2
    mov rbx, [%1]
    shl rbx, 40 ; remove trash
    shr rbx, 40
    ;count rbx 1's to rax
    ; could be 3 of them, on
    mov rax, rbx
    shr rax, 16
    add %2, rax
    mov rax, rbx
    and rax, 0x000100;
    shr rax, 8
    add %2, rax
    mov rax, rbx
    and rax, 0x000001;
    shr rax, 40
    add %2, rax
%endmacro

;; eval_max_offset/2
;; evaluate maximum offset (bytes)
;; destination - %1
;; arguments:
;;      %1 - all values
;;      %2 - size of single
;; used registers: rax, rbx
%macro eval_max_offset 2
    mov rbx, rdx
    mov rax, %2
    mul %1
    mov %1, rax
    mov rdx, rbx
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

    eval_max_offset rdi, size_of_cell_t
    eval_max_offset rsi, ptr_size

%ifndef NDEBUG
    dbg_print rdi
    dbg_print rsi
%endif

    sub rdi, size_of_cell_t ; width-1
    sub rsi, ptr_size ; height-1

    mov r10, size_of_cell_t ; because I'm starting from 1 (ommiting frame)
.while_column:
%ifndef NDEBUG
    dbg_print r10
%endif
    cmp r10, rdi
    jge .while_column_end

    mov r8, 0 ; r8 <- nbrs

    ; begin loop by column
    mov r14, 0 ; r14 <- top
    mov r15, 0 ; r15 <- center
    mov r11, 0 ; r11 <- bottom
    ; r11 <- bottom = source[0][j-1] + source[0][j] + source[0][j+1];
    mov rbx, r10
    sub rbx, size_of_cell_t ; j-1
    get_cell 0, rbx, rdx, rax ; rax = &source[0][j-1]
    summs_next_three_nbrs rax, r11
%ifndef NDEBUG
    dbg_print r11
%endif

    mov r9, 0
.while_row:
%ifndef NDEBUG
    dbg_print r9
%endif
    cmp r9, rsi
    jge .while_row_end

    ; begin loop by row

    mov r14, r15
    mov r15, r11
    mov rax, r9
    add rax, ptr_size ; i+1
    mov rbx, r10
    sub rbx, size_of_cell_t ; j-1
    ;next 3 lines simmilar to get_cell
    add rax, rdx
    mov rax, [rax] ;; TODO: sth is wrong here, wrong address
%ifndef NDEBUG
    dbg_print rax
%endif
    add rax, rbx;;
    summs_next_three_nbrs rax, r11
%ifndef NDEBUG
    dbg_print r11
%endif
    mov r8, r14
    add r8, r15
    add r8, r11
    get_cell r9, r10, rdx, r13 ; r13 == & source[i][j]
    sub r8b, byte [r13] ;; TODO: CHECK BITES
%ifndef NDEBUG
    dbg_print r8
%endif
    find_and_write_cell r9, r10, r8

    ; end loop by row

    add r9, ptr_size
    jmp .while_row
.while_row_end:

    mov r8, r15
    add r8, r11
    get_cell r9, r10, rdx, r13 ; r13 == & source[i][j]
    sub r8b, byte [r13]
    find_and_write_cell r9, r10, r8

    ; end loop by column

    add r10, size_of_cell_t
    jmp .while_column
.while_column_end:

    ;;First column
    ;TODO:
    ;;Last column
    ;TODO:

    epilogue
