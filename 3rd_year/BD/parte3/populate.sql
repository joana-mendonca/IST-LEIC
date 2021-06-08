/* ------------------------------------------------------------------ */
/*                       BASES DE DADOS 2019/20                       */
/*                          PROJETO, PARTE 3                          */
/*                            populate.sql                            */
/*                                                                    */
/*                             GRUPO TP20                             */
/*                        JOANA MENDONCA, 83597                       */
/*                        GONCALO GUERRA, 83899                       */
/*                        FILIPE COLACO, 84715                        */
/* ------------------------------------------------------------------ */

/* LOCAL_PUBLICO */
insert into local_publico values (37.090107, -8.245698, 'CM Albufeira');
insert into local_publico values (37.124397, -8.242660, 'Estádio da Nora');
insert into local_publico values (37.294707, -8.865825, 'Restaurante Praia da Arrifana');
insert into local_publico values (37.805280, -7.498860, 'EB1 de Vales Mortos');
insert into local_publico values (38.572649, -7.907292, 'Templo de Diana');
insert into local_publico values (38.679623, -9.333943, 'Quicksilver Carcavelos');
insert into local_publico values (38.737331, -9.303058, 'IST - Taguspark');
insert into local_publico values (38.771872, -7.715818, 'Castelo de Évora Monte');
insert into local_publico values (38.775502, -9.135351, 'Aeroporto de Lisboa');
insert into local_publico values (39.024452, -8.792789, 'Praça de Toiros de Salvaterra de Magos');
insert into local_publico values (39.353941, -9.380222, 'Fortaleza de Peniche');
insert into local_publico values (39.658880, -8.825509, 'Mosteiro da Batalha');
insert into local_publico values (40.224916, -8.423367, 'Hospital da Luz - Coimbra');
insert into local_publico values (40.659928, -7.911064, 'Sé de Viseu');
insert into local_publico values (41.162203, -8.642465, 'Estádio do Bessa XXI');
insert into local_publico values (41.279030, -8.378315, 'Bombeiros Voluntários de Paços de Ferreira');

/* ITEM */
insert into item values (0, 'Placar de cortiça', 'Junto ao gabinete do vice-presidente', 37.090107, -8.245698);
insert into item values (1, 'Placa de aviso', 'À entrada para os balneários', 37.124397, -8.242660);
insert into item values (2, 'Placa de aviso', 'Junto da casa de banho', 37.294707, -8.865825);
insert into item values (3, 'Placa com descrição de procedimentos', 'Na cozinha da cantina, por cima do lava-louças', 37.805280, -7.498860);
insert into item values (4, 'Tabela de preços', 'À entrada da loja de souvenirs', 38.572649, -7.907292);
insert into item values (5, 'Publicidade de promoção', 'Junto aos sapatos', 38.679623, -9.333943);
insert into item values (6, 'Regras de comportamento na sala', 'Na sala 1-27, ao lado do quadro branco', 38.737331, -9.303058);
insert into item values (7, 'Tabela de horário', 'À esquerda da porta de entrada', 38.771872, -7.715818);
insert into item values (8, 'Aviso de cobrança', 'À entrada do estacionamento das chegadas', 38.775502, -9.135351);
insert into item values (9, 'Aviso de idade mínima', 'Ao lado da bilheteira', 39.024452, -8.792789);
insert into item values (10, 'Placa de "não pisar a relva"', 'Nos jardins de fora', 39.353941, -9.380222);
insert into item values (11, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (12, 'Aviso de radiação', 'Junto à sala 5 de TACs', 40.224916, -8.423367);
insert into item values (13, 'Placa de "não tocar"', 'À entrada do jardim, à direita', 40.659928, -7.911064);
insert into item values (14, 'Placa com avisos gerais', 'Na porta da secção visitante', 41.162203, -8.642465);
insert into item values (15, 'Aviso de saída de viaturas', 'À direita da entrada de veículos', 41.279030, -8.378315);
insert into item values (16, 'Aviso de saída de viaturas', 'À direita da entrada de veículos', 41.279030, -8.378315);
insert into item values (17, 'Tabela de horário', 'À esquerda da porta de entrada', 38.771872, -7.715818);
insert into item values (18, 'Placa de aviso', 'Junto da casa de banho', 37.294707, -8.865825);
insert into item values (19, 'Regras de comportamento na sala', 'Na sala 1-27, ao lado do quadro branco', 38.737331, -9.303058);
insert into item values (20, 'Placa com avisos gerais', 'Na porta da secção visitante', 41.162203, -8.642465);
insert into item values (21, 'Aviso de radiação', 'Junto à sala 5 de TACs', 40.224916, -8.423367);
insert into item values (22, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (23, 'Regras de comportamento na sala', 'Na sala 1-27, ao lado do quadro branco', 38.737331, -9.303058);
insert into item values (24, 'Placa de "não tocar"', 'À entrada do jardim, à direita', 40.659928, -7.911064);
insert into item values (25, 'Tabela de preços', 'À entrada da loja de souvenirs', 38.572649, -7.907292);
insert into item values (26, 'Tabela de horário', 'À esquerda da porta de entrada', 38.771872, -7.715818);
insert into item values (27, 'Placa de aviso', 'Junto da casa de banho', 37.294707, -8.865825);
insert into item values (28, 'Placa de "não tocar"', 'À entrada do jardim, à direita', 40.659928, -7.911064);
insert into item values (29, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (30, 'Placa com avisos gerais', 'Na porta da secção visitante', 41.162203, -8.642465);
insert into item values (31, 'Placa de "não pisar a relva"', 'Nos jardins de fora', 39.353941, -9.380222);
insert into item values (32, 'Placa de aviso', 'Junto da casa de banho', 37.294707, -8.865825);
insert into item values (33, 'Placar de cortiça', 'Junto ao gabinete do vice-presidente', 37.090107, -8.245698);
insert into item values (34, 'Placa de "não pisar a relva"', 'Nos jardins de fora', 39.353941, -9.380222);
insert into item values (35, 'Placar de cortiça', 'Junto ao gabinete do vice-presidente', 37.090107, -8.245698);
insert into item values (36, 'Placa de aviso', 'À entrada para os balneários', 37.124397, -8.242660);
insert into item values (37, 'Placa com avisos gerais', 'Na porta da secção visitante', 41.162203, -8.642465);
insert into item values (38, 'Aviso de saída de viaturas', 'À direita da entrada de veículos', 41.279030, -8.378315);
insert into item values (39, 'Placa com avisos gerais', 'Na porta da secção visitante', 41.162203, -8.642465);
insert into item values (40, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (41, 'Placa de "não tocar"', 'À entrada do jardim, à direita', 40.659928, -7.911064);
insert into item values (42, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (43, 'Aviso de chão molhado', 'Átrio principal', 39.658880, -8.825509);
insert into item values (44, 'Aviso de radiação', 'Junto à sala 5 de TACs', 40.224916, -8.423367);
insert into item values (45, 'Aviso de saída de viaturas', 'À direita da entrada de veículos', 41.279030, -8.378315);
insert into item values (46, 'Publicidade de promoção', 'Junto aos sapatos', 38.679623, -9.333943);
insert into item values (47, 'Placa com descrição de procedimentos', 'Na cozinha da cantina, por cima do lava-louças', 37.805280, -7.498860);

/* UTILIZADOR */
insert into utilizador values ('ggwp420@example.com', 'PrqpROliOb', 'R');
insert into utilizador values ('my.email.creative@example.com', 'HLW6bh6CiP', 'R');
insert into utilizador values ('somename123@example.com', '2XVMYM0V4O', 'R');
insert into utilizador values ('would.smash@example.com', 'lrK3vE6Uzl', 'R');
insert into utilizador values ('bigtidepod@example.com', '0RgDxiLMYR', 'Q');
insert into utilizador values ('elon.musk@example.com', 'rhx6xDAzW9', 'Q');
insert into utilizador values ('filipe@example.com', 'WxcFdxrLJc', 'Q');
insert into utilizador values ('halabadudies@example.com', 'W58Yok6mkG', 'Q');
insert into utilizador values ('headspace@example.com', 'MGAApbQPOf', 'Q');
insert into utilizador values ('hello_world@example.com', 'ocGpJ6zz3M', 'Q');
insert into utilizador values ('qwertyuiop@example.com', 'anP4k1Xzxj', 'Q');
insert into utilizador values ('slide.away1994@example.com', 'gzpKPQDint', 'Q');
insert into utilizador values ('something_ol@example.com', 'LQsEThPIuo', 'Q');
insert into utilizador values ('tiny.violin.10@example.com', '1tZMvKrtaG', 'Q');
insert into utilizador values ('topkek@example.com', '1gjhYvrubW', 'Q');
insert into utilizador values ('mumimadeit@example.com', 'lrK3vE6Uzl', 'Q');

/* UTILIZADOR_REGULAR */
/*insert into utilizador_regular values ('ggwp420@example.com');
insert into utilizador_regular values ('my.email.creative@example.com');
insert into utilizador_regular values ('somename123@example.com');
insert into utilizador_regular values ('would.smash@example.com');*/

/* UTILIZADOR_QUALIFICADO */
/*insert into utilizador_qualificado values ('bigtidepod@example.com');
insert into utilizador_qualificado values ('elon.musk@example.com');
insert into utilizador_qualificado values ('filipe@example.com');
insert into utilizador_qualificado values ('halabadudies@example.com');
insert into utilizador_qualificado values ('headspace@example.com');
insert into utilizador_qualificado values ('hello_world@example.com');
insert into utilizador_qualificado values ('qwertyuiop@example.com');
insert into utilizador_qualificado values ('slide.away1994@example.com');
insert into utilizador_qualificado values ('something_ol@example.com');
insert into utilizador_qualificado values ('tiny.violin.10@example.com');
insert into utilizador_qualificado values ('topkek@example.com');
insert into utilizador_qualificado values ('mumimadeit@example.com');*/

/* ANOMALIA */
insert into anomalia values (0, '((6, 11), (57, 209))', 'images/0.jpg', 'português', '2019-06-14 20:43:45', 'Falta um acento na palavra "contem"', TRUE);
insert into anomalia values (3, '((87, 175), (66, 286))', 'images/3.jpg', 'português', '2019-09-01 12:44:55', 'Devia ter uma vírgula antes de "logo"', TRUE);
insert into anomalia values (4, '((215, 29), (230, 123))', 'images/4.jpg', 'português', '2019-06-24 18:40:20', '"Parar" devia estar no conjutivo', TRUE);
insert into anomalia values (6, '((501, 179), (99, 197))', 'images/6.jpg', 'português', '2019-01-21 02:42:05', '"Hoje" está repetido duas vezes', TRUE);
insert into anomalia values (7, '((458, 270), (322, 189))', 'images/7.jpg', 'inglês', '2019-10-19 00:16:15', 'Faltou usar o pronome "lhe"', TRUE);
insert into anomalia values (12, '((107, 16), (328, 228))', 'images/12.jpg', 'português', '2019-09-30 18:48:19', '"Nao" não tem o til', TRUE);
insert into anomalia values (10, '((410, 93), (168, 20))', 'images/10.jpg', 'português', '2019-04-20 00:28:30', 'Falta o hífen em "passase"', TRUE);
insert into anomalia values (16, '((310, 354), (483, 245))', 'images/16.jpg', 'inglês', '2019-11-09 08:01:14', 'Não tem ponto final', TRUE);
insert into anomalia values (18, '((11, 14), (488, 137))', 'images/18.jpg', 'português', '2019-04-02 00:07:38', 'Frase não começa com letra maiúscula', TRUE);
insert into anomalia values (20, '((325, 22), (420, 233))', 'images/20.jpg', 'português', '2019-03-13 15:08:00', '"joão" não começa com letra maiúscula', TRUE);
insert into anomalia values (23, '((35, 218), (185, 0))', 'images/23.jpg', 'português', '2019-05-02 13:31:57', '"Ontem" não pode começar com letra maiúscula', TRUE);
insert into anomalia values (24, '((382, 317), (375, 221))', 'images/24.jpg', 'inglês', '2019-08-19 20:22:30', '"carros" tem de estar no singular', TRUE);
insert into anomalia values (25, '((401, 68), (370, 0))', 'images/25.jpg', 'português', '2019-12-01 13:38:07', 'Falta acento circunflexo em "robo"', TRUE);
insert into anomalia values (26, '((358, 70), (408, 256))', 'images/26.jpg', 'português', '2019-08-17 15:50:42', '"Usa-se" devia ser usasse', TRUE);
insert into anomalia values (29, '((368, 128), (489, 161))', 'images/29.jpg', 'português', '2019-10-21 12:35:03', 'Falta acento em "balneario"', TRUE);
insert into anomalia values (31, '((501, 121), (168, 72))', 'images/31.jpg', 'português', '2019-11-20 19:59:37', 'Frase acaba com dois pontos finais em vez de um', TRUE);

insert into anomalia values (1, '((310, 134), (442, 167))', 'images/1.jpg', 'português', '2019-06-24 18:40:20', '"Helo" deve ser "Hello"', FALSE);
insert into anomalia values (2, '((72, 133), (302, 103))', 'images/2.jpg', 'inglês', '2019-03-13 15:08:00', '"Everywhere" quer dizer em todo o lado', FALSE);
insert into anomalia values (5, '((43, 97), (99, 158))', 'images/5.jpg', 'inglês', '2019-11-20 19:59:37', '"Last night" está mal traduzido', FALSE);
insert into anomalia values (8, '((30, 120), (507, 158))', 'images/8.jpg', 'português', '2019-06-14 20:43:45', '"cão" devia ser "dog"', FALSE);
insert into anomalia values (9, '((152, 121), (151, 16))', 'images/9.jpg', 'inglês', '2019-08-19 20:22:30', '"cat" devia ser "gato"', FALSE);
insert into anomalia values (11, '((336, 154), (98, 43))', 'images/11.jpg', 'português', '2019-01-21 02:42:05', '"Pescoço" deve ser "cu"', FALSE);
insert into anomalia values (13, '((179, 142), (388, 82))', 'images/13.jpg', 'inglês', '2019-10-19 00:16:15', '"Twice" deve ser "duas vezes"', FALSE);
insert into anomalia values (14, '((354, 85), (293, 116))', 'images/14.jpg', 'português', '2019-09-30 18:48:19', '"qualidade" está mal traduzido', FALSE);
insert into anomalia values (15, '((12, 56), (148, 2))', 'images/15.jpg', 'português', '2019-04-02 00:07:38', '"alface" está mal traduzido', FALSE);
insert into anomalia values (17, '((115, 9), (289, 50))', 'images/17.jpg', 'português', '2019-05-02 13:31:57', '"rio" está mal traduzido', FALSE);
insert into anomalia values (19, '((192, 73), (179, 148))', 'images/19.jpg', 'inglês', '2019-09-01 12:44:55', '"kitchen" está mal traduzido', FALSE);
insert into anomalia values (21, '((424, 113), (486, 164))', 'images/21.jpg', 'português', '2019-12-01 13:38:07', '"segunda" está mal traduzido', FALSE);
insert into anomalia values (22, '((441, 125), (483, 41))', 'images/22.jpg', 'português', '2019-04-20 00:28:30', '"armário" está mal traduzido', FALSE);
insert into anomalia values (27, '((70, 143), (175, 93))', 'images/27.jpg', 'português', '2019-10-21 12:35:03', '""depois" está mal traduzido', FALSE);
insert into anomalia values (28, '((228, 73), (96, 116))', 'images/28.jpg', 'inglês', '2019-11-09 08:01:14', '"after" está mal traduzido', FALSE);
insert into anomalia values (30, '((386, 25), (406, 78))', 'images/30.jpg', 'português', '2019-08-17 15:50:42', '"colégio" está mal traduzido', FALSE);

/* ANOMALIA_TRADUCAO */
insert into anomalia_traducao values (1, '((438, 322), (203, 244))', 'inglês');
insert into anomalia_traducao values (2, '((306, 349), (239, 313))', 'português');
insert into anomalia_traducao values (5, '((431, 190), (326, 277))', 'português');
insert into anomalia_traducao values (8, '((359, 207), (373, 332))', 'inglês');
insert into anomalia_traducao values (9, '((302, 281), (147, 323))', 'português');
insert into anomalia_traducao values (11, '((1, 220), (526, 203))', 'francês');
insert into anomalia_traducao values (13, '((93, 239), (219, 221))', 'português');
insert into anomalia_traducao values (14, '((29, 203), (536, 241))', 'alemão');
insert into anomalia_traducao values (15, '((382, 276), (310, 260))', 'inglês');
insert into anomalia_traducao values (17, '((234, 351), (210, 223))', 'francês');
insert into anomalia_traducao values (19, '((110, 336), (408, 310))', 'português');
insert into anomalia_traducao values (21, '((28, 344), (344, 220))', 'chinês');
insert into anomalia_traducao values (22, '((431, 326), (78, 200))', 'inglês');
insert into anomalia_traducao values (27, '((449, 260), (214, 293))', 'espanhol');
insert into anomalia_traducao values (28, '((189, 307), (20, 183))', 'português');
insert into anomalia_traducao values (30, '((150, 234), (234, 211))', 'francês');

/* INCIDENCIA */
insert into incidencia values (15, 10, 'tiny.violin.10@example.com');
insert into incidencia values (25, 6, 'hello_world@example.com');
insert into incidencia values (11, 0, 'filipe@example.com');
insert into incidencia values (21, 8, 'tiny.violin.10@example.com');
insert into incidencia values (18, 2, 'hello_world@example.com');
insert into incidencia values (13, 7, 'tiny.violin.10@example.com');
insert into incidencia values (7, 15, 'slide.away1994@example.com');
insert into incidencia values (14, 2, 'ggwp420@example.com');
insert into incidencia values (22, 1, 'headspace@example.com');
insert into incidencia values (2, 14, 'mumimadeit@example.com');
insert into incidencia values (4, 10, 'ggwp420@example.com');
insert into incidencia values (3, 14, 'topkek@example.com');
insert into incidencia values (5, 6, 'somename123@example.com');
insert into incidencia values (0, 7, 'somename123@example.com');
insert into incidencia values (28, 6, 'bigtidepod@example.com');
insert into incidencia values (29, 12, 'my.email.creative@example.com');
insert into incidencia values (8, 0, 'would.smash@example.com');
insert into incidencia values (24, 3, 'filipe@example.com');
insert into incidencia values (30, 3, 'filipe@example.com');
insert into incidencia values (6, 10, 'topkek@example.com');
insert into incidencia values (9, 15, 'my.email.creative@example.com');
insert into incidencia values (27, 1, 'elon.musk@example.com');
insert into incidencia values (23, 10, 'qwertyuiop@example.com');
insert into incidencia values (19, 10, 'my.email.creative@example.com');
insert into incidencia values (16, 11, 'somename123@example.com');
insert into incidencia values (17, 4, 'bigtidepod@example.com');
insert into incidencia values (10, 6, 'qwertyuiop@example.com');
insert into incidencia values (1, 5, 'filipe@example.com');
insert into incidencia values (12, 14, 'slide.away1994@example.com');
insert into incidencia values (20, 12, 'elon.musk@example.com');
insert into incidencia values (31, 2, 'something_ol@example.com');
insert into incidencia values (26, 5, 'filipe@example.com');

insert into proposta_de_correcao values (0, 'mumimadeit@example.com', '2019-06-15 20:43:45', 'Meter acento na palavra "contem"');
insert into proposta_de_correcao values (1, 'mumimadeit@example.com', '2019-09-02 12:44:55', 'Meter vírgula antes de "logo"');
insert into proposta_de_correcao values (2, 'filipe@example.com', '2019-06-25 18:40:20', '"Parar" passa a parasse');
insert into proposta_de_correcao values (3, 'headspace@example.com', '2019-01-22 02:42:05', 'Escrever hoje só uma vez');
insert into proposta_de_correcao values (4, 'bigtidepod@example.com', '2019-10-20 00:16:15','Colocar lhe na frase');
insert into proposta_de_correcao values (5, 'qwertyuiop@example.com', '2019-09-30 19:48:19', 'Passar para não');
insert into proposta_de_correcao values (6, 'elon.musk@example.com', '2019-04-21 00:28:30', 'passa-se');
insert into proposta_de_correcao values (7, 'elon.musk@example.com', '2019-11-10 08:01:14', 'Colocar ponto final');
insert into proposta_de_correcao values (8, 'qwertyuiop@example.com', '2019-04-03 00:07:38', 'Começar com letra maiúscula');
insert into proposta_de_correcao values (9, 'topkek@example.com', '2019-03-14 15:08:00', 'João');
insert into proposta_de_correcao values (10, 'headspace@example.com', '2019-05-03 13:31:57', 'ontem');
insert into proposta_de_correcao values (11, 'filipe@example.com', '2019-08-20 20:22:30', 'carro');
insert into proposta_de_correcao values (12, 'mumimadeit@example.com', '2019-12-02 13:38:07', 'robô');
insert into proposta_de_correcao values (13, 'slide.away1994@example.com', '2019-08-18 15:50:42', 'usasse');
insert into proposta_de_correcao values (14, 'mumimadeit@example.com', '2019-10-22 12:35:03', 'balneário');
insert into proposta_de_correcao values (15, 'something_ol@example.com', '2019-11-21 19:59:37', 'Acabar só com um ponto final');

insert into proposta_de_correcao values (16, 'filipe@example.com', '2019-06-25 18:40:20', 'Hello');
insert into proposta_de_correcao values (17, 'hello_world@example.com', '2019-03-14 15:08:00', 'Nowhere');
insert into proposta_de_correcao values (18, 'elon.musk@example.com', '2019-11-21 19:59:37', 'Ontem á noite');
insert into proposta_de_correcao values (19, 'tiny.violin.10@example.com', '2019-06-15 20:43:45', 'dog');
insert into proposta_de_correcao values (20, 'bigtidepod@example.com', '2019-08-20 20:22:30', 'gato');
insert into proposta_de_correcao values (21, 'topkek@example.com', '2019-01-22 02:42:05', 'cu');
insert into proposta_de_correcao values (22, 'qwertyuiop@example.com', '2019-10-20 00:16:15', 'duas vezes');
insert into proposta_de_correcao values (23, 'hello_world@example.com', '2019-09-30 19:48:19', 'quality');
insert into proposta_de_correcao values (24, 'halabadudies@example.com', '2019-04-03 00:07:38', 'lettuce');
insert into proposta_de_correcao values (25, 'halabadudies@example.com', '2019-05-03 13:31:57', 'river');
insert into proposta_de_correcao values (26, 'mumimadeit@example.com', '2019-09-02 12:44:55', 'cozinha');
insert into proposta_de_correcao values (27, 'bigtidepod@example.com', '2019-12-02 13:38:07', 'second');
insert into proposta_de_correcao values (28, 'filipe@example.com', '2019-04-21 00:28:30', 'closet');
insert into proposta_de_correcao values (29, 'mumimadeit@example.com', '2019-10-22 12:35:03', 'after');
insert into proposta_de_correcao values (30, 'topkek@example.com', '2019-11-10 08:01:14', 'depois');
insert into proposta_de_correcao values (31, 'headspace@example.com', '2019-08-18 15:50:42', 'private school');

insert into correcao values (0, 'mumimadeit@example.com', 0);
insert into correcao values (1, 'mumimadeit@example.com', 3);
insert into correcao values (2, 'filipe@example.com', 4);
insert into correcao values (3, 'headspace@example.com', 6);
insert into correcao values (4, 'bigtidepod@example.com', 7);
insert into correcao values (5, 'qwertyuiop@example.com', 12);
insert into correcao values (6, 'elon.musk@example.com', 10);
insert into correcao values (7, 'elon.musk@example.com', 16);
insert into correcao values (8, 'qwertyuiop@example.com', 18);
insert into correcao values (9, 'topkek@example.com', 20);
insert into correcao values (10, 'headspace@example.com', 23);
insert into correcao values (11, 'filipe@example.com', 24);
insert into correcao values (12, 'mumimadeit@example.com', 25);
insert into correcao values (13, 'slide.away1994@example.com', 26);
insert into correcao values (14, 'mumimadeit@example.com', 29);
insert into correcao values (15, 'something_ol@example.com', 31);
insert into correcao values (16, 'filipe@example.com', 1);
insert into correcao values (17, 'hello_world@example.com', 2);
insert into correcao values (18, 'elon.musk@example.com', 5);
insert into correcao values (19, 'tiny.violin.10@example.com', 8);
insert into correcao values (20, 'bigtidepod@example.com', 9);
insert into correcao values (21, 'topkek@example.com', 11);
insert into correcao values (22, 'qwertyuiop@example.com', 13);
insert into correcao values (23, 'hello_world@example.com', 14);
insert into correcao values (24, 'halabadudies@example.com', 15);
insert into correcao values (25, 'halabadudies@example.com', 17);
insert into correcao values (26, 'mumimadeit@example.com', 19);
insert into correcao values (27, 'bigtidepod@example.com', 21);
insert into correcao values (28, 'filipe@example.com', 22);
insert into correcao values (29, 'mumimadeit@example.com', 27);
insert into correcao values (30, 'topkek@example.com', 28);
insert into correcao values (31, 'headspace@example.com', 30);