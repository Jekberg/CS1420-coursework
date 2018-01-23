#================================
#CS1420
#Name: John Berg
#Student Number: 159014260
#================================

.data
	#Allocate the array in memory
	arr: .word 12, -1, 8, 0, 6, 85, -74, 23, 99, -30

	.globl main
	main: .text	#main function
		
		li 	$s0, 0 			#i = 0
		li 	$s1, 10 		#size = 10
		li 	$s2, 0 			#sum = 0
		li 	$s3, 0 			#pos = 0
		li 	$s4, 0 			#neg = 0
		la	$s5, arr		#load arr into $s5
		
		for_start:			#Start of the for loop
			
			slt 	$t0, $s0, $s1 			#Result of i < size in $t0
			beq 	$t0, $zero, for_end 	#Exit for loop if $t0 is false
			
			sll 	$t1, $s0, 2 			#Align i with the array
			add 	$t2, $s5, $t1 			#Add i to the arr
			lw 		$t3, 0($t2) 				#Load the element of the array  at index i into $t4
			add 	$s2, $s2, $t3 			#sum += arr[i]
			
			slt 	$t4, $zero, $t3 		#Result of arr[i] > 0 in $t5
			beq 	$t4, $zero, end_if_a	#If $t5 is false go to end_if_a
			add 	$s3, $s3, $t3 			#pos += arr[i]
			end_if_a:						#End if
			
			slt 	$t4, $t3, $zero			#Result of arr[i] < 0 in $t5
			beq 	$t4, $zero, end_if_b	#If $t5 is false go to end_if_b
			add 	$s4, $s4, $t3 			#pos += arr[i]
			end_if_b:						#End if
			
			addi 	$s0, $s0, 1 			#i++
			j 		for_start 				#Go to the start of the loop.
			for_end: 						#End of loop
		
		li 	$v0, 17 	#Exit program
		li 	$a0, 0 		#Exit code
		syscall 		#return 0
