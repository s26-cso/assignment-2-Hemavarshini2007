.data

.text
.globl next_greater

next_greater:
    # a0 = arr, a1 = n, a2 = result

    # save registers 
    addi sp, sp, -72
    sd ra, 64(sp)
    sd s0, 56(sp)
    sd s1, 48(sp)
    sd s2, 40(sp)
    sd s3, 32(sp)
    sd s4, 24(sp)

    mv s0, a0      # arr base
    mv s1, a1      # n
    mv s2, a2      # result base
    li s4, 0
    #allocate stack for indices 
    # we store indices, so size = n * 4
    slli a0, s1, 2
    sd ra, 16(sp)
    call malloc
    ld ra, 16(sp)
    beqz a0, done   
    mv s4, a0          # stack base

    # initialize to -1 
    li t0, 0
init_loop:
    bge t0, s1, init_done
    slli t1, t0, 2
    add t1, s2, t1
    li t2, -1
    sw t2, 0(t1)
    addi t0, t0, 1
    j init_loop

init_done:

    # stack top = -1 (empty)
    li s3, -1

    # iterate from right → left
    addi t0, s1, -1

main_loop:
    blt t0, zero, done

    # current value arr[i]
    slli t1, t0, 2
    add t1, s0, t1
    lw t2, 0(t1)

# pop if stack elements are <= current
pop_loop:
    blt s3, zero, skip_pop

    slli t3, s3, 2
    add t3, s4, t3
    lw t4, 0(t3)        # index from stack

    slli t5, t4, 2
    add t5, s0, t5
    lw t6, 0(t5)        # arr[i]

    ble t6, t2, do_pop
    j skip_pop

do_pop:
    addi s3, s3, -1
    j pop_loop

# assign result[i] if stack not empty
skip_pop:
    blt s3, zero, skip_store

    slli t3, s3, 2
    add t3, s4, t3
    lw t4, 0(t3)        # next greater idx

    slli t5, t0, 2
    add t5, s2, t5
    sw t4, 0(t5)

# push curr idx
skip_store:
    addi s3, s3, 1
    slli t3, s3, 2
    add t3, s4, t3
    sw t0, 0(t3)

    addi t0, t0, -1
    j main_loop
   
done:
    beqz s4, skip_free   

    sd ra, 16(sp)
    mv a0, s4
    call free
    ld ra, 16(sp)

skip_free:
    ld ra, 64(sp)
    ld s0, 56(sp)
    ld s1, 48(sp)
    ld s2, 40(sp)
    ld s3, 32(sp)
    ld s4, 24(sp)
    addi sp, sp, 72

    ret
    