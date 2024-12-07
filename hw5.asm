.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
    # Function prologue
    la $t0, board
    lw $t1, board_height    # row
    lw $t2, board_width     # col

    li $t3, 0               # i = 0
    li $t4, 0
    li $t5, 0

    zero_r_loop:
        li $t4, 0           # j = 0

    zero_c_loop:
        mul $t5, $t3, $t2   # i * col
        add $t5, $t5, $t4   # i * col + j
        add $t5, $t5, $t0   # board_address + 1 * (i * col + j)
        li $t6, '\0'
        sb $t6, 0($t5)      # store 0 into the board

        addi $t4, $t4, 1           # j++
        blt  $t4, $t2, zero_c_loop     # j < col?

    zero_c_done:
        addi $t3, $t3, 1    # i++
        blt  $t3, $t1, zero_r_loop     # i < row?

zero_done:
    # Function epilogue
    jr $ra

# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
    # Function prologue
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    lw $s3, 0($a0)      #load type
    lw $s4, 4($a0)      #load orientation
    lw $s5, 8($a0)      #load row_loc
    lw $s6, 12($a0)     #load col_loc
    move $s1, $a1       #copy ship_num to $s1
    li $s2, 0           #set $s2 to 0

    # Load piece fields
    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T
    j piece_done       # Invalid type

piece_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $t1, 1
    li $t2, 2
    li $t3, 3
    beq $s2, $t1, occupied_error_1
    beq $s2, $t2, out_of_board_error_2
    beq $s2, $t3, error_3
    li $v0, 0
    jr $ra

occupied_error_1:
    jal zeroOut
    li $v0, 1
    jr $ra

out_of_board_error_2:
    jal zeroOut
    li $v0, 2
    jr $ra

error_3:
    jal zeroOut
    li $v0, 3
    jr $ra

# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
    # Function prologue
    la $t0, board
    lw $t1, board_height    # row
    lw $t2, board_width     # col

    li $t3, 0               # i = 0
    li $t4, 0
    li $t5, 0
    li $t6, 0

    row_loop:
        li $t4, 0           # j = 0

    col_loop:
        mul $t5, $t3, $t2   # i * col
        add $t5, $t5, $t4   # i * col + j
        add $t5, $t5, $t0   # board_address + 1 * (i * col + j)
        lb $a0, 0($t5)      # print byte
        li $v0, 1
        syscall
        li $a0, ' '
        li $v0, 11
        syscall

        addi $t4, $t4, 1           # j++
        blt  $t4, $t2, col_loop     # j < col?

    col_done:
        addi $t3, $t3, 1    # i++
        li $a0, '\n'
        li $v0, 11
        syscall
        blt  $t3, $t1, row_loop     # i < row?
    
    row_done:
        li $a0, '\n'
        li $v0, 11
        syscall

    # Function epilogue
    
    jr $ra                # Return

# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:
    la $t0, board
    lw $t1, board_height    # row
    lw $t2, board_width     # col

# Check if row or column if out of board
    bge $a0, $t1, tile_error_2	# if row >= board_height
    bge $a1, $t2, tile_error_2	# if col >= board_width
    bltz $a0, tile_error_2		# if row < 0
    bltz $a1, tile_error_2		# if col < 0

# Calculate the address of board[row][col]
    mul $t3, $a0, $t2		# $t3 = row * width
    add $t3, $t3, $a1		# $t3 = row * width + col
    add $t3, $t0, $t3		# $t3 = board_address + row * width + col 

# Check if the cell is occupied
    lb $t4, 0($t3)			# $t4 = board[row][col]
    li $t5, '\0'
    bne $t4, $t5, tile_error_1	# if board[row][col] != 0

# Set value to the cell
    sb $a2, 0($t3)			# board[row][col] == 0 board[ row ] [ col ] = value
    li $v0, 0
    jr $ra

tile_error_1:
	li $v0, 1
	jr $ra


tile_error_2:
	li $v0,2
	jr $ra


# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
    # Function prologue
    jr $ra


T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    j piece_done

.include "skeleton.asm"