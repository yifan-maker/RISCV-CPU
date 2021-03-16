.globl __start
.text
__start:

    addi x2, x0, 5 		# initialize x2=5 		0  20020005
	addi x3, x0, 12 	# initialize x3=12 		4  2003000c
	addi x7, x3,-9 		# initialize x7=3 		8  2067fff7
	or x4, x7, x2 		# x4 <= 3 or 5 = 7 		c  00e22025
	and x5, x3, x4 		# x5 <= 12 and 7 = 4 	10 00642824
	add x5, x5, x4 		# x5 = 4 + 7 = 11 		14 00a42820
	beq x5, x7, end 	# shouldn’t be taken 	18 10a7000c
	addi x4, x0, 0 		# x4 = 12 < 7 = 0 		1c 0064202a
	beq x4, x0, around 	# should be taken 		20 10800002
	#nop					# empty inst			24 00000000
	addi x5, x0, 0 		# shouldn’t happen 		28 20050000
around: 
	addi x4, x0, 1 		# x4 = 3 < 5 = 1 		2c 00e2202a
	add x7, x4, x5 		# x7 = 1 + 11 = 12 		30 00853820
	sub x7, x7, x2 		# x7 = 12 - 5 = 7 		34 00e23822
	sw x7, 1(x0)		# [80] = 7 				38 ac670044
	lw x2, x0, 1 		# x2 = [80] = 7 		3c 8c020050
	#j end 				# should be taken 		40 08000013
	#nop					# empty inst			44 00000000
	addi x2, x0, 1 		# shouldn’t happen 		48 20020001
end: 
	sw x2, 4(x0)		# write adr 84=7 		4c ac020054