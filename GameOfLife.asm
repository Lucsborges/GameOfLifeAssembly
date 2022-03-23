.include	"data.s"
.text

MAIN:
	#setando constantes
	la	a2, mat1		# a2 = endereco da mat1
	la 	a4, mat2
	li	s0, 256
	li	s1, 0x00003000		# s1 = endereco da heap
	li	s3, 0xFF00		# s3 = cor verde
	li	s7, 15			#ultima posicao da matriz
	li	s8, 50			#numero de iteracoes 
	li	s9, 1
	li	s10,2
	li	s11,3
	li	t6, 4
	la	s4, mat1		# s4 = endereco da matriz base na .data 
	la	s2, mat2 		# s2 = endereco da matriz alternativa a ser preenchida
	
LOOPPRINCIPAL:
	
	jal	PLOTM

	jal	CALCULA
	
	li	a0, 500
	li	a7, 32
	ecall
	
	addi	s8, s8, -1
	bne	s8, zero, LOOPPRINCIPAL
	
	j	EXIT
	
	jal 	PLOTM
	jal 	READM
	jal 	WRITE

READM:	#read(i, j, mat) = retorna o valor da célula da matriz em a0. 
	slli	a3, a0, 4	#a3 = 16*j
	add	a3, a3, a1	#a0 = 16*j + i (posicao do ponto na matriz) 
	add	a3, a3, a2	# a3 = endereco do bit ja na matriz
	lb 	a0, 0(a3)		#a0 = valor na matriz (0 ou 1)
	ret
	
WRITE:
	slli	a3, a0, 4	#a3 = 16*j
	add	a3, a3, a1	#a0 = 16*j + i (posicao do ponto na matriz) 
	add	a3, a3, a2	# a3 = endereco do bit ja na matriz
	lb 	a0, 0(a3)		#a0 = valor na matriz (0 ou 1)
	xori	a0, a0, 1
	sb	a0, 0(a3)
	ret
	
# plotm(mat) - onde a0 = endereço inicial da matriz: desenha a matriz na tela gráfica 	
PLOTM:
	#Setando registradores
	mv	t0, zero	#t0 = contador
	mv	s6, s1 		#s6 = endereco da heap
LOOPPLOT:	#Pega cada valor da matriz, e joga na heap para que seja printado na tela
	
	
	lb	t2,(s4) 	#t2 =valor do endereco de mat1(0 ou 1)
	mul	t2, t2, s3	# t2 = 0xFF ou 0		
	sw	t2, (s6)
	
	addi 	s6, s6, 4 	#incrementa o ponteiro da heap	
	addi	s4, s4, 1	#incrementa o ponteiro da data (mat1 ou mat2)
	addi 	t0, t0, 1	#incrementa o contador
	
	bne	t0, s0, LOOPPLOT
	
	sub	s4, s4, t0	# volta o ponteiro da matriz ao valor original
	
	ret
#Fim da funcao Plot
# calcula()	calcula a nova matriz a partir da antiga, alternando entre mat1 e mat2
CALCULA:
	
	mv	t0, zero	# t0 = contador do loop

	mv	t3, zero	# t3 = contador de vizinhos para cada celula
	mv	a0, zero	# indice i = 0
	mv 	a1, zero	# indice j = 0
	
	j	LOOPCALCULAI
	
RECONFIG:	

	sub	s4, s4, t0	#volta os ponteiros das matrizes ao valor original
	sub	s2, s2, t0	#
	#swap de a2 e a4, alternando entre as matrizes base e dest
	mv	t5, s4
	mv	s4, s2
	mv	s2, t5
	ret

	
LOOPCALCULAI:
	
	mv	a1, zero	# set j = 0
	j	LOOPCALCULAJ		
	
LOOPCALCULAJ:
		
		
	beq 	a0, zero, LINE0	
	lb	t4, -16(s4)
	add	t3, t3, t4	#cima		
	beq	a0, s7, LINE15
	lb	t4, 16(s4)
	add	t3, t3, t4	#baixo
	
	beq	a1, zero, COLZERO
	lb	t4, -1(s4)
	add	t3, t3, t4	#esq
	lb	t4, -17(s4)
	add	t3, t3, t4	#cimaesq
	lb	t4, 15(s4)
	add	t3, t3, t4	#baixoesq	
	beq	a1, s7, COLQUINZE
	#caso comum: meio da matriz
	lb	t4, 1(s4)
	add	t3, t3, t4	#dir
	lb	t4, 17(s4)
	add	t3, t3, t4 	#baixodir
	lb	t4, -15(s4)
	add	t3, t3, t4	#cimadir
	
	j	JULGAMENTO

LINE0:	#primeira linha
	lb	t4, 16(s4)
	add	t3, t3, t4	#baixo
	beq	a1, zero, TUDOZERO
	beq	a1, s7, ZEROQUINZE
	lb	t4, -1(s4)
	add	t3, t3, t4	#esq
	lb	t4, 1(s4)
	add	t3, t3, t4	#dir
	lb	t4, 15(s4)
	add	t3, t3, t4	#baixoesq
	lb	t4, 17(s4)
	add	t3, t3, t4  	#baixodir
	j	JULGAMENTO
	
TUDOZERO: #primeira linha, primeira coluna
	lb	t4, 17(s4)
	add	t3, t3, t4	#baixodir
	lb	t4, 1(s4)
	add	t3, t3, t4	#dir
	j	JULGAMENTO
ZEROQUINZE: #primeira linha, ultima coluna
	lb	t4, -1(s4)
	add	t3, t3, t4	#esq
	lb	t4, 15(s4)
	add	t3, t3, t4	#baixoesq						
	j 	JULGAMENTO
LINE15: #ultima linha

	beq	a1, zero, QUINTEZERO
	beq	a1, s7, TUDOQUINZE
	lb	t4, -1(s4)
	add	t3, t3, t4	#esq
	lb	t4, 1(s4)
	add	t3, t3, t4	#dir
	lb	t4, -17(s4)
	add	t3, t3, t4	#cimaesq
	lb	t4, -15(s4)
	add	t3, t3, t4	#cimadir
	j	JULGAMENTO
QUINTEZERO: #ultima linha, primeira coluna
	lb	t4, 1(s4)
	add	t3, t3, t4	#direito
	lb	t4, -15(s4)
	add	t3, t3, t4 	#cimadireito
	j	JULGAMENTO
TUDOQUINZE: #ultima linha, ultima coluna
	lb	t4, -1(s4)
	add	t3, t3, t4 	#esq
	lb	t4, -17(s4)
	add	t3, t3, t4	#cimaesq
	j	JULGAMENTO

COLZERO:
	lb	t4, 1(s4)
	add	t3, t3, t4	#dir
	lb	t4, -15(s4)
	add	t3, t3, t4	#cimadir
	lb	t4, 17(s4)
	add	t3, t3, t4	#baixodir
	j	JULGAMENTO
COLQUINZE:
	j	JULGAMENTO

JULGAMENTO:

	blt	t3, s10, MORTE		#menos que 2, morre
	beq	t3, s10, SOBREVIVENCIA	# igual a 2, sobrevive
	beq	t3, s11, NASCIMENTO	#igual a 3, sobrevive ou nasce
	blt 	s11, t3, MORTE		#maior que 3, morre
	j	RECONFIG2

SOBREVIVENCIA:
	lb	a5, 0(s4)
	sb	a5, 0(s2)
	j	RECONFIG2
NASCIMENTO:
	sb	s9, 0(s2)
	j	RECONFIG2
MORTE:
	sb	zero, 0(s2)
	j	RECONFIG2

RECONFIG2:
	addi 	t0, t0, 1	#incrementa o contador
	addi 	s4, s4, 1	#incrementa ponteiro da matriz base
	addi 	s2, s2, 1	#incrementa ponteiro da matriz destino
	addi 	a1, a1, 1	#inc j
	mv	t3, zero	#zera o contador de vizinhos positivos
	bgeu	s7, a1, LOOPCALCULAJ	# j <= 15
	addi	a0, a0, 1	# inc i
	bgeu 	s7, a0, LOOPCALCULAI	# i <= 15
	j	RECONFIG
		

EXIT:
	li	a7, 10
	ecall
