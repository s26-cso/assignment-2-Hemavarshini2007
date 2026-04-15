.data
# we are not using any global variables

.text
.globl make_node
.globl insert
.globl get
.globl getAtMost



make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)       

    # malloc will overwrite a0, so save val first
    mv s0, a0          

    # allocating memory for 1 node ( 3 x 8 )
    li a0, 24          
    call malloc        

    # now a0 has address of new node
    # fill the fields one by one
    sw s0, 0(a0)       # store value
    sd zero, 8(a0)     # left = NULL
    sd zero, 16(a0)    # right = NULL

    # restore saved registers before returning
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret



insert:
    addi sp, sp, -24   
    sd ra, 16(sp)
    sd s0, 8(sp)       
    sd s1, 0(sp)       

    # store inputs coz recursive calls will overwrite a0 a1
    mv s0, a0          # s0 = root
    mv s1, a1          # s1 = val

    # if tree is empty
    beqz s0, insert_new

    # compare curr node value with val
    lw t1, 0(s0)       

    # if val is smaller , go left side
    blt s1, t1, go_left

    # otherwise go right side
    # load right child and recursively insert there
    ld a0, 16(s0)      
    mv a1, s1          
    call insert

    # after recur, update right pointer
    sd a0, 16(s0)      
    j insert_done

go_left:
    ld a0, 8(s0)       
    mv a1, s1          
    call insert

    # update left pointer after recursion
    sd a0, 8(s0)

insert_done:
    # return original root
    mv a0, s0          

    ld s1, 0(sp)
    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret

insert_new:
    # creating new node when we get NULL
    mv a0, s1          
    call make_node

    # new node itself is root of this subtree
    ld s1, 0(sp)
    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret


# searches for a value in BST

get:
    # if we reach NULL , value not found
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

# finds largest value <= val

getAtMost:
    # assuming no valid value found
    li t3, -1          

loop_gam:
    # if tree ends , stop
    beqz a1, done_gam

    lw t0, 0(a1)       

    # if current value is <= val, it can be a candidate
    ble t0, a0, update_ans

    # if current value is big , go left
    ld a1, 8(a1)
    j loop_gam

update_ans:
    # store current as best answer so far
    mv t3, t0          

    # try to find a bigger valid value on right side
    ld a1, 16(a1)
    j loop_gam

done_gam:
    # return final answer
    mv a0, t3
    ret
    