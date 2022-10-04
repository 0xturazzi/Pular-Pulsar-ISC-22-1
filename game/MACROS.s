# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# DATA e COUNTS 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.data
newLine: .string "\n"
slow_count: .byte -1
super_slow_count: .byte -1
gas_count: .word -1
refresh_count: .word -1
current_level: .byte 0

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# CONSTANTES 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.eqv MMIO_add 0xff200004 # Receiver Data Register (ASCII)
.eqv MMIO_set 0xff200000 # Receiver Control Register (Bool) : 1=dados, restaura pra 0 automaticamente quando usa lw MMIO_add

.eqv slow_count_reset 16
.eqv gas_count_reset 250

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS GERAIS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.text
.macro syscall(%op)		# Multipos wrappers de syscall aceitando
	li a7, %op 			# tanto instrucao e registrador ou valor
	ecall
.end_macro

.macro syscall(%op, %val)
	li a7, %op
	li a0, %val
	ecall
.end_macro

.macro syscall(%op, %reg)
	li a7, %op
	mv a0, %reg
	ecall
.end_macro

.macro exit()			# wrapper de exit
	syscall(10)
.end_macro

.macro print_str(%reg) 	# wrappers de print str
	syscall(4, %reg)
.end_macro

.macro print_line() 		# printa o char '\n'
	la t0, newLine
	print_str(t0)
.end_macro

.macro print_int(%int) 	# wrappers de print int
	syscall(1, %int)
.end_macro

.macro print_int(%reg)
	mv a0, %reg
	syscall(1)
.end_macro

.macro print_hex(%reg) 	# wrappers de print int as hex
	syscall(34, %reg)
.end_macro

.macro print_char(%int) 	# wrappers de print char
	syscall(11, %int)
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS TEMPO
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


.macro get_time(%reg) 	# retorna o valor da syscall de tempo
	syscall(30)
	mv %reg, a0
.end_macro

.macro sleep(%reg) 		# dorme por X ms
	mv a0, %reg
	syscall(32)
.end_macro

.macro wait_frame (%reg) 		# Seria usado se precisase limitar
	# reg = old time 				# a execucao da fisica por X fps
	# 1 frame = 33ms 				# garatindo consistencia em varias maquinas
	# return reg = new time
	get_time(t0) 				# porem, ja ta pesado demais ashjdkjsahdk
	sub t0, t0, %reg
	li t1, 33
	
	bge t0, t1, SKIP_WAIT
	sub t1, t1, t0
	wait_time(t1)
	SKIP_WAIT: get_time(%reg)
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS DEBUG
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro print_frame()		# printa o frame atual na tela
	li s0,0xFF200604	
	lw t2,0(s0)	
	print_int(t2)
.end_macro

.macro dump_regs() 		# Dump dos registrados reservados 
	print_frame()
	print_line()
	print_hex(s1)
	print_line()
	print_hex(s2)
	print_line()
	print_hex(s3)
	print_line()
	print_hex(s4)
	print_line()
	print_line()
.end_macro 

			##### OBS NAO DEIXAR AS FUNCOES QUE PREENCHEM A TELA NO CODIGO
			##### DEFINITIVO, VAI QUEBRAR O SISTEMA DE NEXT_FRAME
			##### ELAS ALTERAM FRAMES MANUALMENTE

.macro DEBUG_SCREEN_RED()   		# Preenche FRAME 0 de vermelho
	li s0,0xFF200604				# Escolhe o Frame 
	li t2,0	
	sw t2,0(s0)	
								# Preenche a tela de vermelho
	li t1,0xFF000000				# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00				# endereco final 
	li t3,0x07070707				# cor vermelho|vermelho|vermelhor|vermelho
	LOOP: 	
		beq t1,t2,OUT			# Se for o último endereço então sai do loop
		sw t3,0(t1)				# escreve a word na memória VGA
		addi t1,t1,4				# soma 4 ao endereço
		j LOOP					# volta a verificar
	OUT:
.end_macro

.macro DEBUG_UPPER_LINE() 		# Printa a cor da linha acima do player
	addi t1, s1, -320
	add t1,t1, s3
	lw t1, 0(t1)
	print_hex(t1)
	print_line()
.end_macro

.macro DEBUG_SCREEN_GREEN() 		# Analogamente Preenche FRAME 1 de verde
	li s0,0xFF200604
	li t2,1			
	sw t2,0(s0)		

	li t1,0xFF100000
	li t2,0xFF112C00
	li t3,0x70707070
	LOOP: 	
		beq t1,t2,OUT		
		sw t3,0(t1)		
		addi t1,t1,4		
		j LOOP			
	OUT:
.end_macro

.macro SCREEN_PURPLE_0() # Analogamente Preenche FRAME 0 de roxo
	li s0,0xFF200604	
	li t2,0			
	sw t2,0(s0)		
	
	li t1,0xFF000000
	li t2,0xFF012C00	
	li t3,0x82828282	
	LOOP: 	
		beq t1,t2,OUT		
		sw t3,0(t1)		
		addi t1,t1,4		
		j LOOP		
	OUT:
.end_macro

.macro SCREEN_PURPLE_1() # Analogamente Preenche FRAME 1 de roxo
	li s0,0xFF200604
	li t2,1			
	sw t2,0(s0)		

	li t1,0xFF100000
	li t2,0xFF112C00
	li t3,0x82828282
	LOOP: 	
		beq t1,t2,OUT		
		sw t3,0(t1)		
		addi t1,t1,4		
		j LOOP			
	OUT:
.end_macro

			##### OBS NAO DEIXAR AS FUNCOES QUE PREENCHEM A TELA NO CODIGO
			##### DEFINITIVO, VAI QUEBRAR O SISTEMA DE NEXT_FRAME
			##### ELAS ALTERAM FRAMES MANUALMENTE

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS SETUP
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro NEXT_FRAME() 		# Avancar frame
	mv t1,s4				# troca s3 e s4 ----- BUFFER 0 e 1
	mv s4,s3				# riscv nao tem instrucao pra fazer isso de uma vez :(
	mv s3,t1

#	mv s2,s1 			# DEBUG

	li s0,0xFF200604		# Le o frame atual e inverte
	lw t2,0(s0)
	xori t2,t2, 1
	sw t2,0(s0)		
	
	
			##### SOMENTE ESSA MACRO PODE ALTERAR O FRAME DURANTE O RUNTIME
			##### ASSIM SEMPRE GARANTIMOS QUE NO FRAME 0 ESCREVEMOS NO BUFFER 1
			##### E VICE VERSA... NAO ALTERAR !!!!
.end_macro 

.macro get_frame(%reg) 	# salva o frame atual em um registrador
	li s0,0xFF200604	
	lw %reg,0(s0)	 
.end_macro

.macro SETUP_DATA()
	sb zero, hp, t0
	li t0, 10
	sb t0, gas, t1
.end_macro

.macro SETUP_REGS()
	li s1, 51480 			# 51200 + 300 - 20
	li s2, 51480 			# 51200 + 300 - 20
	li s3, 0xFF000000		# Buffer 0
	li s4, 0xFF100000 		# Buffer
			#### RESERVADOS
			# s1 posicao 
			# s2 posicao passada
			# s3 next write
			# s4 last write
.end_macro
 
.macro get_slow_count(%reg) 	# le a count de desaceleracao
	lb %reg, slow_count
.end_macro

.macro next_slow_count() 	# decresce
	lb t0, slow_count		# entidades desaceleradas so podem mover quando o counter == 0
	
	bltz t0, RESET
	addi t0, t0, -1
	j END
	RESET:
		li t0, slow_count_reset
	END:
		sb t0, slow_count, t1
.end_macro

.macro next_gas_count(%reg) 	# decresce a gasolina/carencia
	lw t0, gas_count	 
	
	bltz t0, RESET
	addi t0, t0, -1
	j END
	RESET:
		li t0, gas_count_reset 
	END:
		mv %reg, t0
		sw t0, gas_count, t1
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS MATEMATICA
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro abs(%reg) 				# absoluto inteiros
	bgez %reg, END 	
	NEG:
		sub %reg, zero, %reg
	END:
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS CHEAT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro cheat()
	li t2, 80 			# P  (shift p) Take dmg (increase hp)
	beq t2, a0, dmg
	li t2, 79 			# O  (shift o) heal dmg (reduce hp)
	beq t2, a0, heal
	li t2, 76
	beq t2, a0, free_flower	# L (shift l) flor
	j end
	
	
	# altera o hp (cor) SEM MATAR O PLAYER
	dmg:
		lb t0, hp
		addi t0, t0, 1
		sb t0, hp, t1
		j end
	heal:
		lb t0, hp
		addi t0, t0, -1
		sb t0, hp, t1
		j end
	free_flower:
		lb t0, flor_win
		addi t0, t0, -1
		sb t0, flor_win, t1
		j end
	end:
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MACROS LEVEL
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.macro level_update_input()
	NEXT_FRAME()					# Prox frame
	#dump_regs() 						# Ignorar: DEBUG
	lw t0, pos_flor
	print_hex(t0)
	print_line()
		
	li t0, MMIO_set 					# Checar se tem input para ler
	lb t1, 0(t0)
	beqz t1, NO_INPUT				# se nao tem input, pula a movimentacao
	lw a0, MMIO_add					# Endereco Dados MMIO
	#syscall(11)						# Ignorar: DEBUG

	cheat() 						# checar input de cheat

	move_player() 					# se nao tem input, pula a movimentacao
	attack_player()					# checar input de ataque
	NO_INPUT:
.end_macro

.macro level_update_player_actions() # acoes do player e counts relacionadas
		next_slow_count()
		player_gas()
		
		move_bullet() 				# ataque do player
		delete_atk()
		print_atk()
	
		print_player(s2, 0x50505050) 	# apaga player antigo
		print_sapo()					# print sprite do player 

.end_macro                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               

.macro update_ui()
	ui_print_gas()
	ui_print_vida()
.end_macro

.macro update_current_level()
	lb t0, current_level
	beqz t0, lv0
	addi t0, t0, -1
	beqz t0, lv1
	j END
	
	lv0: 
		update_level_0()
		j END
	lv1:
		update_level_1()
		j END
	
	END:
.end_macro
.macro setup_current_level()
	lb t0, current_level
	beqz t0, lv0
	addi t0, t0, -1
	beqz t0, lv1
	addi t0, t0, -1
	beqz t0, lv2
	j END
	
	lv0: 
		setup_level_0()
		j END
	lv1:
		setup_level_1()
		j END
	lv2:
		exit()
	END:
.end_macro
