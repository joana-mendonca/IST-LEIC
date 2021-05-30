; *********************************************************************************
; *
; * 				Introducao a Arquitetura de Computadores
; *
; *********************************************************************************
; *********************************************************************************
; *
; *						Projecto Treino de Ninjas
; *     
; *								Grupo 03
; *
; *			Projecto realizado por: 
; *			Joana Mendonca 	EQU 83597
; *    		Sara Machado 	EQU 86923
; * 		Pedro Bezerra 	EQU 88214
; *
; *      
; *********************************************************************************

; *********************************************************************************
;		Estado do programa:
;			0 - Inicial. A espera de comecar o jogo
;			1 - Jogo activo
;			2 - Jogo em pausa
;			3 - Jogo finalizado. A espera de reiniciar jogo
; *********************************************************************************


; *********************************************************************************
; constantes
; *********************************************************************************
LIMITE_INFERIOR		EQU		29		; borda inferior da area de jogo
SCREEN	   			EQU		8000H	; endereco do inicio do Pixel Screen 
SCREND 	   			EQU 	807FH	; endereco do fim do Pixel Screen
DISPLAYS   			EQU 	0A000H  ; endereco dos displays de 7 segmentos (periferico POUT-1)
LINHAS	   			EQU 	0C000H  ; endereco das linhas do teclado (periferico POUT-2)
COLUNAS    			EQU 	0E000H  ; endereco das colunas do teclado (periferico PIN)

; *********************************************************************************
; dados
; *********************************************************************************
PLACE 1000H

mask:
	STRING 	80H, 40H, 20H, 10H, 08H, 04H, 02H, 01H

lifeNinja:
	STRING  1, 1, 1, 1	; 0 para ninja morto, 1 para vivo
coordNinja:
	STRING  0, 0		; coordenadas X e Y do ninja 0
	STRING  4, 4		; coordenadas X e Y do ninja 1
	STRING  8, 8		; coordenadas X e Y do ninja 3
	STRING  12, 12		; coordenadas X e Y do ninja 4

tipoItem:
	STRING	0, 0		; 0 para presente, 1 para arma
coordItem:
	STRING  20, 27		; coordenadas X e Y do item 1
	STRING  0, 0		; coordenadas X e Y do item 2

pontuacao:
	STRING 	00H	

; *********************************************************************************	
; 	Objeto ninja
; *********************************************************************************	
tabelaNinja:
	STRING	4, 3
	STRING	0, 1, 0
	STRING	1, 1, 1
	STRING	0, 1, 0
	STRING	1, 0, 1

; *********************************************************************************	
; 	Objeto shuriken
; *********************************************************************************
tabelaArma:
	STRING	3, 3
	STRING	1, 0, 1
	STRING	0, 1, 0
	STRING	1, 0, 1
	
	
; *********************************************************************************	
; 	Objeto presente
; *********************************************************************************
tabelaPresente:
	STRING	3, 3
	STRING	0, 1, 0
	STRING	1, 1, 1
	STRING	0, 1, 0


; *********************************************************************************	
; 	Objetos em branco
; *********************************************************************************
brancoNinja:
	STRING	4, 3
	STRING	0, 0, 0
	STRING	0, 0, 0
	STRING	0, 0, 0
	STRING	0, 0, 0

brancoItem:
	STRING	3, 3
	STRING	0, 0, 0
	STRING	0, 0, 0
	STRING	0, 0, 0	
; *********************************************************************************	

movAuto:
	STRING	0, 0		; Indicam se deve haver movimento vertical e horizontal

maskLowNibble:
	STRING 0FH


	TABLE 200H
pilha:

tabExc:
	WORD	exc0
	WORD	exc1
	
	
PLACE 4000H

;**********************************************************************************
;						Tabelas de Ecra 
; 
; Descricao: 	Desenha o ecra inicial e final(Game Over)
;**********************************************************************************

ecra_inicial: 
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	21H,	0CFH,	0E3H,	84H
			STRING 	33H,	88H,	21H,	0CCH
			STRING 	3FH,	09H,	0A0H,	0FCH
			STRING 	19H,	0AH,	20H,	98H
			STRING 	09H,	8AH,	21H,	90H
			STRING 	0FH,	0C9H,	0A3H,	0F0H
			STRING	1CH,	0C8H,	023H,	38H
			STRING 	38H,	4FH,	0E2H,	1CH
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	7DH,	0F7H,	0D4H,	5EH
			STRING 	11H,	14H,	16H,	52H
			STRING 	11H,	0F7H,	15H,	52H
			STRING	11H,	44H,	14H,	0D2H
			STRING	11H,	27H,	0D4H,	5EH
			STRING	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	45H,	44H,	17H,	0DEH
			STRING 	65H,	64H,	14H,	50H
			STRING 	55H,	55H,	14H,	5EH
			STRING 	4DH,	4DH,	17H,	0C2H
			STRING	45H,	44H,	0E4H,	5EH
			STRING	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H

ecra_GO:
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING 	3DH,	0E8H,	0BCH,	00H
			STRING 	21H,	2DH,	0A0H,	00H
			STRING 	2DH,	0EAH,	0B8H,	00H
			STRING 	25H,	28H,	0A0H,	00H
			STRING 	3DH,	28H,	0BCH,	00H
			STRING 	00H,	00H,	00H,	00H
			STRING	00H,	00H,	00H,	00H
			STRING 	00H,	3DH,	17H,	0BCH
			STRING 	00H,	25H,	14H,	24H
			STRING 	00H,	24H,	0A7H,	3CH
			STRING 	00H,	24H,	0A4H,	28H
			STRING 	00H,	3CH,	47H,	0A4H
			STRING 	00H,	00H,	00H,	00H
			STRING 	00H,	07H,	0C0H,	00H
			STRING	00H,	18H,	30H,	00H
			STRING	00H,	20H,	08H,	40H
			STRING	00H,	40H,	04H,	80H
			STRING 	00H,	7FH,	0FFH,	00H
			STRING 	00H,	0FFH,	0FFH,	00H
			STRING 	00H,	80H,	02H,	80H
			STRING 	00H,	94H,	52H,	40H
			STRING 	00H,	88H,	22H,	00H
			STRING	00H,	94H,	52H,	00H
			STRING	00H,	40H,	04H,	00H
			STRING 	00H,	40H,	04H,	00H
			STRING 	00H,	20H,	08H,	00H
			STRING 	00H,	18H,	30H,	00H
			STRING 	00H,	08H,	20H,	00H
			STRING 	00H,	00FH,	0E0H,	00H
			STRING 	00H,	00H,	00H,	00H

			
			
; *********************************************************************************	
; Main
; *********************************************************************************	
PLACE 0000H

	MOV 	sp, pilha			; Inicializa a pilha
	
	MOV		bte, tabExc			; inicializa tabela de excecoes
	EI0							; Ativa interrupcao 0 
	EI1 						; Ativa interrupcao 1
	EI 							; Ativa interrupcoes
	
init:
	MOV		R10, 0				; Inicializa o R10
	MOV		R9, 0 				; Inicializa o R9
	MOV		R7, 0FFFFH 			; Inicializa o R7	
	MOV		R8, 0FFFFH			; Inicializa o R8
	CALL 	init_var 			; Rotica que inicializa os displays, nijas e outros itens 
	CALL	init_screen			; Rotina que inicializa o pixel screen com o ecra inicial  

running:
	CALL	le_teclado 			; Rotina que trata do teclado 	
	CALL	controleNinjas 		; Rotina que trata dos ninjas 
	CALL	controleItens 		; Rotina que trata das armas e presentes 
	CALL	controleEstado 		; Rotina que trata o estado do jogo ()

	JMP 	running
	
fim:
	JMP 	fim
	
	
; *********************************************************************************
; 						1. Rotinas de Inicializacao
; *********************************************************************************

; *********************************************************************************
; 1.1							Inicializa Variaveis
; ********************************************************************************* 
; Descricao: Atribui valor inicial as variaveis
; input:  nenhum
; output: variaveis relativas ao jogo
; *********************************************************************************

init_var:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH 	R4
	PUSH 	R5
	
	MOV		R5, 0 				 
	MOV		R0, pontuacao 		; Endereco de memoria onde se encontra a pontuacao
	MOVB	[R0], R5 			; Inicializacao da pontuacao com 0
	
	CALL	init_disp 			; Rotina que inicia os displays com 0
	
	MOV		R0, movAuto 		; R0 fica com endereco de memoria onde se encontra variavel que indica se deve haver movimento 
	MOV 	R1, 1 				; O 1 indica que o movimento esta ativo 
	MOVB	[R0], R1 			; Indicacao que deve haver movimento vertical 
	ADD		R0, 1 				; Incrementa-se para ter o endereco da proxima string
	MOVB	[R0], R1 			; Indicacao que deve haver movimento horizontal 
	
	MOV		R8, 0FFH			; Tecla pressionada pelo jogador (FFh nao é uma tecla)

	; ninjas vivos e na posicao inicial:
	MOV		R0, 0 				; R0 vai servir como contador para verificar se já foram posicionados o 4 ninjas
	MOV		R1, coordNinja 		; R1 vai conter o endereco da string que contem a posicao do ninja
	MOV		R2, lifeNinja 		; R2 vai conter o endereco da string com estado do ninja (morto ou vivo)

cicloInitNinja:
	CMP		R0, 4 				; Se os 4 ninjas ja tiverem posicionados, repete-se o processo para as armas ou presentes
	JZ		initItem 			
	MOV		R3, 1 		 		; 
	MOVB	[R2], R3			; Ativa a vida do ninja colocando 1 na string 		
	
	MOV		R3, 13 				;
	MOVB	[R1], R3			; Set da linha inicial do ninja (no meio do ecra)
	
	ADD		R2, 1				; Incrementa-se R2 para iniciar a vida do proximo ninja
	ADD		R1, 2				; Incrementa-se R1 para escrever a coordenada do proximo ninja
	ADD		R0, 1				; Incrementa o contador de ciclo
	JMP		cicloInitNinja		; Repete o processo para os outros ninjas 

initItem:
	MOV		R0, 0 				; R0 vai servir como contador para verificar se já foram posicionados os 2 itens (arma ou presente)
	MOV		R1, coordItem 		; R1 vai conter o endereco da string que contem a posicao do item
	MOV		R4, tipoItem 		; R2 vai conter o endereco da string com o tipo de item , arma ou presente 

cicloInitItem:
	CMP		R0, 2 				; Se os 2 itens ja tiverem posicionados, termina a rotina 
	JZ		fimInitVar          
	
	CALL	novoItem			; Rotina que determina qual o tipo de objecto, se e arma  ou presente, e qual a sua posicao 
	
	ADD		R1, 2				; Incrementa-se R1 para escrever a coordenada do proximo item
	ADD		R4, 1				; Tipo do proximo item
	ADD		R0, 1				; Incrementa o contador de ciclo			
	ADD		R10, R5 			; R10 vai ajudar a determinar a posicao do proximo item 
	JMP		cicloInitItem		; Repete o processo para outro item 
	
	
fimInitVar:
	POP 	R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	
	RET

	


; *********************************************************************************
; 1.2							Inicializa Display
; ********************************************************************************* 
; Descricao: Rotina que inicializa os displays a 00 
; input:  
; output: display  
; *********************************************************************************

init_disp:
	PUSH 	R1
	PUSH	R2
	PUSH	R3
	PUSH 	R4 
	
	
	MOV		R2, DISPLAYS		;Atribuicao do endereco displays a R2
	MOV 	R3, LINHAS			;Atribuicao do endereco do periferico de saida (linhas) a R3
	MOV		R4, COLUNAS 		;Atribuicao do endereco do periferico de entrada (colunas) a R4

	
	MOV 	R1, 0			
	MOVB 	[R2],R1				;Inicializa os displays com o valor 0
	
	
	POP 	R4		
	POP		R3
	POP		R2
	POP 	R1

	RET


	
; *********************************************************************************
; 1.3							Inicializa PixelScreen
; ********************************************************************************* 
; Descricao: Inicializa o pixelScreen com a tela de inicio
; input: 
; output: desenha no pixel screen 
; *********************************************************************************

init_screen:
	PUSH 	R0
	
	CALL	limpa_ecra			; Rotina que limpa o pixel screen			
	
	MOV		R0, ecra_inicial 	; Coloca-se em R0 o primeiro enderecco do ecra a ser desenhado n pixel sreen
	CALL	desenha_ecra 		; Rotina que permite desenhar o ecra prentendido no pixel screen 
	
	POP		R0

	RET	



	
; *********************************************************************************
; 							2. Rotinas de Teclado
; *********************************************************************************
; *********************************************************************************
; 2.1								Le Teclado 
; ********************************************************************************* 
; Descricao: Rotina que passa o valor da tecla lida para o resto do programa 
; input: Valor da tecla anterior (R7)
; output: valor da Tecla pressionada (R8)
; *********************************************************************************

le_teclado:
	PUSH	R0

	MOV		R0, 0FFFFH 			; Valor que indica que o jogador ja deixou de pressionar uma tecla 
	CMP		R7, R0				; Verifica se ha valor anterior, ou seja, se o utilizador ainda continua a tocar na tecla
	JNZ		mantemPress			; Vai para a parte da rotina que verifica se a tecla ja deixou de ser pressionada 
	
	; verifica se uma tecla foi pressionada:
	CALL	varre_teclado		; Rotina que percorre o teclado para vefificar se ha tecla a ser pressionada e tem como output R7
	MOV		R8, R7				; Passa o valor pressionado para o resto do programa
	JMP 	fimLeTeclado		
	
mantemPress:
	MOV		R8, 0FFFFH			; Faz o reset do valor para o resto do programa
	CALL	varre_teclado		; Volta e entrar nesta rotina para verificar se a tecla ja nao esta ser pressionada
	
fimLeTeclado:
	POP		R0

	RET
	

; *********************************************************************************
; 2.1.1								Varre Teclado 
; ********************************************************************************* 
; Descricao: Ve se ha uma tecla sendo pressionada
; input: 
; output: valor da Tecla pressionada (R7)
; *********************************************************************************	

varre_teclado:
	
	PUSH	R1
	PUSH 	R2
	PUSH 	R3 
	PUSH 	R4
	PUSH 	R5
	PUSH 	R6
	PUSH 	R0
	
	MOV 	R3, LINHAS			; Atribuicao do endereco do periferico de saida (linhas) a R3
	MOV		R4, COLUNAS 		; Atribuicao do endereco do periferico de entrada (colunas) a R4
	MOV 	R6,0
	MOV		R5,0
	
Valor_reset:					; Faz reset do ciclo das linhas para ler a coluna da tecla pressionada 
	MOV		R1, 8
Valor:							; Ciclo permite saber a coluna e a linha da tecla 
	MOVB	[R3], R1			; Escreve no periferico de entrada (linhas)
	MOVB	R0, [R4]			; Le o periferico de saida (colunas) 
	MOV 	R2, maskLowNibble 	
	MOVB	R5, [R2] 			; R5 fica com o valor da mascara a ser aplicada  
	AND		R0, R5 				; Aplica uma mascara no R0(coluna da tecla) para que as interrupcoes nao alterem o seu valor
	CMP		R0, 0			
	JNZ		ciclo_l_reset		; Se houver valor da coluna prossege para calcular o valor da tecla
	SHR		R1, 1				; Decrementa um 0 ao R1 para mudar o valor da linha lida
	CMP		R1, 0			
	JNZ 	Valor				; Se ao decrementar, R1 e diferente de zero, volta a fazer a leitura da linha para esse valor

	MOV 	R7, 0				; Se nao houve nenhuma tecla a ser pressionada, coloca-se o valor -1(em hexadecimal) em R7 
	SUB		R7, 1				; como output para dar indicacao a outras rotinas que nao ha tecla a ser pressionada
	JMP 	fimVarreTeclado


ciclo_l_reset: 
	MOV		R5,0				; R5 vai servir como um contador de zeros a direita do 1
ciclo_linha:
	ADD		R5, 1				; Incrementa um valor ao contador sempre que se encontra um zero a direita do 1
	SHR		R1, 1				; 'Retira' 1 zero ao valor da coluna 
	CMP		R1, 0				; Se for o caso activa a flag 'z' (zero)
	JNZ		ciclo_linha			; Enquanto o valor for diferente de zero repete o ciclo
	SUB		R5, 1				; O R5 e inicializado com 1 mesmo que o numero de zeros a direita seja nulo
	
ciclo_c_reset:	
	MOV		R6,0				; R6 vai servir como um contador de zeros a direita do 1
ciclo_coluna:
	ADD 	R6, 1				; Incrementa um valor ao contador sempre que se encontra um zero a direita do 1
	SHR		R0, 1				; 'Retira' 1 zero ao valor da coluna 
	CMP 	R0, 0				; Se for o caso activa a flag 'z' (zero)
	JNZ		ciclo_coluna		; Enquanto o valor for diferente de zero repete o ciclo
	SUB		R6, 1				; O R6 é inicializado com 1 mesmo que o numero de zeros a direita seja nulo
	
Tecla_select:				
	MOV		R7, 0				; Inicializa R7
	MOV		R2, 4
	MUL		R5, R2				; Utilizacao da formula 4*Linha + Coluna
	ADD		R7, R5				; R5 e o valor da coluna 
	ADD 	R7, R6				; Em R7 fica armazenado o valor da tecla pressionada

fimVarreTeclado:
	POP 	R0		
	POP		R6
	POP		R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP		R1
	
	RET	
	
	
; *********************************************************************************
; 						3. Rotinas de Entidades
; *********************************************************************************	

; *********************************************************************************
; 3.1							Ciclo Entidade Ninja
; ********************************************************************************* 
; Descricao: Executa as rotinas de entidade dos 4 ninjas
; input:  
; output: 
; *********************************************************************************

controleNinjas:
	PUSH	R0
	PUSH	R5
	PUSH	R7

	MOV		R7, 0 				; R7 vai servir como contador de ninjas 
cicloControleNinja:
	CMP		R7, 4 				; Se ja foram os 4 ninjas tratados sai do ciclo 
	JZ		fimCicloNinjas 		
	
	CALL	entidadeNinja 		; Rotina que controla as accoes do ninja 

	ADD		R7, 1 				; Incrementa-se um ao contador de ciclo 
	JMP		cicloControleNinja	
fimCicloNinjas:
	MOV		R0, movAuto 		; R0 fica com endereco de memoria onde se encontra variavel que indica se deve haver movimento
	ADD		R0, 1 				; Endereco da string que indica se deve haver movimento vertical
	MOV		R5, 0 				; 
	MOVB	[R0], R5 			; Faz o reset do valor da variavel que indica se houve movimento, esta e 'activada' 
								; pela interrupcao que faz descer o ninja 

	POP		R7
	POP		R5
	POP		R0

	RET

; *********************************************************************************
; 3.1.1							Entidade Ninja
; ********************************************************************************* 
; Descricao: Executa as acoes do ninja, desenha ninja
; input:  posicao e vida do ninja, tabela de desenho do ninja, tecla (R8)
;			numero do ninja (R7)
; output: posicao e vida do ninja
; *********************************************************************************

entidadeNinja:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	
	
	CMP		R9, 1					; Le o estado do programa
	JNZ		fimEntidadeNinja		; Se nao estiver em jogo activo sai da rotina 
	
	; le as variaveis relativas ao ninja:
	MOV		R1, coordNinja			; Coluna (X)
	
	ADD		R1, R7					; R7 varia entre 0 e 3
	ADD		R1, R7					; Soma-se 2 vezes o valor de R7 pois as coordendas dos ninjas tem 2 valores por cada ninja 
	
	MOV		R2, coordNinja			 
	ADD 	R2, 1					; Linha  (Y) , soma-se 1 para aceder ao endereco a seguir, o que tem os valores de Y
	
	ADD		R2, R7 					; R7 varia entre 0 e 3
	ADD		R2, R7 					; Soma-se 2 vezes o valor de R7 pois as coordendas dos ninjas tem 2 valores por cada ninja

	MOV		R3, tabelaNinja			; Tabela de desenho do ninja
	
	MOV		R4, lifeNinja			; R4 fica com o endereco do estado do ninja, vivo ou morto 
	; offset
	ADD		R4, R7					; Soma-se R7 para ler o endereco certo, depende se e o ninja 1,2,3,4
	
	MOVB	R0, [R4]				; Le o valor da vida do ninja 
	CMP		R0, 0					; Se o ninja estiver morto, termina a rotina
	JZ		fimEntidadeNinja
	
movNinja0:
	; movimentos do ninja
	; tecla pra cima
	MOV		R5, 0					
									; Verificar se a tecla pertence a 1 linha do teclado
	ADD		R5, R7 					; R7 varia entre 0 e 3	
	
	CMP		R8, R5					; Verifica se a tecla vale 0-3, para ter a indicacao se é para subir um ninja 
	
	JNZ 	movNinja1 				; Se a tecla de subir nao foi pressionada, vai verficar se a tecla de descer foi 
	CALL	sobeNinja 				; Rotina que permite subir um ninja  
	JMP		desenhaNinja			; Vai desenhar o ninja na nova posicao
	
movNinja1:
	; tecla para baixo
	MOV		R5, 4H 					; Soma-se 4 para verificar se a tecla pertence a 2 linha do teclado  
	; offset
	ADD		R5, R7					; R7 varia entre 0 e 3
	
	CMP		R8, R5					; Verifica se a tecla vale 4-7, para ter a indicacao de qual dos ninjas tem de mover
	JNZ 	movNinja2 				; Se a tecla de descer nao foi pressionada, vai verficar se houve colisao
	CALL	desceNinja 				; Rotina que permite descer o ninja 
	JMP		vfNinjaCaiu				; Vai verificar se o ninja chegou ao fim do ecra/pixel screen
	
movNinja2:
	; gravidade
	MOV		R0, movAuto 			; R0 fica com endereco de memoria onde se encontra variavel que indica se deve haver movimento
	ADD		R0, 1 					; Endereco do movimento vertical 
	MOVB	R5, [R0] 				; Le o valor no endereco de memoria 
	CMP		R5, 1					; Verifica se houve interrupcao, se ouve interrupcao o ninja desce 
	JNZ 	colisaoNinja 			; Se nao houve movimento automatico, vai verficar se houve colisao 
	CALL	desceNinja 				; Se houve, vai descer o ninja 
	JMP 	vfNinjaCaiu				; Vai verificar se o ninja chegou ao fim do ecra/pixel screen
	


vfNinjaCaiu:
	MOVB	R0, [R1]				; Le a coord Y do ninja
	MOV		R5, LIMITE_INFERIOR 	; Coloca em R5 o endereco do fim do pixel screen 
	CMP		R0, R5					; Compara com a borda inferior da pixel screen
	JLT		desenhaNinja			; Se estiver acima, desenha o ninja
	
	CALL	mataNinja 				; Se nao estiver acima da borda mata o ninja 
	JMP		fimEntidadeNinja		; Termina a rotina

	
desenhaNinja:
	MOV		R4, R1 					 
	MOVB	R1, [R4] 				; R1 fica com o valor da coordenada da linha do ninja 
	
	MOV		R4, R2 					 	
	MOVB	R2, [R4]				; R2 fica com o valor da coordenada da coluna do ninja 

	MOV		R3, tabelaNinja
	CALL	desenhaObjeto 			; Rotina que desenha os objectos no ecra 
	
; colisao
colisaoNinja:
	MOV 	R1, coordNinja			; Escreve o endereco do vetor posicao do ninja em R1
	MOV		R2, tabelaNinja			; Escreve o endereco do vetor tamanho do ninja em R2
	; offset
	ADD		R1, R7
	ADD		R1, R7
	
	MOV		R3, coordItem			; Escreve endereco do vetor posicao do item em R3
	MOV		R4, tabelaArma			; Escreve endereco do vetor tamanho do item em R4
	
	CALL	colisao					; Rotina que verifica se ha colisao
	CMP		R5, 0					; Se R5 vale 0, nao houve colisao
	JZ	 	colisaoItem2			; Vai para o ciclo que verifica a colisao com o segundo item no ecra
	
	; se chegou aqui, houve colisao
	MOV		R5, tipoItem
	MOVB	R0, [R5]				; Faz a leitura do tipo de item
	CMP		R0, 0					; Se for presente vai para o ciclo da colisao com o presente
	JZ		colisaoPresente1
	
	; se for colisao com arma:
	CALL	mataNinja				; Rotina que mata um ninja eliminando-o do ecra 
	JMP		ninjaCriaItem1			; Vai para o ciclo que apaga o item que colidiu com o ninja e cria um novo
	
colisaoPresente1:
	CALL	incPontuacao 			; Rotina que incrementa 3 pontos no display sempre que ha colisao ninja-presente 
	
ninjaCriaItem1:
	;novo item
	MOV		R1, coordItem 			; 
	MOV		R2, R1
	ADD		R2, 1
	CALL	apagaItem 				; Rotina que permite apagar um item (arma ou presente) do ecra
	
	MOV		R4, tipoItem 			; Em R4 fica com endereco que indica o tipo de item (arma ou presente)
	CALL	novoItem
	
; segundo item
colisaoItem2:
	MOV 	R1, coordNinja			; Escreve end. do vetor posicao do ninja em r1
	MOV		R2, tabelaNinja			; Escreve end. do vetor tamanho do ninja em r2
	; offset
	ADD		R1, R7 				
	ADD		R1, R7
	
	MOV		R3, coordItem			; Escreve endereco do vetor posicao do item em R3
	ADD		R3, 2
	MOV		R4, tabelaArma			; Escreve endereco do vetor tamanho do item em R4

	CALL	colisao					; Verifica se ha colisao
	CMP		R5, 0					; Se R5 vale 0, nao houve colisao
	JZ	 	fimEntidadeNinja
	
	; se chegou aqui, houve colisao
	MOV		R5, tipoItem
	ADD		R5, 1
	MOVB	R0, [R5]				; Faz a leitura do tipo de item (arma ou presente)
	CMP		R0, 0					; Se for presente, vai para o ciclo de colisao presente - ninja 
	JZ		colisaoPresente2
	
	; se for colisao com arma:
	CALL	mataNinja 				; Rotina que mata um ninja eliminando-o do ecra 
	JMP		ninjaCriaItem2			; Vai para o ciclo que apaga o item que colidiu com o ninja e cria um novo
colisaoPresente2:
	CALL	incPontuacao 			; Rotina que incrementa 3 pontos no display sempre que ha colisao ninja-presente 

	
ninjaCriaItem2:
	;novo item
	MOV		R1, coordItem 			; R1 fica com o endereco da coordenada da linha
	ADD		R1, 2 					; 
	MOV		R2, R1 					; R2 fica com o endereco da coordenada da coluna
	ADD		R2, 1 					; 
	CALL	apagaItem 				; Rotina que permite apagar um item do ecra 
	
	MOV		R4, tipoItem 			; R4 fica com o endereco que contem o tipo de item (arma ou presente)
	ADD 	R4, 1
	CALL	novoItem 				; Rotina que permite gerar outro item (arma ou presente)
	
	

fimEntidadeNinja:
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	
	RET
	
	


; *********************************************************************************
; 3.1.1.1							Sobe Ninja
; ********************************************************************************* 
; Descricao: decrementa posicao do ninja, verifica se saiu da tela
; input:  posicao do ninja
; output: posicao do ninja
; *********************************************************************************	

sobeNinja:
	PUSH	R0
	CALL 	apagaNinja				; Rotina que apaga o ninja do ecra
	MOVB	R0, [R1]				; Le a posicao da linha do ninja
	SUB		R0, 1					; Decrementa a posicao da linha
	CMP		R0, 0					; Compara com o valor do topo do ecra
	JGE		movNinja01
	MOV		R0, 0					; Se o novo valor e negativo, volta para zero
	
	movNinja01:
	MOVB	[R1], R0				; Escreve o novo valor da linha 
	POP		R0

	RET
	
; *********************************************************************************
; 3.1.1.2							Desce Ninja
; ********************************************************************************* 
; Descricao: incrementa posicao do ninja
; input:  posicao do ninja
; output: posicao e vida do ninja
; *********************************************************************************

desceNinja:
	PUSH	R0
	CALL	apagaNinja				; Rotina que apaga o ninja do ecra
	MOVB	R0, [R1]
	ADD		R0, 1					; Incrementa a posicao da linha
	MOVB	[R1], R0				; Escreve novo valor da linha
	
fimDesceNinja:
	POP 	R0

	RET

; *********************************************************************************
; 3.1.1.3						Apaga Ninja
; ********************************************************************************* 
; Descricao: desenha um retangulo branco na posicao do ninja
; input:  posicao do ninja
; output: pixelscreen
; *********************************************************************************

apagaNinja:
	PUSH	R3
	PUSH	R2
	PUSH	R1
	PUSH	R0
	
	MOV		R0, R1 					
	MOVB	R1, [R0] 				; Em R1 fica o valor da coordenada da linha
	
	ADD		R0, 1 					 
	MOVB	R2, [R0] 				; Em R2 fica o valor da coordenada da coluna 
	
	MOV		R3, brancoNinja 		; Em R3 fica o endereco de inicio da tabela com o ninja em branco 
	CALL	desenhaObjeto 			; Rotina que permite desenhar um objeto no ecra 
	
	POP		R0
	POP		R1
	POP		R2
	POP		R3

	RET
	
; *********************************************************************************
; 3.1.1.4							Mata Ninja
; ********************************************************************************* 
; Descricao: altera o valor de vida do ninja e o apaga da tela
; input:  posicao do ninja
; output: vida do ninja
; *********************************************************************************	

mataNinja:
	PUSH	R0
	PUSH	R1
	
	MOV		R0, 0
	MOV		R1, lifeNinja 			; Em R1 fica o endereco com estado do ninja (vivo ou morto)
	; offset						; R7 varia entre 0 e 3, correspondento aos ninjas de 1 a 4, respectivamente 
	ADD		R1, R7 					; Soma-se o valor de R7 para verificar o estado de um certo ninja 
	MOVB	[R1], R0				; Mata o ninja
	MOV		R1, coordNinja 			; Em R1 fica o endereco inicial das coordenadas dos ninjas 
	ADD		R1, R7
	ADD		R1, R7 					; Soma-se 2 vezes o valor de R7 pois as coordendas dos ninjas tem 2 valores por cada ninja
	
	CALL	apagaNinja 				; Rotina que permite apagar um ninja do ecra 
	
	POP		R1
	POP		R0

	RET


; *********************************************************************************
; 3.2						Ciclo Entidade Item
; ********************************************************************************* 
; Descricao: executa as rotinas de entidade dos 2 itens
; input:  posicao do item, tabela de desenho do item
; output: posicao do item
; *********************************************************************************

controleItens:
	PUSH	R0
	PUSH	R5
	PUSH	R7

	MOV		R7, 0 					; R7 vai servir como contador de ninjas

cicloControleItem:
	CMP		R7, 2 					; Se ja foram os 2 itens tratados sai do ciclo
	JZ		fimCicloItens 			; Termina a rotina 
	
	CALL	entidadeItem 			; Rotina que controla as accoes do item  

	ADD		R7, 1 					; Incrementa-se um ao contador de ciclo 
	JMP		cicloControleItem 		

fimCicloItens:
	MOV		R0, movAuto  			; R0 fica com endereco de memoria onde se encontra variavel que indica se deve haver movimento 
	MOV		R5, 0					; 
	MOVB	[R0], R5 				; Faz o reset do valor da variavel que indica se houve movimento, esta e 'activada' 
									; pela interrupcao que faz mover os itens 

	POP		R7
	POP		R5
	POP		R0

	RET
	
; *********************************************************************************
; 3.2.1						Entidade Item
; ********************************************************************************* 
; Descricao: Executa as acoes dos itens (arma/presente), desenha item
; input:  posicao do item, tabela de desenho do item, contador de execucao
; output: posicao do item
; *********************************************************************************

entidadeItem:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH 	R7
	
	; Verifica o estado do programa:
	CMP		R9, 1
	JNZ		fimEntidadeItem			; Se nao estiver em jogo, sai da rotina
	
	; Verifica se houve interrupcao:
	MOV		R0, movAuto
	MOVB	R3, [R0]
	CMP		R3, 1 			
	JNZ		fimEntidadeItem			; Se nao houve, sai da rotina
	
	; Se houve, move o item
	; Le as variaveis do item
	MOV		R1, coordItem			; Coordenada  Y do item
	ADD		R1, R7					; R7 varia entre 0 e 3, correspondento aos ninjas de 1 a 4, respectivamente 
	ADD		R1, R7					; Soma-se o valor de R7 para se obter a coordenada de um certo ninja 
	MOV		R2, R1
	ADD		R2, 1					; Coordenada X do item 
	
	MOV		R4, tipoItem			; tipo de item (presente/arma)
	ADD		R4, R7
	
	CALL 	apagaItem
	
	
	; Move o item para a esquerda
	MOVB	R0, [R2]				; Le a coordenada X do item 
	SUB		R0, 1					; Decrementa 1 a posicao do item 
	MOVB	[R2], r0				; Escreve a nova coordenada do item 
	
	CMP		R0, 0					; Verifica se o item saiu da ecra
	JGE 	desenhaItem				; Se nao saiu, desenha o item
	
	; Se chegou a este ponto e porqu saiu do ecra
	CALL	novoItem 				; Rotina que permite gerar outro item para desenhar no ecra 
	JMP		desenhaItem				; Vai para o ciclo que permite desenhar um item 
	

desenhaItem:
	MOV		R0, R1 					
	MOVB	R1, [R0] 				; R1 fica com o valor da coordenada da linha
	
	MOV		R0, R2 					
	MOVB	R2, [R0] 				; R2 ficam com o valor da coordenada da coluna

	MOVB	R0, [R4] 				
	CMP		R0, 1					; Se for arma vai para o ciclo que permite desenhar a arma 
	JZ		desenhaArma 			
	MOV		R3, tabelaPresente		; Le tabela presente
	CALL	desenhaObjeto 			; Rotina que permite desenhar um objecto no ecra 

	JMP 	fimEntidadeItem 		; Termina a a rotina 
	
desenhaArma:
	MOV		R3, tabelaArma 			; Le tabela arma 
	CALL	desenhaObjeto 			; Rotina que permite desenhar um objecto no ecra 

	
fimEntidadeItem:
	POP		R7	
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	
	RET

	
; *********************************************************************************
; 3.2.1.1						Apaga Item
; ********************************************************************************* 
; Descricao: desenha um retangulo branco na posicao do item
; input:  posicao do item
; output: pixelscreen
; *********************************************************************************
	
apagaItem:
	PUSH	R3
	PUSH	R2
	PUSH	R1
	PUSH	R0
	
	MOV		R0, R1
	MOVB	R1, [R0] 				; Em R1 fica o valor da coordenada da linha
	
	ADD		R0, 1
	MOVB	R2, [R0] 				; Em R2 fica o valor da coordenada da coluna 
	
	MOV		R3, brancoItem 			; Em R3 fica o endereco de inicio da tabela com o item em branco 
	CALL	desenhaObjeto 			; Rotina que permite desenhar objectos no ecra 
	
	POP		R0
	POP		R1
	POP		R2
	POP		R3
	RET
	
; *********************************************************************************
; 3.2.1.2						Novo Item
; ********************************************************************************* 
; Descricao: atribui novos valores a um item
; input:  end. coordenada e tipo de item, contador de execucao
; output: posicao do item, tipo de item
; *********************************************************************************	

novoItem:
	PUSH		R0
	PUSH		R1
	PUSH		R2
	PUSH 		R3
	PUSH		R5
	
	; ve se é o item 1 ou item 2
	MOV			R3, coordItem		; copia o endereco inicial de coordenadas
	MOV			R5, R1				; copia o endereco das coord. sendo tratadas
	SUB			R5, R3				; subtrai os dois valores para saber se tratamos do primeiro ou segundo item
	MOV			R3, 2				; R5 atualmente vale 0 ou 2
	DIV			R5, R3				; R5 passa a valer 0 ou 1
	MOV			R3, 14
	MUL			R5, R3				; R5 passa a valer 0 ou 15
	
	; coordenada Y aleatoria:
	MOV			R0, R10 			; Em R0 fica uma copia do valor em R10 
	MOV			R2, 15				
	MOD			R0, R2 				; Permite gerar um valor entre 0 e 14
	ADD			R0, R5				; cada item fica apenas em sua metade da tela
	MOVB		[R1], R0 			; Escreve a nova coordenada das linhas
	
	; coordenada X inicial
	MOV			R0, 29 				 
	ADD 		R1, 1
	MOVB		[R1], R0			; Escreve a nova coordenada das colunas, movendo o item para o extremo direito do ecra 
	
	; tipo de item
	MOV			R0, R10
	MOV			R2, 3				; Faz o resto da divisao por 3
	MOD			R0, R2
	CMP			R0, 0				; Se for 0, é presente
	JZ			setTipo				; Se for 1, 2 é arma
	MOV			R0, 1
setTipo:	
	MOVB		[R4], R0 			; Escreve na variavel o novo tipo de item a ser criado 
	
	
	POP			R5
	POP 		R3
	POP			R2
	POP			R1
	POP			R0

	RET
	
; *********************************************************************************
; 3.3						Verifica Colisao
; ********************************************************************************* 
; Descricao: verifica se houve colisao entre 2 objetos
; input: posicao, tamanho de 2 objetos 
;			vem na forma (Y, X), (Altura, Largura)
; output: 1 se houve colisao, 0 se nao (R5)
; *********************************************************************************

colisao:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4

	; dados 2 retangulos o1 e o2
	; X e Y sao a posicao do extremo superior esquerdo
	; L e A sao altura e largura
	; ha colisao se:
	;	o1.Y		< o2.Y + o2.A	and
	;	o1.Y + o1.A > o2.Y			and
	;	o1.X 		< o2.X + o2.L 	and
	;	o1.X + o1.L > o2.X
	; nao ha colisao se qualquer um destes for falso
	
	;	o1.Y		>= o2.Y + o2.A
	MOVB	R5, [R3]			; o2.Y
	MOVB	R0, [R4]			; o2.A
	ADD		R5, R0				; o2.Y + o2.A
	
	MOVB	R0, [R1]			; o1.Y
	
	CMP		R0, R5 				; Faz a primeira comparacao, se esta for falsa entao nao ha colisao
	JGE		naoColide
	
	;	o1.Y + o1.A <= o2.Y
	MOVB	R0, [R1]			; o1.Y
	MOVB	R5, [R2]			; o1.A
	ADD		R0, R5				; o1.Y + o1.A
	
	MOVB	R5, [R3]			; o2.Y
	
	CMP		R0, R5
	JLE		naoColide 			;Faz a segunda comparacao, se esta for falsa entao nao ha colisao
	
	; passa ao endereco do segundo numero de cada coordenada
	ADD		R1, 1				; o1.X
	ADD		R2, 1				; o1.L
	ADD		R3, 1				; o2.X
	ADD		R4, 1				; o2.L
	;	o1.X 		>= o2.X + o2.L
	MOVB	R5, [R3]			; o2.X
	MOVB	R0, [R4]			; o2.L
	ADD		R5, R0				; o2.X + o2.L
	
	MOVB	R0, [R1]			; o1.X
	
	CMP		R0, R5
	JGE		naoColide 			;Faz a terceira comparacao, se esta for falsa entao nao ha colisao
	
	;	o1.X + o1.L <= o2.X		
	MOVB	R5, [R2]			; o1.L
	MOVB	R0, [R1]			; o1.X
	ADD		R0, R5				; o1.x + o1.L
	
	MOVB	R5, [R3]			; o2.X
	
	CMP		R0, R5
	JLE		naoColide 			;Faz a ultima comparacao, se sao todas falsas tambem nao ha colisao
	
	
	; se chegar a este ponto, houve colisao
	MOV		R5, 1
	JMP		fimColisao 			; Termina a rotina 

naoColide:
	MOV		R5, 0 				; R5 e o indicador se ha colisao ou nao 

fimColisao:
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0

	RET
	
	
	
; *********************************************************************************
; 4. Rotinas de Fluxo do programa
; *********************************************************************************

; *********************************************************************************
; 4.1						Controle de Estado
; *********************************************************************************
; Descricao: trata das rotinas de fluxo de estado do programa
; input:	estado do programa (R9), tecla (R8)
; output:   estado do programa (R9)
; *********************************************************************************

controleEstado:
	ADD		R10, 1				; Incrementa contador de execucao
	CMP 	R9, 0				; Estado inicial (title screen)
	JZ		eTitleScreen
	
	CMP		R9, 1				; Estado jogo 
	JZ		eJogo
	
	CMP		R9, 2				; Estado pausa
	JZ		ePause
	
	CMP		R9, 3				; Pos jogo
	JZ 		eGameOver
	
eTitleScreen:
	CALL	controleTitleScreen ; Rotina que controla o inicio do jogo
	JMP 	fimControleEstado
eJogo:
	CALL	controleJogo 		; Rotina que controla o jogo quando actvo 
	JMP 	fimControleEstado
ePause:
	CALL	controlePause 		; Rotina que controla a pausa do jogo
	JMP		fimControleEstado
eGameOver:
	CALL	controleGameOver 	; Rotina que controla o fim co jogo
	
fimControleEstado:
	RET
	
; *********************************************************************************
; 4.1.1						Controle de Estado 0
; *********************************************************************************
; Descricao: verifica se o jogo deve ser iniciado(0->1)
; input:	estado do programa (R9), tecla (R8)
; output:   estado do programa (R9)
; *********************************************************************************

controleTitleScreen:
	PUSH 	R0
	PUSH	R1
	MOV		R0, 0CH
	
	CMP		R8, R0				
	; Se o valor em R10 nao for 0CH
	JNZ		fimCTitleScreen		; Sai da rotina
	
	; Se for 0CH
	CALL	limpa_ecra			; Rotina que limpa o ecra
	MOV		R9, 1				; Muda o estado do programa
	
	; Faz reset das variaveis 
	CALL	init_var 			; Rotina que inicia as variaveis
	
fimCTitleScreen:
	POP		R1
	POP		R0
	RET
	
; *********************************************************************************
; 4.1.2						Controle de Estado 1
; *********************************************************************************
; Descricao: verifica se o jogo deve ser pausado(1->2) ou terminado(1->3)
; input:	estado do programa (R9), tecla (R8)
; output:   estado do programa (R9)
; *********************************************************************************

controleJogo:
	PUSH 	R0
	PUSH	R1
	PUSH 	R2
	
	MOV		R0, 0DH
	
	CMP		R8, R0				
	; Se o valor em R10 nao for 0DH
	JNZ		cJogoTecE			; Vai para o proximo passo
	
	; Se for 0Dh
	MOV		R9, 2				; Muda o estado do programa
	
cJogoTecE:
	MOV		R0, 0EH
	
	CMP		R8, R0				
	; Se o valor em R10 nao for 0EH
	JNZ		ninjasVivos			; Proximo passo
	
	; Se for 0EH
	JMP		vaiGameOver
	
ninjasVivos:
	MOV		R0, lifeNinja
	MOV		R2, 4 				
cicloNinjasVivos:
	MOVB	R1, [R0] 			; Faz a leitura da variavel de vida do ninja 
	CMP		R1, 1 				
	JZ		fimCJogo			; Se algum ninja tiver vivo, termina rotina
	
	ADD		R0, 1
	
	SUB		R2, 1
	JNZ		cicloNinjasVivos 	; Sai do ciclo apos 4 repeticoes e se nenhum ninja estiver vivo  
	
vaiGameOver:					; Chega nesse ponto se nenhum ninja estiver vivo
	MOV		R9, 3				; Muda o estado do programa
	CALL	limpa_ecra			; Limpa o ecra
	MOV		R0, ecra_GO			
	CALL	desenha_ecra		; Desenha o ecra de game over
	
fimCJogo:
	POP		R2
	POP		R1
	POP		R0
	RET

; *********************************************************************************
; 4.1.3						Controle de Estado 2
; *********************************************************************************
; Descricao: verifica se o jogo deve ser continuado(2->1)
; input:	estado do programa (R9), tecla (R8)
; output:   estado do programa (R9)
; *********************************************************************************

controlePause:
	PUSH	R0
	
	MOV		R0, 0DH
	CMP		R8, R0				
	; Se o valor em R10 nao for 0Dh
	JNZ		fimCPause			; Sai da rotina
	
	; Se for 0Dh
	MOV		R9, 1				; Muda o estado do programa

fimCPause:
	POP		R0
	RET
	
; *********************************************************************************
; 4.1.4						Controle de Estado 3
; *********************************************************************************
; Descricao: verifica se o jogo deve ser iniciado(3->1)
; input:	estado do programa (R9), tecla (R8)
; output:   estado do programa (R9)
; *********************************************************************************

controleGameOver:
	PUSH 	R0
	MOV		R0, 0CH
	
	CMP		R8, R0				
	; Se o valor em R10 nao for 0Ch
	JNZ		fimCGameOver		; Sai da rotina
	
	; Se for 0Ch
	CALL	limpa_ecra			; Limpa o ecra
	MOV		R9, 1				; Muda o estado do programa
	; Faz o reset das varaiveis de jogo
	CALL	init_var
	
fimCGameOver:
	POP		R0
	RET
	
; *********************************************************************************
; 4.2						Incrementa Pontuacao
; ********************************************************************************* 
; Descricao: incrementa a pontuacao em 3 pontos e escreve no display
; input: pontuacao
; output: pontuacao
; *********************************************************************************

incPontuacao:

	PUSH 	R0
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3	
	PUSH	R4
	PUSH	R6
	
	MOV		R0,pontuacao	
	MOVB	R1,[R0]				; Vai a memoria buscar o valor actual da pontuacao 
	MOV		R2, 63H				; Se a pontuacao estiver no maximo nao se adiciona mais pontuacao (63H corresponde a 99 em decimal) 
	CMP		R1, R2			 
	JZ		Hexa_p_decimal	
	ADD		R1, 3				; Adiciona 3 a pontuacao
	MOVB	[R0],R1				; Escreve a nova pontuacao na memoria
	
Hexa_p_decimal:
	MOV		R4, R1				; R1 armazena o valor nos displays logo nao pode ser utilizado nas operacoes de conversao 
	MOV		R6, R1				; Utilizacao das variaveis R4 e R6 para fazer a conversao de hexadecimal para decimal
	MOV 	R2, 10				; R1 permite fazer a divisao 
	DIV		R6, R2				; Equivalente a fazer a divisao inteira de um decimal por 10, isola o valor das dezenas 
	SHL		R6, 4				; Passa o valor para o nibble high, ou seja a posicao das dezenas 	
	MOD 	R4,	R2				; Isola o valor das unidades
	OR		R6,	R4				; Faz como a soma das dezenas com as unidades, juntando os nibbles diferentes de 0
	
	MOV		R0, DISPLAYS
No_diplay:
	MOVB 	[R0], R6			; Passa para o display o valor depois de aplicada a operacao 
	JMP		fimIncPontuacao

	
fimIncPontuacao:

	POP		R6
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP 	R0

	RET
	
	
; *********************************************************************************
; 5. Rotinas de Interrupcao
; *********************************************************************************
; *********************************************************************************
; 5.1								Interrupcao0
; *********************************************************************************
; input:	
; output:   movAuto[0]
; *********************************************************************************

exc0:
	PUSH	R0
	PUSH	R1
	
	MOV		R0, movAuto
	MOV		R1, 1 				
	MOVB 	[R0], R1 			; 'Activa' a variavel de movimento vertical automatico
	
	POP		R1
	POP		R0
	RFE
	
; *********************************************************************************
; 5.2								Interrupcao1
; *********************************************************************************
; input:	
; output:   movAuto[1]
; *********************************************************************************

exc1:
	PUSH	R0
	PUSH	R1
	
	MOV		R0, movAuto
	ADD		R0, 1 				
	MOV		R1, 1
	MOVB 	[R0], R1 			; 'Activa' a variavel de movimento horizontal automatico
	
	POP		R1
	POP		R0	
	RFE
	
	
	
; *********************************************************************************
; 6. Rotinas de Desenho
; *********************************************************************************
; *********************************************************************************
; 6.1								DesenhaObjeto
; *********************************************************************************
; Descricao: desenha um obejto na tela
; input:	posicao Y (r1), posicao X (r2), endereco da tabela do objeto (r3)
; output:   pixelscreen
; *********************************************************************************

desenhaObjeto:
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
	
	MOVB	R4, [R3]			; Altura em R4
	ADD		R3, 1				; R3 vai para o endereco da largura
	MOVB	R5, [R3]			; Largura em R5
	ADD		R3, 1				; R3 tem o endereco do inicio da tabela de pixel

cicloObj:
	SUB 	R4, 1
	CMP		R4, 0
	JN		fimDesenhaObj
	PUSH	R3					; Guarda o endereco inicial da tabela
	PUSH	R5					; Guarda a alrgura do objeto
	MUL		R5, R4				; Offset na tabela
	ADD		R3, R5				; Endereco da linha na tabela
	POP 	R5
	CALL	desenhaLinha
	POP 	R3					; Retoma o valor 
	JMP 	cicloObj
	
fimDesenhaObj:	
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	
	RET


; *********************************************************************************
; 6.1.1								 DesenhaLinha
; *********************************************************************************
; Descricao: Desenha uma linha de um objeto
; input:	posicaoY (r1), posicaoX (r2), endereco da linha (r3), 
; 			linha (r4), largura (r5)
; output:   pixelscreen
; *********************************************************************************

desenhaLinha:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	
	MOV		R0, R3				; Copia o endereco da linha
	ADD		R1, R4
	ADD		R0, R5				; Endereco final da linha
	
cicloLinha:
	CMP		R3, R0
	JZ 		fimDesenhaLinha		; Se o endereco atual for igual ao final, sai do cicloLinha
	CALL	desenhaPixel		
	ADD 	R2, 1				; Passa para a proxima coluna
	ADD		R3, 1				; Passa para o proximo endereco
	JMP		cicloLinha
	
fimDesenhaLinha:
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	
	RET


; *********************************************************************************
; 6.1.2							Desenha pixel
; *********************************************************************************
; Descricao: desenha um pixel na tela
; input: 	linha (r1), col (r2), endereco do valor (r3)
; output: 	pixelscreen
; *********************************************************************************

desenhaPixel:
	PUSH 	R0
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
	PUSH	R5
	
; converte linha e coluna para enderecos
	MOV 	R0, 4
	MUL 	R1, R0				; Linha
	
	MOV 	R4, R2				; Copia coluna
	
	MOV 	R0, 8		
	DIV		R2, R0				; Coluna
	
	MOD 	R4, R0				; Peso do bit
	
	MOV 	R0, SCREEN			; Passa endereco da tela ao R0
	ADD 	R2, R1
	ADD 	R2, R0				; Endereco do byte em R2
	
	
	MOV 	R0, mask
	ADD 	R4, R0				; Seleciona a mascara adequada
	
	SUB		R0, R0				; Faz reset do valor em R0
	
	MOVB	R0, [R4]			; Poe a mascara em R0
	
	MOVB	R5, [R3]
	CMP 	R5, 1				; Se for para acender pixel
	JZ	 	acendePixel
	JMP		apagaPixel
	
	
acendePixel:
	MOVB 	R1, [R2]			; Le o valor no endereco
	OR		R0, R1				; Or bit a bit com o valor sendo exibido
	MOVB 	[R2], R0			; escreve o novo valor no periferico
	JMP		fimDesenhaPixel
	
apagaPixel:
	NOT 	R0					; Se for para apagar pixel
	
	MOVB 	R1, [R2]			; Le o valor no endereco
	AND		R0, R1				; And bit a bit com o valor sendo exibido
	MOVB 	[R2], R0			; Escreve o novo valor no periferico

fimDesenhaPixel:
	
	POP		R5
	POP		R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	RET
	
; *********************************************************************************
; 6.2									Limpa Ecra
; *********************************************************************************
; Descricao: Limpa o pixel sreen  
; input: nenhum
; output: 	pixelscreen
; *********************************************************************************


limpa_ecra:

	PUSH	R1
	PUSH	R2 
	PUSH 	R3
	
	MOV 	R1, SCREEN 				; Introduz no R1 o endereco do inicio do pixel sreen
	MOV		R2, SCREND 				; Introduz no R2 o endereco do fim do pixel screen
	MOV 	R3, 0
	
cicloLimpaEcra:
	MOVB	[R1], R3 				; Limpa o byte em R1 
	ADD 	R1, 1					; Passa para o segundo byte que se pretende limpar 
	CMP 	R1, R2 					; Verifica se o ultimo byte do ecra ja foi limpo 
	JNZ		cicloLimpaEcra 			; Repete o ciclo ate o pixel screen estar todo limpo

	
	POP 	R3
	POP		R2
	POP		R1
	
	RET
	
; *********************************************************************************
; 6.3								Desenha Ecra
; *********************************************************************************
; Desricao: Funcao que desenha uma tela do programa
; input: 	tela a desenhar
; output: 	pixelscreen
; *********************************************************************************
	
desenha_ecra:

	PUSH	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R0
	
	MOV 	R1, SCREEN 				; Introduz no R1 o endereco do inicio do pixel sreen
	MOV 	R2, SCREND				; Introduz no R2 o endereoo do fim do pixel screen
	
cicloDesenhaEcra: 
	MOVB 	R3, [R0]				; 
	MOVB 	[R1],R3 				; Desenha/pinta no pixel screen a string lida 
	ADD		R1, 1					; Passa para o proximo byte do pixel screen 
	ADD		R0, 1 					; Passa para a proxima string a ser desenhada/pintada no pixel screen
	CMP 	R1,R2 					; Verifica se já atingirmos ao ultimo endereco(do pixel screen)
	JNZ 	cicloDesenhaEcra		; Volta a repetir o ciclo ate conseguir chegar ao fim 
	
	MOVB	R3, [R0] 				; Le o valor da ultima string para ser desenhada/pintada no pixel screen  
	MOVB 	[R1],R3 				; Desenha/Pinta no ultimo byte do pixel screen 
	
	POP 	R0
	POP		R3
	POP		R2
	POP		R1 
	
	RET