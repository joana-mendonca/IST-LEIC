# Joana Mendonca, 83597 (Projeto "Palavra GURU", 1ano: 1sem.)

"""

Valor booleano da gramatica

(Funcoes que definem a gramatica. Sao utilizadas listas para definir a posicao das vogais/consoantes/ditongos)

"""

def artigo_def(n):
    return (n == 'O' or n == 'A')

def vogal_palavra(n):
    return (n == 'E' or artigo_def(n))

def vogal(n):
    return (n == 'I' or n == 'U' or vogal_palavra(n))

def ditongo_palavra(n):
    return (n == 'AI' or n == 'AO' or n == 'EU' or n == 'OU')

def ditongo(n):
    return (n == 'AE' or n == 'AU' or n == 'EI' or n == 'OE' or n == 'OI' or n == ' IU' or ditongo_palavra(n))

def par_vogais(n):
    return (n == 'IA' or n == 'IO' or ditongo(n))

def consoante_freq(n):
    return (n == 'D' or n == 'L' or n == 'M' or n == 'N' or n == 'P' or n == 'R' or n == 'S' or n == 'T' or n == 'V')

def consoante_terminal(n):
    return (n == 'L' or n == 'M' or n == 'R' or n == 'S' or n == 'X' or n == 'Z')

def consoante_final(n):
    return (n == 'N' or n == 'P' or consoante_terminal(n))

def consoante(n):
    return (n == 'B' or n == 'C' or n == 'D' or n == 'F' or n == 'G' or n == 'H' or n == 'J' or n == 'L' or n == 'M'
            or n == 'N' or n == 'P' or n == 'Q' or n == 'R' or n == 'S' or n == 'T' or n == 'V' or n == 'X' or n == 'Z')

def par_consoantes(n):
    return (n == 'BR' or n == 'CR' or n == 'FR' or n == 'GR' or n == 'PR' or n == 'TR' or n == 'VR' or n == 'BL'
            or n == 'CL' or n == 'FL' or n == 'GL' or n == 'PL')

def monossilabo_2(n):
    return (n == 'AR' or n == 'IR' or n == 'EM' or n == 'UM' or (vogal_palavra(n[0]) and n[1] == 'S') or
            ditongo_palavra(n) or (consoante_freq(n[0]) and vogal(n[1])))

def monossilabo_3(n):
    return ((consoante(n[0]) and vogal(n[1]) and consoante_terminal(n[2])) or ((consoante(n[0]) and ditongo(n[1:3]))) or
            ((par_vogais(n[0:2]) and consoante_terminal(n[2]))))

def silaba_2(n):
    return (par_vogais(n) or (consoante(n[0]) and vogal(n[1])) or (vogal(n[0]) and consoante_final(n[1])))

def silaba_3(n):
    return (n == 'QUA' or n == 'QUE' or n == 'QUI' or n == 'GUE' or
            n == 'GUI' or (vogal(n[0]) and n[1] == 'N' and n[2] == 'S') or
            (consoante(n[0]) and par_vogais(n[1:3])) or
            (consoante(n[0]) and vogal(n[1]) and consoante_final(n[2])) or
            (par_vogais(n[0:2]) and consoante_final(n[2])) or
            (par_consoantes(n[0:2]) and vogal(n[2])))

def silaba_4(n):
    return ((par_vogais(n[0:2]) and n[2] == 'N' and n[3] == 'S') or
            (consoante(n[0]) and vogal(n[1]) and n[2] == 'N' and n[3] == 'S') or
            (consoante(n[0]) and vogal(n[1]) and n[2] == 'I' and n[3] == 'S') or
            (par_consoantes(n[0:2]) and par_vogais(n[2:4])) or
            (consoante(n[0]) and par_vogais(n[1:3]) and consoante_final(n[3])))

def silaba_5(n):
    return (par_consoantes(n[0:2]) and vogal(n[2]) and n[3] == 'N' and n[4] == 'S')


""" 

Funcoes usadas em palavra

"""

def monossilabo(n):
    if len(n) == 1:
        return vogal_palavra(n)
    elif len(n) == 2:
        return monossilabo_2(n)
    elif len(n) == 3:
        return monossilabo_3(n)
    else:
        return False

# Funcao silaba pode surgir em palavra 0/+ vezes
def silaba(n):
    if len(n) == 1:
        return (vogal(n))
    elif len(n) == 2:
        return silaba_2(n)
    elif len(n) == 3:
        return silaba_3(n)
    elif len(n) == 4:
        return silaba_4(n)
    elif len(n) == 5:
        return silaba_5(n)
    else:
        return False

# Funcao silaba_final usada em palavra juntamente com silaba (sempre que nao se verifique que e monossilabo)
def silaba_final(n):
    if len(n) == 2:
        return monossilabo_2(n)
    elif len(n) == 3:
        return monossilabo_3(n)
    elif len(n) == 4:
        return silaba_4(n)
    elif len(n) == 5:
        return silaba_5(n)
    else:
        return False


# Funcao palavra
def palavra(n):
    """ Verifica a existencia de monossilabo ou de silaba_final, retornando a recursiva quando esta ultima existe """
    if monossilabo(n):
        return True
    for i in range(-5, -1):
        if silaba_final(n[i:]):                   # Verifica as ultimas 5 letras de n
            if len(n[:i]) == 0:                   # Se nao tiver nenhuma silaba (len = 0) retorna True
                return True                       # (So retorna True porque pode ter 0 ou mais silabas)
            else:                                 # Se tiver len > 0 silabas retorna a funcao recursiva
                return (recursiva(n[:i]))
    return False

# Funcao auxiliar
def recursiva(n):
    """ Apos excluir a silaba_final, comeca por avaliar a validade das silabas verificando-as da esquerda para a
    direita """
    for i in (5, 4, 3, 2, 1):                    # Verifica da maior para a menor silaba
        if (silaba(n[0:i])):
            return (recursiva(n[i:]))
    return (len(n) == 0)                         # Quando ja nao houver palavas, termina de validar a palavra


"""

Inicio da definicao do valor booleano das funcoes e_silaba, e_monossilabo e e_palavra 

"""

def e_silaba(n):
    """ Funcao verifica se o valor introduzido em e_silaba e uma string """
    if isinstance(n, str):
        return (silaba(n))
    else:
        raise ValueError('e_silaba:argumento invalido')

def e_monossilabo(n):
    """ Funcao verifica se o valor introduzido em e_monossilabo e uma string """
    if isinstance(n, str):
        return (monossilabo(n))
    else:
        raise ValueError('e_monossilabo:argumento invalido')

def e_palavra(n):
    """ Funcao verifica se o valor introduzido em e_palavra e uma string, retornando a funcao associada quando e str """
    if isinstance(n, str):
        return (palavra(n))
    else:
        raise ValueError('e_palavra:argumento invalido')

