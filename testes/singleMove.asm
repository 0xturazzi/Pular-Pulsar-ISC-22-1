.macro print_player(%reg, %int)
	mv t0, %reg

	
	li t3, %int
	
	add t0, s3, t0
	li t4, 11
	VERT_DRAW:
		sw t3, 0(t0)
		sw t3, 4(t0)
		sw t3, 8(t0)
		
		addi t0, t0,320
		addi t4,t4,-1
		bgez t4, VERT_DRAW

.end_macro

#### RESERVADOS
# s1 posicao X
# s2 posicao Y
# s3 mmio start 

.include "MACROS.s"
.text
MAIN:
	SETUP_REGS()


	li s0,0xFF200604	# Escolhe o Frame 0 ou 1
	li t2,0			# inicio Frame 1
	sw t2,0(s0)		# seleciona a Frame t2
	# Preenche a tela
#	MMIO_NEXT_ADDR(t1,t2)
	li t3,0x82828282	# cor
	LOOP: 	
		beq t1,t2,OUT2		# Se for o �ltimo endere�o ent�o sai do loop
		sw t3,0(t1)		# escreve a word na mem�ria VGA
		addi t1,t1,4		# soma 4 ao endere�o
		j LOOP		# volta a verificar
OUT2:
#	NEXT_FRAME()
	mv t1, s3
	li t2, 0x012C00
	add t2, t1, t2
	LOOP2: 	
		beq t1,t2,OUT		# Se for o �ltimo endere�o ent�o sai do loop
		sw t3,0(t1)		# escreve a word na mem�ria VGA
		addi t1,t1,4		# soma 4 ao endere�o
		j LOOP2		# volta a verificar
OUT:
	#NEXT_FRAME()
	li t1, 0x100000
	add t1,t1, s3
	li t2, 0x012C00
	add t2, t1, t2

	print_player(s1,0x71717171)

POOLING_LOOP:
	#NEXT_FRAME()
	li s0, MMIO_set
	lb t1, 0(s0)
	beqz t1, POOLING_LOOP	# ready bit == 0
	lw a0, MMIO_add		# Dados MMIO
	
	#syscall(11)
	
	li t2, 119
	beq t2, a0, UP
	li t2, 115
	beq t2, a0, DOWN
	li t2, 97
	beq t2, a0, LEFT
	li t2, 100
	beq t2, a0, RIGHT
	j POOLING_LOOP
	exit()
UP:
	li t0, 20
#	ble s1, t0, COLLISION_BORDER
	print_player(s1,0x82828282)
	addi s1,s1,-1280
	print_player(s1,0x71717171)
	j POOLING_LOOP
DOWN:
	li t0, 12800 
#	bge s1, t0, COLLISION_BORDER
	print_player(s1,0x82828282)
	addi s1,s1,1280
	print_player(s1,0x71717171)
	j POOLING_LOOP
LEFT:
	li t0, 1
	print_int(t0) 
	li t0, 300
	andi t1, s1, 0xff
#	bge t1, t0, COLLISION_BORDER
	print_player(s1,0x82828282)
	addi s1,s1,-4
	print_player(s1,0x71717171)
	j POOLING_LOOP
RIGHT:
	li t0, 300
	andi t1, s1, 0xff
#	bge t1, t0, COLLISION_BORDER
	print_player(s1,0x82828282)
	addi s1,s1,4
	print_player(s1,0x71717171)
	j POOLING_LOOP
COLLISION_BORDER:
	li t0, 1
	print_int(t0) 
	j POOLING_LOOP
