.data

.text
.globl next_greater

next_greater:
    # a0 = arr
    # a1 = n
    # a2 = result

    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)

    mv s0, a0      # arr
    mv s1, a1      # n
    mv s2, a2      # result

    li t0, 0

# initialize result = -1
init_loop:
    bge t0, s1, init_done
    slli t1, t0, 2
    add t1, s2, t1
    li t2, -1
    sw t2, 0(t1)
    addi t0, t0, 1
    j init_loop

init_done:

    # stack top = -1
    li s3, -1

    addi t0, s1, -1   # i = n-1

main_loop:
    blt t0, zero, done

    # arr[i]
    slli t1, t0, 2
    add t1, s0, t1
    lw t2, 0(t1)

pop_loop:
    blt s3, zero, skip_pop

    slli t3, s3, 2
    add t3, sp, t3
    lw t4, 0(t3)

    slli t5, t4, 2
    add t5, s0, t5
    lw t6, 0(t5)

    ble t6, t2, do_pop
    j skip_pop

do_pop:
    addi s3, s3, -1
    j pop_loop

skip_pop:
    blt s3, zero, skip_store

    slli t3, s3, 2
    add t3, sp, t3
    lw t4, 0(t3)

    slli t5, t0, 2
    add t5, s2, t5
    sw t4, 0(t5)

skip_store:
    addi s3, s3, 1
    slli t3, s3, 2
    add t3, sp, t3
    sw t0, 0(t3)

    addi t0, t0, -1
    j main_loop

done:
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    addi sp, sp, 64

    ret
    