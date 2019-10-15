
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
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

grid_file_name:         .asciiz		"1dgrid.txt"
dictionary_file_name:   .asciiz		"dictionary.txt"
newline:                .asciiz		"\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 		33      # Maximun size of 1D grid_file + NULL
.align 4                                	# The next field will be aligned
dictionary:             .space 		11001   # Maximum number of words in dictionary *
                                        	# ( maximum size of each word + \n) + NULL
# You can add your data here!
dictionary_idx:		.word 		0:1000	# [0, 0, ...]
no_match:		.asciiz		"-1\n"

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     	# Declare main label to be globally visible.
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
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            	# grid[idx] = '\0'

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
#	$s1 = dict_num_words	int

# storing the starting index of each word in the dictorionary in dictionary_idx
# $s2 = int	idx
# $t1 = int	c_input
# $t2 = int	start_idx
# $t3 = int	dict_idx
	move	$s1, $0				# dict_num_words = 0;
	move	$s2, $0				# idx = 0;
	move	$t2, $0				# start_idx = 0;
	move	$t3, $0				# dict_idx = 0;
store_idx_loop:					# do {
	lb	$t1, dictionary($s2)		# c_input = dictionary[idx];
	beq	$t1, $0, store_idx_end		# if(c_input == '\0')
	addi	$v0, $0, 10			# $v0 = '\n'
	beq	$t1, $v0, store_idx_LF		# if(c_input == '\n')
store_idx_inc:
	addi	$s2, $s2, 1			# idx += 1;
	j	store_idx_loop			# } while(1)
store_idx_LF:					# char is '\n'
	sw	$t2, dictionary_idx($t3)	# dictionary_idx[dict_idx] = start_idx
	addi	$t3, $t3, 4			# dict_idx++
	addi	$t2, $s2, 1			# start_idx = idx + 1
	j	store_idx_inc
store_idx_end:					# break
	move	$s1, $t3			# dict_num_words = dict_idx;
	jal	strfind				# strfind();
	
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall
        
# FUNCTION: void strfind(void)
# $s2 = int 	idx
# $t4 = int 	grid_idx
# $t5 = char *	word
strfind:
	subiu	$sp, $sp, 8
	sw	$ra, 4($sp)			# store $ra
	sw	$s2, 0($sp)			# store idx
	move	$s2, $0				# idx = 0;
	move	$t4, $0				# grid_idx = 0;
strfind_wl:
	lb	$t1, grid($t4)			# $t1 = grid[grid_idx]
	beq	$t1, $0, strfind_wb		# while($t1 != '\0') {
	move	$s2, $0				# for(idx = 0;
strfind_fl:
	bge	$s2, $s1, strfind_fb		# idx < dict_num_words;
	lw	$t1, dictionary_idx($s2)	# $t1 = dictionary_idx[idx]
	la	$t5, dictionary($t1)		# word = &dictionary[0] + $t1;
	# contain(grid + grid_idx, word);
	la	$a0, grid($t4)			# $a0 = &grid[0] + grid_idx
	move	$a1, $t5			# $a1 = word
	jal	contain
	beqz	$v0, strfind_fc			# !contain(...)
	# print the word that was found
	move	$a0, $t4
	move	$a1, $t5
	jal	print_match			# NB: $sp already stored
	lw	$s2, 0($sp)			# restore idx
	lw	$ra, 4($sp)			# restore $ra
	addiu	$sp, $sp, 8
	jr	$ra
strfind_fc:
	addi	$s2, $s2, 4			# idx++
	j	strfind_fl			# }
strfind_fb:
	addi	$t4, $t4, 1			# grid_idx++;
	j	strfind_wl			# }
strfind_wb:
	li	$v0, 4
	la	$a0, no_match
	syscall					# print_string("-1\n");
	lw	$s2, 0($sp)			# restore idx
	lw	$ra, 4($sp)			# restore $ra
	addiu	$sp, $sp, 8
	jr	$ra				# [implied] return;
	
# FUNCTION: int contain(char *string, char *word)
# parameters
#	$a0 = char *	string
# 	$a1 = char *	word
# returns $v0
#	1 if string contains '\n' terminated word
# 	0 otherwise
# $t0 = *string
# $t1 = *word
contain:
contain_wl:
	lb	$t0, 0($a0)			# $t0 = *string
	lb	$t1, 0($a1)			# $t1 = *word
	bne	$t0, $t1, contain_r		# if(*string != *word)
	addi	$a0, $a0, 1			# add 1 byte (char)
	addi	$a1, $a1, 1			# "
	j	contain_wl			# while(1)
	move	$v0, $0				# }
	jr	$ra				# return 0;
contain_r:					# $t1 is still *word
	addi	$t0, $0, 10			# $t0 = '\n'
	seq	$v0, $t1, $t0			# "return" = *word == '\n'
	jr	$ra				

# FUNCTION: void print_match(int idx, char *word)
# parameters
# 	$a0 = int	idx
#	$a1 = char *	word
print_match:
	li	$v0, 1				# NB: $a0 already holds grid_idx
	syscall					# print_int(grid_idx);
	li	$v0, 11
	li	$a0, 32				# 32 = ' '
	syscall					# print_char(' ');
print_match_l:
	lb	$a0, 0($a1)			# current character
	beq	$a0, 10, print_match_b		# *word == '\n'
	beq	$a0, 0, print_match_b		# *word == '\0'
	li	$v0, 11
	syscall					# print current character
	addi	$a1, $a1, 1			# point to next character
	j	print_match_l
print_match_b:
	li	$v0, 11
	li	$a0, 10				# 10 = '\n'
	syscall					# print_char('\n');
	jr	$ra

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
