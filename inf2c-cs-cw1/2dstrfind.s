
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 	1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 	11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
dictionary_idx:		.word	0:1000	# [0, 0, ...]
no_match:		.asciiz	"-1\n"

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!

# GLOBAL VARIABLES
# $s1 = int dict_num_words
# $s6 = int grid_num_rows
# $s7 = int grid_num_cols
 
# $s2 = int	idx
# $t1 = int	c_input
# $t2 = int	start_idx
# $t3 = int	dict_idx
# $t4 = char *	c
# $t5 = char	*c
	move	$s1, $0					# dict_num_words = 0;
	move	$s6, $0					# grid_num_rows = 0;
	move	$s7, $0					# grid_num_cols = 0;
	move	$s2, $0					# idx = 0;
	move	$t2, $0					# start_idx = 0;
	move	$t3, $0					# dict_idx = 0;
# computing the actual dimensions of the grid, post file-reading
	la	$t4, grid				# char *c = grid
comp_dims_wl_EOF:
	lb	$t5, 0($t4)				# $t5 = *c
	beq	$t5, $0, comp_dims_wb_EOF		# while(*c != '\0') {
	move	$s7, $0					# grid_num_cols = 0;
	addi	$s6, $s6, 1				# grid_num_rows++;
comp_dims_wl_LF:
	lb	$t5, 0($t4)				# $t5 = *c
	beq	$t5, 10, comp_dims_wb_LF		# while(*c != '\n') {
	addi	$t4, $t4, 1				# c++; NB: +1, because char *
	addi	$s7, $s7, 1				# grid_num_cols++;
	j	comp_dims_wl_LF				# }
comp_dims_wb_LF:
	addi	$t4, $t4, 1				# c++;
	j	comp_dims_wl_EOF			# }
comp_dims_wb_EOF: # distinct label added for robustness
	# nop
# storing the starting index of each word in the dictorionary in dictionary_idx
store_idx_loop:						# do {
	lb	$t1, dictionary($s2)			# c_input = dictionary[idx];
	beq	$t1, $0, store_idx_end			# if(c_input == '\0')
	addi	$v0, $0, 10				# $v0 = '\n'
	beq	$t1, $v0, store_idx_LF			# if(c_input == '\n')
store_idx_inc:
	addi	$s2, $s2, 1				# idx += 1;
	j	store_idx_loop				# } while(1)
store_idx_LF:						# char is '\n'
	sw	$t2, dictionary_idx($t3)		# dictionary_idx[dict_idx] = start_idx
	addi	$t3, $t3, 4				# dict_idx++
	addi	$t2, $s2, 1				# start_idx = idx + 1
	j	store_idx_inc
store_idx_end:						# break
	move	$s1, $t3				# dict_num_words = dict_idx;
	jal	strfind					# strfind();
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

# FUNCTION: void strfind(void)
# $s3 = int	wordfound
# $s2 = int 	idx
# $t4 = int 	grid_idx
# $s4 = int	xcoord
# $s5 = int	ycoord
# $t5 = char *	word
strfind:
	subiu	$sp, $sp, 20
	sw	$ra, 16($sp)			# store $ra
	sw	$s2, 12($sp)			# store caller's $s2
	sw	$s3, 8($sp)			# store caller's $s3
	sw	$s4, 4($sp)			# store caller's $s4
	sw	$s5, 0($sp)			# store caller's $s5
	move	$s3, $0				# wordfound = 0;
	move	$s2, $0				# idx = 0;
	move	$t4, $0				# grid_idx = 0;
	move	$s4, $0				# xcoord = 0;
	move	$s5, $0				# ycoord = 0;
strfind_wl_EOF:
	lb	$t1, grid($t4)			# $t1 = grid[grid_idx]
	beq	$t1, $0, strfind_wb_EOF		# while($t1 != '\0') {
	# this is where we add the nested while loop
strfind_wl_LF:
	lb	$t1, grid($t4)			# $t1 = grid[grid_idx];
	beq	$t1, 10, strfind_wb_LF		# while($t1 != '\n')
	move	$s2, $0				# for(idx = 0;
	# this is where we add the nested for loop
strfind_fl:
	bge	$s2, $s1, strfind_fb		# idx < dict_num_words;
	lw	$t1, dictionary_idx($s2)	# $t1 = dictionary_idx[idx]
	la	$t5, dictionary($t1)		# word = &dictionary[0] + $t1;
strfind_hor_check:
	la	$a0, grid($t4)			# $a0 = &grid[0] + grid_idx
	move	$a1, $t5			# $a1 = word
	jal	contain_hor
	beq	$v0, $0, strfind_ver_check	# !contain_hor(...)
	# print the word that was found
	move	$a0, $s5			# ycoord
	move	$a1, $s4			# xcoord
	move	$a2, $t5			# word
	li	$a3, 0x48			# 'H'
	jal	print_match			# print_match(ycoord, xcoord, word, 'H');
	addi	$s3, $0, 1			# wordfound = 1;
strfind_ver_check:
	la	$a0, grid($t4)			# $a0 = &grid[0] + grid_idx
	move	$a1, $t5			# $a1 = word
	jal	contain_ver
	beq	$v0, $0, strfind_fc		# !contain_ver(...)
	# print the word that was found
	move	$a0, $s5			# ycoord
	move	$a1, $s4			# xcoord
	move	$a2, $t5			# word
	li	$a3, 0x56			# 'H'
	jal	print_match			# print_match(ycoord, xcoord, word, 'V');
	addi	$s3, $0, 1			# wordfound = 1;
strfind_fc:
	addi	$s2, $s2, 4			# idx++
	j	strfind_fl			# }
strfind_fb:
	addi	$t4, $t4, 1			# grid_idx++;
	addi	$s4, $s4, 1			# xcoord++;
	j	strfind_wl_LF			# }
strfind_wb_LF:
	addi	$t4, $t4, 1			# grid_idx++; // skip over '\n'
	move	$s4, $0				# xcoord = 0;
	addi	$s5, $s5, 1			# ycoord++;
	j	strfind_wl_EOF			# }
strfind_wb_EOF:
	bne	$s3, $0, strfind_return		# if(wordfound) return;
	li	$v0, 4
	la	$a0, no_match
	syscall					# print_string("-1\n");
strfind_return:
	lw	$s5, 0($sp)			# restore caller's registers
	lw	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra
	
# FUNCTION: int contain_hor(char *string, char *word)
# parameters
#	$a0 = char *	string
# 	$a1 = char *	word
# returns $v0
#	1 if string contains '\n' terminated word - horizontally
# 	0 otherwise
# $t0 = *string
# $t1 = *word
contain_hor:
contain_hor_wl:
	lb	$t0, 0($a0)			# $t0 = *string
	lb	$t1, 0($a1)			# $t1 = *word
	bne	$t0, $t1, contain_r		# if(*string != *word)
	addi	$a0, $a0, 1			# string++;
	addi	$a1, $a1, 1			# word++;
	j	contain_hor_wl			# while(1)
contain_r:					# $t1 is still *word
	addi	$t0, $0, 10			# $t0 = '\n'
	seq	$v0, $t1, $t0			# "return" = *word == '\n'
	jr	$ra
	
# FUNCTION: int contain_ver(char *string, char *word)
# parameters
# 	$a0 = char *	string
# 	$a1 = char *	word
# returns $v0
# 	1 if string contains '\n' terminated word - vertically
# 	0 otherwise
# $t0 = *string
# $t1 = *word
contain_ver:
	move	$t2, $0				# int row = 0;
contain_ver_wl:
	lb	$t0, 0($a0)			# $t0 = *string
	lb	$t1, 0($a1)			# $t1 = *word
	# NB: contain_r is "part of" contain_hor, but it contains the same instructions
	bne	$t0, $t1, contain_r		# this is the same for contain_hor
	addi	$a1, $a1, 1			# word++;
	addi	$t3, $s7, 1			# $t3 = grid_num_cols + 1;
	add	$a0, $a0, $t3			# string += grid_num_cols + 1;
	j	contain_ver_wl			# while(1)
	
# FUNCTION: void print_match(int row, int col, char *word, char direction)
# parameters
# 	$a0 = int	row
#	$a1 = int	col
#	$a2 = char *	word
# 	$a3 = char	direction
print_match:
	li	$v0, 1				# PRINT INT
	# move	$a0, $a0			# $a0 already holds row
	syscall					# print_int(row);
	
	li	$v0, 11				# PRINT CHAR
	li	$a0, 0x2c			# 0x2c = ','
	syscall					# print_char(',');
	
	li	$v0, 1				# PRINT INT
	move	$a0, $a1			# $a0 = col
	syscall					# print_int(col);
	
	li	$v0, 11				# PRINT CHAR
	li	$a0, 0x20			# 0x20 = ' '
	syscall					# print_char(' ');
	
	li	$v0, 11				# PRINT CHAR
	move	$a0, $a3			# $a0 = direction
	syscall					# print_char(direction);
	
	li	$v0, 11				# PRINT CHAR
	li	$a0, 0x20			# 0x20 = ' '
	syscall					# print_char(' ');
print_match_l:
	lb	$a0, 0($a2)			# current character
	beq	$a0, 10, print_match_b		# *word == '\n'
	beq	$a0, 0, print_match_b		# *word == '\0'
	
	li	$v0, 11				# PRINT CHAR
	syscall					# print current character
	addi	$a2, $a2, 1			# point to next character
	j	print_match_l
print_match_b:
	li	$v0, 11				# PRINT CHAR
	li	$a0, 10				# 10 = '\n'
	syscall					# print_char('\n');
	jr	$ra

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
