###############################################
#  Programa de exemplo para Syscall MIDI      #
#  ISC Abr 2018				      #
#  Marcus Vinicius Lamar		      #
###############################################

.data
# Numero de Notas a tocar
NUM_CHOPIN: .word 28
NUM_BEETHOVEN: .word 40
# lista de nota,duração,nota,duração,nota,duração,...
BEETHOVEN: 67,148,72,148,74,148,76,445,77,148,74,445,76,148,72,519,74,74,72,148,73,148,72,148,74,74,77,74,76,148,74,148,76,148,77,148,79,296,79,296,79,891,77,148,79,148,81,594,74,297,76,148,77,148,79,594,72,297,72,148,74,148,76,296,76,148,77,148,74,296,74,148,76,148,72,891,77,148,79,148,81,594,74,297,76,148,77,148,79,594,72,297,72,148
CHOPIN: 64,366,69,366,67,732,72,1098,74,366,72,366,73,366,74,1464,74,1098,76,366,74,366,72,366,76,1464,79,1098,81,366,79,366,78,366,74,1098,76,366,77,732,79
.text
.macro music_chopin()
	la s0,NUM_CHOPIN		# define o endereço do número de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,CHOPIN		# define o endereço das notas
	li t0,0			# zera o contador de notas
	li a2,1		# define o instrumento
	li a3,100		# define o volume

LOOP:	beq t0,s1, FIM		# contador chegou no final? então  vá para FIM
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	addi a0,a1, -100		# passa a duração da nota para a pausa ##### Modificado para a nota parar de clipar
	li a7,32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi s0,s0,8		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j LOOP			# volta ao loop
	
FIM:	# removi som estranho
.end_macro

.macro music_beethoven()
	la s0,NUM_CHOPIN		# define o endereço do número de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,CHOPIN		# define o endereço das notas
	li t0,0			# zera o contador de notas
	li a2,1		# define o instrumento
	li a3,100		# define o volume

LOOP:	beq t0,s1, FIM		# contador chegou no final? então  vá para FIM
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	addi a0,a1, -100		# passa a duração da nota para a pausa ##### Modificado para a nota parar de clipar
	li a7,32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi s0,s0,8		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j LOOP			# volta ao loop
	
FIM:	# removi som estranho
.end_macro
.macro sfx_ataque()
	jal ra, sfx_ataque
.end_macro
