# -------- READ-ONLY DATA SECTION --------
.section .rodata

filename:
    .asciz "input.txt"      # file name (null-terminated string)

msg_yes:
    .asciz "Yes\n"          # output if palindrome

msg_no:
    .asciz "No\n"           # output if not palindrome


# -------- UNINITIALIZED MEMORY --------
.section .bss

.lcomm buf_left, 1          # buffer to store 1 byte from left side
.lcomm buf_right, 1         # buffer to store 1 byte from right side


# -------- CODE SECTION --------
.section .text
.globl _start

_start:

# ===== OPEN FILE (LEFT POINTER) =====

    li a7, 56               # syscall: openat
    li a0, -100             # AT_FDCWD → current directory
    la a1, filename         # pointer to filename
    li a2, 0                # O_RDONLY → read-only
    li a3, 0                # mode (unused for read)
    ecall                   # perform syscall

    bltz a0, exit_error     # if return < 0 → error
    mv s1, a0               # s1 = file descriptor for left pointer


# ===== OPEN FILE AGAIN (RIGHT POINTER) =====

    li a7, 56
    li a0, -100
    la a1, filename
    li a2, 0
    li a3, 0
    ecall

    bltz a0, exit_error
    mv s2, a0               # s2 = file descriptor for right pointer


# ===== FIND FILE SIZE USING LSEEK =====

    li a7, 62               # syscall: lseek
    mv a0, s2               # file descriptor
    li a1, 0                # offset = 0
    li a2, 2                # SEEK_END → move to end of file
    ecall

    bltz a0, exit_error
    mv s3, a0               # s3 = file size (number of bytes)


# ===== EDGE CASE: EMPTY FILE =====

    beqz s3, print_yes      # if size == 0 → palindrome

li a7, 62
mv a0, s1
li a1, 0
li a2, 0     
ecall

# ===== INITIALIZE POINTERS =====

    li s4, 0                # s4 = left index = 0

    addi s3, s3, -1         # s3 = right index = n - 1


# ===== MAIN LOOP =====

compare_loop:

    bge s4, s3, print_yes   # if left >= right → palindrome


# ---- READ LEFT CHARACTER ----

    li a7, 63               # syscall: read
    mv a0, s1               # fd_left
    la a1, buf_left         # buffer to store byte
    li a2, 1                # read 1 byte
    ecall

    li t0, 1
    bne a0, t0, exit_error   # if not exactly 1 byte → treat as done


# ---- MOVE RIGHT POINTER TO CORRECT POSITION ----

    li a7, 62               # syscall: lseek
    mv a0, s2               # fd_right
    mv a1, s3               # offset = right index
    li a2, 0                # SEEK_SET → absolute position
    ecall
    bltz a0, exit_error


# ---- READ RIGHT CHARACTER ----

    li a7, 63               # syscall: read
    mv a0, s2               # fd_right
    la a1, buf_right        # buffer
    li a2, 1                # read 1 byte
    ecall

    li t0, 1
    bne a0, t0, exit_error   # unexpected EOF → assume done


# ---- LOAD BYTES FROM BUFFERS ----

    la t0, buf_left
    lbu t0, 0(t0)            # t0 = left character

    la t1, buf_right
    lbu t1, 0(t1)            # t1 = right character


# ---- COMPARE ----

    bne t0, t1, print_no    # mismatch → not palindrome


# ---- MOVE POINTERS ----

    addi s4, s4, 1          # left++
    addi s3, s3, -1         # right--

    j compare_loop          # repeat


# ===== PRINT YES =====

print_yes:
    li a7, 64               # syscall: write
    li a0, 1                # stdout
    la a1, msg_yes          # "Yes\n"
    li a2, 4                # length = 4 bytes
    ecall

    j do_exit


# ===== PRINT NO =====

print_no:
    li a7, 64
    li a0, 1
    la a1, msg_no           # "No\n"
    li a2, 3
    ecall


# ===== CLOSE FILES AND EXIT =====

do_exit:

    li a7, 57               # syscall: close
    mv a0, s1               # close fd_left
    ecall

    li a7, 57
    mv a0, s2               # close fd_right
    ecall

    li a7, 93               # syscall: exit
    li a0, 0                # exit code 0
    ecall


# ===== ERROR EXIT =====

exit_error:
    li a7, 93               # exit syscall
    li a0, 1                # error code
    ecall