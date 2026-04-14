.globl make_node

make_node:
    addi sp, sp, -16;
    sd ra, 8(sp);
    sd a0, 0(sp);
    li a0, 24;
    call malloc

    ld t0, 0(sp)
    sw t0, 0(a0)
    sd zero, 8(a0)
    sd zero, 16(a0)

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.globl insert

insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd a0, 16(sp)
    sd a1, 8(sp)
    bnez a0, .insert_not_null
    mv a0, a1
    call make_node
    j .insert_done

.insert_not_null:
    lw t0, 0(a0)
    ld a1, 8(sp)
    blt a1, t0, .insert_left
    bgt a1, t0, .insert_right
    ld a0, 16(sp)
    j .insert_done

.insert_left:
    ld a0, 8(a0)    # Load left child
    ld a1, 8(sp)    # Load val
    call insert
    ld t1, 16(sp)   # Get original root pointer
    sd a0, 8(t1)    # Link new/updated left child
    mv a0, t1       # Return the root
    j .insert_done

.insert_right:
    ld a0, 16(a0)   # FIX: Load RIGHT child (16), not left (8)
    ld a1, 8(sp)    # FIX: Load val from 8(sp), not 16(sp)
    call insert
    ld t1, 16(sp)
    sd a0, 16(t1)   # Link new/updated right child
    mv a0, t1
    j .insert_done

.insert_done:
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

.globl get

get:
    beqz a0, .return_get
    lw t0, 0(a0)
    beq a1, t0, .return_get
    blt a1, t0, .get_left
    ld a0, 16(a0)
    j get

.get_left:
    ld a0, 8(a0)
    j get

.return_get:
    ret

.globl getAtMost

getAtMost:
    li t2, -1

.loop:
    beqz a1, .getAtMost_ret
    lw t0, 0(a1)
    beq t0, a0, .getAtMost_exact
    blt t0, a0, .getAtMost_possible
    ld a1, 8(a1)
    j .loop

.getAtMost_possible:
    mv t2, t0
    ld a1, 16(a1)
    j .loop

.getAtMost_exact:
    mv t2, t0

.getAtMost_ret:
    mv a0, t2
    ret