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
debug_output_sse:
    db `>DBG: (line:%-4llu) %-16p%-16p\n`, 0
%endif
sse_capability_error_msg:
    db `Can not execute.\nYour processor do not support some of SSE operations.\n`, 0
mask_1:
    dq 0x01010101
mask_2:
    dq 0x02020202
mask_3:
    dq 0x03030303

    section .text
    align 64
    global make_iteration
    extern printf


;; definitions
%define size_of_cell_t 1
;; window is size of concurrent cells in one iteration
%define size_of_window 16 ; 16 = (16) * size_of_cell_t
%define ptr_size 8 ; __BITS__ / 8


%ifndef NDEBUG
;;pushm\1 / popm\1 for xmms
%macro pushm 1
    sub rsp, 16
    movdqu [rsp], %1
%endmacro
%macro popm 1
    movdqu %1, [rsp]
    add rsp, 16
%endmacro
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
    pushm xmm0
    pushm xmm1
    pushm xmm2
    pushm xmm3
    pushm xmm4
    pushm xmm5
    pushm xmm6
    pushm xmm7
%endmacro
%macro popallimusing 0
    popm xmm7
    popm xmm6
    popm xmm5
    popm xmm4
    popm xmm3
    popm xmm2
    popm xmm1
    popm xmm0
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
%macro dbg_xmm 1
    pushallimusing
    movq rbx, %1
    mov rdi, debug_output_sse
    mov rsi, __LINE__
    mov rdx, rbx
    pextrq rbx, %1, 1
    mov rcx, rbx
    xor rax, rax
    call printf
    popallimusing
%endmacro
%endif


;; create_byte_mask/2
;; create mask in xmm register
;; arguments:
;;      %1 - destination (xmm) 16 cells,
;;      %2 - mask (two bytes),
%macro create_byte_mask 2
    mov eax, %2
    movd %1, eax
    shufps %1, %1, 00000000B
%endmacro


;; write_cell/3
;; writes proper destination[i][j] (and next 16 collumns)
;; arguments:
;;      %1 - &destination[i][j],
;;      %2 - source (xmm) 16 cells,
;;      %3 - number of neibours (xmm) 16 proper cells.
;; used registers: xmm6, xmm7
;; using masks in xmm10 (2), xmm11 (3) and xmm12 (1)
%macro write_cells 3
    movdqa xmm6, %3
    pcmpeqb xmm6, xmm10
    pand xmm6, %2
     
    movdqa xmm7, %3
    pcmpeqb xmm7, xmm11
    por xmm6, xmm7
    
    pand xmm6, xmm12
    
    movdqu [%1], xmm6
%endmacro

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
;;      %1 - output
;;      %2 - row offset
;;      %3 - coulumn offset
;;      %4 - cells
%macro get_cell 4
    mov %1, %4
    add %1, %2
    mov %1, [%1]
    add %1, %3 ; %1 == & cells[i][j]
%endmacro

;; find_and_write_cell/3
;; writes proper destination[i][j]
;; source - rdx
;; destination - rcx
;; arguments:
;;      %1 - row offset,
;;      %2 - column offset,
;;      %3 - number of neibours
;; used registers: r13, r12, rax
;; registers after macro:
;;      r13 - &source[i][j],
;;      r12 - &destination[i][j]
;;      al  - source[i][j]
%macro find_and_write_cell 3
    ;; & source[i][j] = *(source + rowoffset) + columnoffset
    get_cell r13, %1, %2, rdx ; r13 == & source[i][j]
    get_cell r12, %1, %2, rcx ; r12 == & destination[i][j]
    write_cell r13, r12, %3
%endmacro

;; summs_alive/4
;; summs 14 cells (current row neighbors)
;; arguments:
;;      %1          - nbrs sum (xmm) - output,
;;      %2          - source cells (xmm),
;;      %3          - source cells + 1 (xmm),
;;      %4          - source cells + 2 (xmm),
;; used registers: xmm6
%macro summs_alive 4
    movdqa %1, %2
    paddb %1, %3
    paddb %1, %4
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
;;      %2 - summs to this, first removes it
;; used registers: rax, rbx
%macro summs_next_three_nbrs 2
    mov %2, 0
    mov rbx, [%1]
    and rbx, 0xffffff
    ;count rbx 1's to rax
    ; could be 3 of them
    mov rax, rbx
    shr rax, 16
    add %2, rax
    mov rax, rbx
    and rax, 0x000100;
    shr rax, 8
    add %2, rax
    mov rax, rbx
    and rax, 0x000001;
    add %2, rax
%endmacro
; summs_next_two_nbrs, almost this same as previous
%macro summs_next_two_nbrs 2
    mov %2, 0
    mov rbx, [%1]
    and rbx, 0xffff
    mov rax, rbx
    shr rax, 8
    add %2, rax
    mov rax, rbx
    and rax, 0x1;
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

;; check_capability\0
;; check if user has sse2 (or if debug sse3)
%macro check_capability 0
    push rdi
    push rsi
    push rdx
    push rcx
    
    xor rax, rax
    cpuid
    ;one of this sould guarantee used sse instructions
    test rdx, 1 << 25
    jnz gotsse
    test rdx, 1 << 26
    jnz gotsse
    test rcx, 1
    jnz gotsse
    test rcx, 1 << 9
    jnz gotsse
    test rcx, 1 << 19
    jnz gotsse
    test rcx, 1 << 20 
    jnz gotsse
    test rcx, 1 << 6 
    jnz gotsse
    test rcx, 1 << 7 
    jnz gotsse
    mov rdi, sse_capability_error_msg
    xor rax, rax
    call printf
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    epilogue

gotsse:
    pop rcx
    pop rdx
    pop rsi
    pop rdi
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
    check_capability
    

    ;; create masks
    create_byte_mask xmm12, [mask_1]
    create_byte_mask xmm10, [mask_2]
    create_byte_mask xmm11, [mask_3]
    
%ifndef NDEBUG
    dbg_xmm xmm11
%endif




    ;; First Case - iteration without first and last column




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

    ; begin loop by column

    pxor xmm0, xmm0
    pxor xmm1, xmm1

    ; xmm2 <- bottom = source[0][j-1] + source[0][j] + source[0][j+1]
    ; from j-1 to j-1+16;
    mov rbx, r10
    sub rbx, size_of_cell_t ; j-1
    get_cell rax, 0, rbx, rdx ; rax = &source[0][j-1]
    ;loads cells to xmm
    movdqu xmm5, [rax]
    movdqu xmm6, [rax + size_of_cell_t]
    movdqu xmm7, [rax + 2 * size_of_cell_t]
    summs_alive xmm2, xmm5, xmm6, xmm7

    movdqa xmm5, xmm6

    mov r9, 0
.while_row:
%ifndef NDEBUG
    dbg_print r9
%endif
    cmp r9, rsi
    jge .while_row_end

    ; begin loop by row

    ;; r14 <- &source[i][j]
    get_cell r14, r9, r10, rdx
    ;; r15 <- &destination[i][j]
    get_cell r15, r9, r10, rcx
    
    movdqa xmm3, xmm5 ; source[i][j+0..15]
%ifndef NDEBUG
    dbg_xmm xmm3
%endif

    movdqa xmm0, xmm1 ; top <- center
    movdqa xmm1, xmm2 ; center <- bottom

    mov rax, r9
    add rax, ptr_size ; i+1
    mov rbx, r10
    sub rbx, size_of_cell_t ; j-1
    ;next 3 lines simmilar to get_cell
    add rax, rdx
    mov rax, [rax]
    add rax, rbx
    movdqu xmm5, [rax]
    movdqu xmm6, [rax + size_of_cell_t]
    movdqu xmm7, [rax + 2 * size_of_cell_t]
    summs_alive xmm2, xmm5, xmm6, xmm7 ;; summs bottom
    movdqa xmm5, xmm6


    movdqa xmm4, xmm0 ;; NBRS sum + cell[i][j]
    paddb xmm4, xmm1
    paddb xmm4, xmm2
    psubb xmm4, xmm3 ;; NBRS sum

%ifndef NDEBUG
    dbg_xmm xmm4
%endif

    write_cells r15, xmm3, xmm4

    ; end loop by row

    add r9, ptr_size
    jmp .while_row
.while_row_end:

    get_cell r14, r9, r10, rdx ; r14 == & source[i][j]
    get_cell r15, r9, r10, rcx ; r15 == & source[i][j]

    movdqu xmm3, [r15]
    movdqa xmm4, xmm1
    paddb xmm4, xmm2
    psubb xmm4, xmm3
    write_cells r15, xmm3, xmm4

    ; end loop by column

    add r10, size_of_window
    jmp .while_column
.while_column_end:





    ;; END, main part





    ;;First column




    mov r14, 0 ; r14 <- top
    mov r15, 0 ; r15 <- center
    mov r11, 0 ; r11 <- bottom
    ; r11 <- bottom = source[0][0] + source[0][1]
    mov rax, [rdx] ; rax = &source[0][0]
    summs_next_two_nbrs rax, r11

    mov r9, 0
.while_row_fst_col:
    cmp r9, rsi
    jge .while_row_end_fst_col

    ; begin loop by row

    mov r14, r15
    mov r15, r11
    mov rax, r9
    add rax, ptr_size ; i+1
    add rax, rdx
    mov rax, [rax] ; rax == & source[i+1][0]
    summs_next_two_nbrs rax, r11
    mov r8, r14
    add r8, r15
    add r8, r11
    get_cell r13, r9, 0, rdx ; r13 == & source[i][0]
    mov bl, byte [r13]
    and rbx, 0x1
    sub r8, rbx
    find_and_write_cell r9, 0, r8

    ; end loop by row

    add r9, ptr_size
    jmp .while_row_fst_col
.while_row_end_fst_col:

    mov r8, r15
    add r8, r11
    get_cell r13, r9, 0, rdx ; r13 == & source[i][0]
    mov bl, byte [r13]
    and rbx, 0x1
    sub r8, rbx
    find_and_write_cell r9, 0, r8
    



    
    ;;Last column




    mov r14, 0 ; r14 <- top
    mov r15, 0 ; r15 <- center
    mov r11, 0 ; r11 <- bottom
    ; r11 <- bottom = source[0][width-2] + source[0][width-1]
    mov r10, rdi
    sub r10, size_of_cell_t
    mov rax, [rdx]
    add rax, r10 ; rax = &source[0][width-2]
    summs_next_two_nbrs rax, r11

    mov r9, 0
.while_row_lst_col:
    cmp r9, rsi
    jge .while_row_end_lst_col

    ; begin loop by row

    mov r14, r15
    mov r15, r11
    mov rax, r9
    add rax, ptr_size ; i+1
    add rax, rdx
    mov rax, [rax] ; rax == & source[i+1][0]
    add rax, r10 ; rax == & source[i+1][width-2]
    summs_next_two_nbrs rax, r11
    mov r8, r14
    add r8, r15
    add r8, r11
    get_cell r13, r9, rdi, rdx ; r13 == & source[i][width-1]
    mov bl, byte [r13]
    and rbx, 0x1
    sub r8, rbx
    find_and_write_cell r9, rdi, r8

    ; end loop by row

    add r9, ptr_size
    jmp .while_row_lst_col
.while_row_end_lst_col:

    mov r8, r15
    add r8, r11
    get_cell r13, r9, rdi, rdx ; r13 == & source[height-1][width-1]
    mov bl, byte [r13]
    and rbx, 0x1
    sub r8, rbx
    find_and_write_cell r9, rdi, r8
    



    epilogue
