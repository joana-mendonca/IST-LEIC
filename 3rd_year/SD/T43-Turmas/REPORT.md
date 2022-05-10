# Report

Nesta terceira fase, assume-se que o sistema contém dois servidores a comunicar entre si, sendo um primário e outro secundário.
Por default, os servidores propagam-se a cada minuto assim que se conectarem.

## Proposta de solução para incoerência no cancelamento de inscrições
	Quando um professor cancela a inscrição de um estudante num servidor e enquanto esta não se propaga e o mesmo estudante  inscreve-se noutro servidor, quando ocorrer a propagação, o estudante irá ficar sempre na lista de alunos não inscritos dando sempre prioridade à operação realizada pelo professor, mesmo que o aluno tenha recebido a mensagem de que a sua inscrição foi feita com sucesso. Sendo que se ele listar a turma, poderá ver que o seu nome se encontra na lista de não inscritos.
	Se este mesmo aluno voltar a tentar inscrever-se após a propagação, o seu nome irá então ser removido da lista de alunos não inscritos e passará a constar na lista de inscritos.

## Proposta de solução para incoerência de inscrições de alunos em servidores diferentes
	Considere-se o conflito proposto no enunciado, em que um professor abre as inscrições com uma capacidade = 2 (por exemplo), e dois alunos se inscrevem no servidor S1 e outros dois no servidor S2. Quando ocorre a propagação de um dos servidores, o critério de escolha dos alunos que ficam inscritos é pela ordem crescente dos ids (baixo nível de fairness), sendo que os restantes alunos ficam na lista de alunos não inscritos.