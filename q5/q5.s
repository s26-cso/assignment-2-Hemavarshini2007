# q5.s - Palindrome checker in RISC-V (RV64) assembly
# Target: Linux RV64
# Strategy: Open file twice. Walk left pointer forward, right pointer backward,
#           comparing one byte at a time. O(n) time, O(1) space.
#
# Linux RV64 syscall ABI:
#   syscall number -> a7
#   args           -> a0, a1, a2, a3, a4, a5
#   return value   -> a0
#
# Syscall numbers (Linux):
#   openat  = 56
#   read    = 63
#   write   = 64
#   lseek   = 62
#   close   = 57
#   exit    = 93
#
# SEEK_SET = 0, SEEK_END = 2
# AT_FDCWD = -100

    .section .rodata
filename:
    .asciz "input.txt"
msg_yes:
    .asciz "Yes\n"
msg_no:
    .asciz "No\n"

    .section .bss
    .lcomm buf_left,  1
    .lcomm buf_right, 1

    .section .text
    .globl _start
_start:
    # ---- open file for left pointer (fd_left -> s1) ----
    li      a7, 56              # sys_openat
    li      a0, -100            # AT_FDCWD
    la      a1, filename
    li      a2, 0               # O_RDONLY
    li      a3, 0
    ecall
    bltz    a0, exit_error
    mv      s1, a0              # s1 = fd_left

    # ---- open file again for right pointer (fd_right -> s2) ----
    li      a7, 56
    li      a0, -100
    la      a1, filename
    li      a2, 0
    li      a3, 0
    ecall
    bltz    a0, exit_error
    mv      s2, a0              # s2 = fd_right

    # ---- seek fd_right to end to get file size ----
    li      a7, 62              # sys_lseek
    mv      a0, s2
    li      a1, 0               # offset = 0
    li      a2, 2               # SEEK_END
    ecall
    bltz    a0, exit_error
    mv      s3, a0              # s3 = file size (n)

    # edge case: empty file -> palindrome
    beqz    s3, print_yes

    # s4 = left index  = 0
    li      s4, 0
    # s3 = right index = n - 1
    addi    s3, s3, -1

compare_loop:
    # if left >= right -> palindrome
    bge     s4, s3, print_yes

    # ---- read 1 byte from fd_left ----
    li      a7, 63              # sys_read
    mv      a0, s1
    la      a1, buf_left
    li      a2, 1
    ecall
    li      t0, 1
    bne     a0, t0, print_yes   # unexpected EOF

    # ---- seek fd_right to right index ----
    li      a7, 62              # sys_lseek
    mv      a0, s2
    mv      a1, s3              # offset = right index
    li      a2, 0               # SEEK_SET
    ecall

    # ---- read 1 byte from fd_right ----
    li      a7, 63
    mv      a0, s2
    la      a1, buf_right
    li      a2, 1
    ecall
    li      t0, 1
    bne     a0, t0, print_yes

    # ---- compare bytes ----
    la      t0, buf_left
    lb      t0, 0(t0)
    la      t1, buf_right
    lb      t1, 0(t1)
    bne     t0, t1, print_no

    # ---- advance pointers ----
    addi    s4, s4, 1           # left++
    addi    s3, s3, -1          # right--
    j       compare_loop

print_yes:
    li      a7, 64              # sys_write
    li      a0, 1               # stdout
    la      a1, msg_yes
    li      a2, 4               # "Yes\n"
    ecall
    j       do_exit

print_no:
    li      a7, 64
    li      a0, 1
    la      a1, msg_no
    li      a2, 3               # "No\n"
    ecall

do_exit:
    li      a7, 57              # sys_close
    mv      a0, s1
    ecall
    li      a7, 57
    mv      a0, s2
    ecall

    li      a7, 93              # sys_exit
    li      a0, 0
    ecall

exit_error:
    li      a7, 93
    li      a0, 1
    ecall
    
