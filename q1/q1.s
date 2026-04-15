.text

.globl make_node
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd a0, 0(sp)          # save val

    # Allocate 24 bytes (4 + padding + 8 + 8)
    li a0, 24
    call malloc
    beqz a0, make_node_fail

    ld t0, 0(sp)
    sw t0, 0(a0)          # val
    sd zero, 8(a0)        # left
    sd zero, 16(a0)       # right

make_node_fail:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# ---------------- insert ----------------
.globl insert
insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    mv s0, a0
    mv s1, a1

    beqz s0, insert_new

    lw t0, 0(s0)
    blt s1, t0, insert_left
    bgt s1, t0, insert_right

    mv a0, s0
    j insert_done

insert_left:
    ld s2, 8(s0)
    mv a0, s2
    mv a1, s1
    call insert
    sd a0, 8(s0)
    mv a0, s0
    j insert_done

insert_right:
    ld s2, 16(s0)
    mv a0, s2
    mv a1, s1
    call insert
    sd a0, 16(s0)
    mv a0, s0

insert_done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret

insert_new:
    mv a0, s1
    call make_node

    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret

# ---------------- get ----------------
.globl get
get:
    beqz a0, get_null

    lw t0, 0(a0)
    beq t0, a1, get_found

    blt a1, t0, get_left

    ld a0, 16(a0)
    j get

get_left:
    ld a0, 8(a0)
    j get

get_found:
    ret

get_null:
    li a0, 0
    ret

# ---------------- getAtMost ----------------
.globl getAtMost
getAtMost:
    li t3, -1

loop_gam:
    beqz a1, done_gam

    lw t0, 0(a1)

    ble t0, a0, update_ans

    ld a1, 8(a1)
    j loop_gam

update_ans:
    mv t3, t0
    ld a1, 16(a1)
    j loop_gam

done_gam:
    mv a0, t3
    ret
    