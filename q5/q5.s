.section .rodata
# Define constants for file access and console output
file_path: .string "input.txt"
read_mode: .string "r"
msg_is_pal:  .string "Yes\n"
msg_not_pal: .string "No\n"

    .section .text
    .globl main
    .type main, @function
main:
    
    # I am allocating 64 bytes to preserve the Return Address and Saved registers
    # This is necessary because we are calling external C library functions.
    addi    sp, sp, -64
    sd      ra, 56(sp)
    sd      s0, 48(sp)    # Left-side file stream
    sd      s1, 40(sp)    # Right-side file stream
    sd      s2, 32(sp)    # Left offset (0 to N)
    sd      s3, 24(sp)    # Right offset (N to 0)
    sd      s4, 16(sp)    # Temporary storage for left character
    sd      s5, 8(sp)     # Temporary storage for right character

    
    # Opening the file twice to maintain two independent read cursors.
    la      a0, file_path
    la      a1, read_mode
    call    fopen
    mv      s0, a0
    beqz    s0, report_failure 

    la      a0, file_path
    la      a1, read_mode
    call    fopen
    mv      s1, a0
    beqz    s1, report_failure

    # Moving the second pointer to the end of the file to calculate total size.
    mv      a0, s1
    li      a1, 0
    li      a2, 2       # SEEK_END
    call    fseek

    # Determine total byte count via ftell.
    mv      a0, s1
    call    ftell
    mv      t0, a0

    # If the file size is 0 or less, I treat it as a valid palindrome.
    blez    t0, report_success

    # Initialize pointers: s2 starts at index 0, s3 at the final byte index.
    li      s2, 0
    addi    s3, t0, -1



start_comparison:
    # If the cursors meet or cross, all comparisons were successful.
    bgt     s2, s3, report_success

find_valid_left:
    # This loop skips characters that fall outside the 'a'-'z' range.
    bgt     s2, s3, report_success
    mv      a0, s0
    mv      a1, s2
    li      a2, 0       # SEEK_SET
    call    fseek

    mv      a0, s0
    call    fgetc
    mv      s4, a0

    # Filtering logic: check if character is within lowercase ASCII (97-122).
    li      t1, 97
    blt     s4, t1, move_left_cursor
    li      t1, 122
    bgt     s4, t1, move_left_cursor
    j       find_valid_right

move_left_cursor:
    addi    s2, s2, 1
    j       find_valid_left

find_valid_right:
    # Mirror the filtering logic for the right-side pointer.
    bgt     s2, s3, report_success
    mv      a0, s1
    mv      a1, s3
    li      a2, 0       
    call    fseek

    mv      a0, s1
    call    fgetc
    mv      s5, a0

    li      t1, 97
    blt     s5, t1, move_right_cursor
    li      t1, 122
    bgt     s5, t1, move_right_cursor
    j       verify_match

move_right_cursor:
    addi    s3, s3, -1
    j       find_valid_right

verify_match:
    # Final check to ensure pointers haven't crossed during filtering.
    bge     s2, s3, report_success

    # Perform the character comparison.
    bne     s4, s5, report_failure

    # If characters match, increment left and decrement right to continue.
    addi    s2, s2, 1
    addi    s3, s3, -1
    j       start_comparison

report_success:
    la      a0, msg_is_pal
    call    printf
    j       cleanup_and_exit

report_failure:
    la      a0, msg_not_pal
    call    printf
    j       cleanup_and_exit

cleanup_and_exit:
    # Explicitly closing file handles to avoid resource leaks.
    beqz    s0, close_second
    mv      a0, s0
    call    fclose
close_second:
    beqz    s1, finalize
    mv      a0, s1
    call    fclose
finalize:
    # Restore stack and return control to the caller.
    li      a0, 0
    ld      ra, 56(sp)
    ld      s0, 48(sp)
    ld      s1, 40(sp)
    ld      s2, 32(sp)
    ld      s3, 24(sp)
    ld      s4, 16(sp)
    ld      s5, 8(sp)
    addi    sp, sp, 64
    ret