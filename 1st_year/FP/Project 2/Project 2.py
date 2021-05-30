#Joana Mendonca, 83597
""" PROJETO 2 """

from parte1 import e_palavra

import itertools

"""TAD palavra_potencial"""
def cria_palavra_potencial(cadeia_caract, conjunto):
    #Funcao construtor do tipo palavra_potencial
    #Recebe como argumentos uma cadeia de caracteres(cadeia_caract) e um conjunto de letras(conjunto) e devolve uma palavra_potencial
    def verifica(cadeia_caract, conjunto):
        
        x = list(conjunto)
        
        for i in cadeia_caract:
            if i in x:
                x.remove(i)
            else:
                raise ValueError('cria_palavra_potencial:a palavra nao e valida.')              
            
    if not isinstance(cadeia_caract, str) or not isinstance(conjunto, tuple):    
        # Verifica a validade dos argumentos 
        raise ValueError('cria_palavra_potencial:argumentos invalidos.')

    for i in cadeia_caract:
        # Verifica se a cade e maiuscula
        if not (i >= 'A' and i <= 'Z'):
            raise ValueError('cria_palavra_potencial:argumentos invalidos.') 
        
    for i in conjunto:
        # Verifica se a palavra e maiuscula
        if not (i >= 'A' and i <= 'Z'):
            raise ValueError('cria_palavra_potencial:argumentos invalidos.')     
                                
    
    if len(cadeia_caract) > len(conjunto):
        # Verifica se a cadeia de caracteres contem mais do que as letras existentes no conjunto de letras em jogo
        raise ValueError('cria_palavra_potencial:a palavra nao e valida.')    
    
    verifica(cadeia_caract, conjunto)                   #Chama a funcao verifica

    return [cadeia_caract]

def palavra_tamanho(p):
    #Recebe como argumento a palavra_potencial(cadeia_caract) e devolve o numero de letras da palavra
    return len(p[0])

def e_palavra_potencial(p):
        
    if not isinstance(p, list):
        return False
    if p == 0:
        return False
    #
    if p == []:
        return False
    #if not isinstance(p[0], str):
    #    return False
    #if len(p) != 1:
    #    return False
    else:
        return True

def palavras_potenciais_iguais(p1, p2):
    return (p1[0] == p2[0])

def palavra_potencial_menor(p1, p2):
    return (p1[0] < p2[0])

def palavra_potencial_para_cadeia(p):
    return (p[0])
    

"""TAD conjunto_palavras"""
def cria_conjunto_palavras():
    return ([])

def numero_palavras(conjunto):
    return len(conjunto)

def subconjunto_por_tamanho(conjunto, n):
    lista = []
    for i in conjunto:
        if len(i[0]) == n:                      
            lista = lista + [i]                       
    return (lista)

def e_conjunto_palavras(c):
    if isinstance(c, list):
        for i in c:
            if not e_palavra_potencial(i):
                return False
        return True
    return False
        
def acrescenta_palavra(conjunto, p):
    if not e_palavra_potencial(p) or not e_conjunto_palavras(conjunto):
        raise ValueError('acrescenta_palavra:argumentos invalidos.')
    elif p not in conjunto:
        conjunto.append(p)

def conjuntos_palavras_iguais(conjunto_1, conjunto_2):   
    if not len(conjunto_1) == len(conjunto_2):
        return False
        
    if conjunto_1 == []:
        return True
    
    for i in conjunto_1:
        if i not in conjunto_2:
            return False
    return True

def conjunto_palavras_para_cadeia(c):
    c.sort()                                            #ordena a lista por ordem alfabetica e por len
    maior_tamanho = len(c[-1][0])                       #a palavra de maior tamanho e a ultima da lista ordenada
    final = "["                                         #onde vai estar o return no final
    cont = 0                                            #contador para o ciclo comeca em 0 porque o len menor e 0
    if c == cont:
        return '[]'
    while cont <= maior_tamanho:                        #enquanto houver palavras cujo o tamanho e menor ou igual ao da ultima palavra
        lista_aux = subconjunto_por_tamanho(c, cont)         
        if lista_aux != []:                             #se a lista nao estiver vazia(ou seja, ha palavras do tamanho cont, feita na divisao da funcao subconjunto_por_tamanho)
            final += str(cont)                          #adiciona a string o tamanho da palavra
            final += "->"                               #adiciona a string a setinha
            final += str(lista_aux)                     #adiciona a string a lista 
            if cont < maior_tamanho: 
                final += ";"                            #adiciona a string o ponto e virgula
#        else:
#            return '[]'
        cont += 1                                       #incrementa o contador para continuar as prox. iteracoes             
    final += "]"
    final = final.replace("\'", "")

    return final                                        #retorna a string

"""TAD Jogador"""
def cria_jogador(jogador):
    if not isinstance(jogador, str):
        raise ValueError('cria_jogador:argumento invalido.')  
    
    jogador = {'JOGADOR': jogador, 'PONTOS=': 0, 'VALIDAS=': [], 'INVALIDAS=': []}     
    return jogador
        
def jogador_nome(jogador):
    return jogador['JOGADOR']

def jogador_pontuacao(jogador):
    return jogador['PONTOS=']

def jogador_palavras_validas(jogador):
    return jogador['VALIDAS=']

def jogador_palavras_invalidas(jogador):
    return jogador['INVALIDAS=']
        

def adiciona_palavra_valida(jogador, p):
    if e_palavra_potencial(p):
        #adiciona as palavras validas
        #if not p in jogador['VALIDAS=']:
        jogador['VALIDAS='].append(p)
        
        #soma os pontos
        jogador['PONTOS='] += len(p)
    else:
        raise ValueError('adiciona_palavra_valida:argumentos invalidos.')
    
def adiciona_palavra_invalida(jogador, p):
    if e_palavra_potencial(p):
        #adiciona as palavras invalidas
        #if not p in jogador['INVALIDAS=']:
        jogador['INVALIDAS='].append(p)
        
        #subtrai os pontos
        jogador['PONTOS='] -= len(p)
    else:
        raise ValueError('adiciona_palavra_valida:argumentos invalidos.')
    
def compare_dic(dic_1, dic_2):
    for key in dic_1:
        if key in dic_2:
            if type(dic_1[key]) != type(dic_2[key]):
                return False
        else:
            return False
    return True


def e_jogador(n):
    if isinstance(n, dict):
        nome = n['JOGADOR']
        compare = cria_jogador(nome)                         #tipo jogador na forma correcta 
        if (len(n) == len (compare)):                        #verifica se tem o mesmo tamanho
            res = compare_dic(compare, n)                    #verifica se as keys tem o mesmo nome e os conteudos do mesmo tipo 
            return res                                       #so retorna True se os dicionarios tiverem o msm tamanho e as mesmas keys
    return False

def jogador_para_cadeia(jog):
    cad_caract = ''
    cad_caract += 'JOGADOR ' 
    cad_caract += jogador_nome(jog)
    cad_caract += ' PONTOS='
    cad_caract += jogador_pontuacao(jog)
    cad_caract += ' VALIDAS='
    cad_caract += conjunto_palavras_para_cadeia(jogador_palavras_validas(jog))
    cad_caract += ' INVALIDAS='
    cad_caract += conjunto_palavras_para_cadeia(jogador_palavras_validas(jog))
    return cad_caract

"""Funcoes adicionais"""
def gera_todas_palavras_validas(letras):
    conj_final = cria_conjunto_palavras()
    for i in range(1, len(letras)+1):
        palavras = (list(itertools.permutations(letras, i)))          #lista de tuplos (com strings la dentro)
        for tuplos in palavras:                                       #transformar numa lista de strings, por cada tuplo dentro da lista
            potencial = ''.join(tuplos)                               #transforma o tuplo numa string com o .join ('' para n haver nada entre as letras)
            if e_palavra(potencial):                                  #se a palavra pontencial for valida
                valida = [potencial]
                acrescenta_palavra(conj_final, valida)                #acrescenta a lista dos conjuntos finais
    return conj_final


def guru_mj(letras):
    print('Descubra todas as palavras geradas a partir das letras:')
    print(letras)
    jogador = eval(input('Introduza o nome dos jogadores (-1 para terminar)...\n'))
    n = 1
    lista_jogadores = []
    numero_jogadores = 0
    while jogador != -1:
        print('JOGADOR ' + str(n) + ' -> ' + str(jogador))
        n += 1
        lista_jogadores += [cria_jogador(jogador)]
        numero_jogadores += 1
        jogador = eval(input())
        if jogador == -1:
            print('JOGADOR ' + str(n) + ' -> ' + str(jogador))

    todas_palavras = gera_todas_palavras_validas(letras)
    numero_palavras = len(todas_palavras)
        
    k = 0
    while numero_palavras > 0:
        print('JOGADA ' + str(k+1) + ' - Falta descobrir ' + str(numero_palavras) + ' palavras')
        num_jogador = k % numero_jogadores
        proposta = eval(input('JOGADOR ' + jogador_nome(lista_jogadores[num_jogador]) + ' -> '))
        if [proposta] in todas_palavras:
            print (proposta + ' - palavra VALIDA')
            adiciona_palavra_valida(lista_jogadores[k%numero_jogadores], [proposta])
            numero_palavras -= 1
        else:
            print (proposta + ' - palavra INVALIDA')
            adiciona_palavra_invalida(lista_jogadores[k%numero_jogadores], [proposta])
        k += 1
    #coloca as pontuacoes dos jogadores por ordem crescente
    jogadores_por_ordem = sorted(lista_jogadores, key=lambda k: k['PONTUACAO='])
    
    #verifica as duas ultimas pontuacoes da lista, se forem iguais ocorre empate
    if jogador_pontuacao(jogadores_por_ordem[-1]) == jogador_pontuacao(jogadores_por_ordem[-2]):
        print('FIM DE JOGO! O jogo terminou em empate.')
    #qdo nao sao iguais ha um vencedor
    else:
        print('FIM DE JOGO! O jogo terminou com a vitoria do jogador ' + \
              jogador_nome(jogadores_por_ordem[-1]) + ' com ' + \
              str(jogador_pontuacao(jogadores_por_ordem[-1])) + ' pontos.')
    n = 0
    while(n <= numero_jogadores):
        print(jogador_para_cadeia(lista_jogadores[n]))
