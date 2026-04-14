.section .data
    space:      .string " "
    newline:    .byte 10, 0        # ASCII code for \n is 10, 0 is null terminator
    fmt_int:    .string "%d"

.section .text
.globl main

main:
    addi sp, sp, -128
    sd ra, 0(sp)
    sd s0, 8(sp)    # number of args
    sd s1, 16(sp)   # arg
    sd s2, 24(sp)   # result array
    sd s3, 32(sp)   # stack top pointer
    sd s4, 40(sp)   # input arr
    sd s5, 48(sp)   # stack counter
    sd s6, 56(sp)
    
    mv s0, a0 
    mv s1, a1

    addi s0, s0, -1 
    li t0, 0
    ble s0, t0, end

    slli t1, s0, 3
    sub sp, sp, t1
    mv s2, sp       # result
    sub sp, sp, t1
    mv s4, sp       # input
    sub sp, sp, t1
    mv s3, sp       # indices
    li s6, 0        # loop counter

loop:
    beq s6, s0, initial
    slli t0, s6, 3
    addi t0, t0, 8
    add t0, s1, t0
    ld a0, 0(t0)    # string pointer from input
    call atoi       # string to int 
    slli t1, s6, 3
    add t1, s4, t1
    sd a0, 0(t1)
    addi s6, s6, 1
    j loop

initial:
    li s5, 0        # stack counter initial
    addi s6, s0, -1

loop2:
    blt s6, zero, printRes

while_stack:
    ble s5, zero, stack_empty
    addi t0, s5, -1
    slli t0, t0, 3
    add t0, s3, t0  
    ld t1, 0(t0)     # stack top index
    slli t2, t1, 3
    add t2, s4, t2
    ld t2, 0(t2)     # input arr[top index]
    slli t3, s6, 3
    add t3, s4, t3
    ld t3, 0(t3)     # arr[i]
    bgt t2, t3, not_empty   # if curr<top, stop popping
    addi s5, s5, -1     # popping
    j while_stack

stack_empty:
    li t0, -1
    slli t1, s6, 3
    add t1, s2, t1
    sd t0, 0(t1)        # res[i]=-1
    j pushIndex

not_empty:
    addi t0, s5, -1
    slli t0, t0, 3
    add t0, s3, t0
    ld t1, 0(t0)
    slli t2,  s6, 3
    add t2, s2, t2
    sd t1, 0(t2)        # res[i]=top value

pushIndex:
    slli t0, s5, 3

    add t0, s3, t0
    sd s6, 0(t0)
    addi s5, s5, 1
    addi s6, s6, -1
    j loop2

printRes:
    li s6, 0
loopPrint:
    beq s6, s0, end
    slli t0, s6, 3
    add t0, s2, t0
    ld a1, 0(t0)
    la a0, fmt_int
    call printf
    addi t0, s0, -1
    beq s6 , t0, no_space
    la a0, space
    call printf

no_space:
    addi s6, s6, 1
    j loopPrint
end:
    la a0, newline
    call printf
    ld ra, 0(sp)
    li a7, 93    # exit syscall
    li a0, 0
    ecall



