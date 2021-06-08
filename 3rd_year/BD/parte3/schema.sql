/* ------------------------------------------------------------------ */
/*                       BASES DE DADOS 2019/20                       */
/*                          PROJETO, PARTE 3                          */
/*                             schema.sql                             */
/*                                                                    */
/*                             GRUPO TP20                             */
/*                        JOANA MENDONCA, 83597                       */
/*                        GONCALO GUERRA, 83899                       */
/*                        FILIPE COLACO, 84715                        */
/* ------------------------------------------------------------------ */

drop table local_publico cascade;
drop table item cascade;
drop table anomalia cascade;
drop table anomalia_traducao cascade;
drop table duplicado cascade;
drop table utilizador cascade;
drop table utilizador_qualificado cascade;
drop table utilizador_regular cascade;
drop table incidencia cascade;
drop table proposta_de_correcao cascade;
drop table correcao cascade;

/* ------------------------------------------------------------------ */
/*                               TABLES                               */
/* ------------------------------------------------------------------ */
create table local_publico (
    latitude numeric(8,6) not null,
    longitude numeric(9,6) not null,
    nome varchar(80) not null,
    constraint pk_local_publico primary key (latitude, longitude)
);

--create unique index coordenadas on local_publico(latitude, longitude);

create table item (
    item_id int not null unique,
    item_descricao text not null,
    localizacao text not null,
    latitude numeric(8,6) not null,
    longitude numeric(9,6) not null,
    constraint pk_item primary key (item_id),
    constraint fk_item_coordenadas foreign key (latitude, longitude) references local_publico(latitude, longitude) on delete cascade
);

create table anomalia (
    anomalia_id int not null unique,
    zona box not null,
    imagem text not null,
    lingua varchar(25) not null,
    ts timestamp not null,
    anomalia_descricao text not null,
    tem_anomalia_redacao boolean not null,
    constraint pk_anomalia primary key (anomalia_id)
);

create table anomalia_traducao (
    anomalia_id int not null unique,
    zona2 box not null,
    lingua2 varchar(25) not null,
    constraint pk_anomalia_traducao primary key (anomalia_id),
    constraint fk_anomalia_traducao_id foreign key (anomalia_id) references anomalia(anomalia_id) on delete cascade
);

create table duplicado (
    item1_id int not null unique,
    item2_id int not null unique,
    constraint pk_duplicado primary key (item1_id, item2_id),
    constraint fk_duplicado_item1_id foreign key (item1_id) references item(item_id) on delete cascade,
    constraint fk_duplicado_item2_id foreign key (item2_id) references item(item_id) on delete cascade,
    constraint RI3 check (item1_id < item2_id)
);

create table utilizador (
    email varchar(255) not null unique,
    password varchar(255) not null,
    type char(1) not null,
    constraint pk_utilizador primary key (email)
);

create unique index uuk on utilizador(email, type);

create table utilizador_qualificado (
    email varchar(255) not null,
    type char(1) default 'Q',
    constraint fk_utilizador_qualificado_uuk foreign key (email, type) references utilizador(email, type) on delete cascade,
    constraint pk_utilizador_qualificado primary key (email)
);

create table utilizador_regular (
    email varchar(255) not null,
    type char(1) default 'R',
    constraint fk_utilizador_regular_uuk foreign key (email, type) references utilizador(email, type) on delete cascade,
    constraint pk_utilizador_regular primary key (email)
);

create table incidencia (
    anomalia_id int not null unique,
    item_id int not null,
    incidencia_email varchar(255) not null,
    constraint pk_incidencia primary key (anomalia_id),
    constraint fk_incidencia_anomalia_id foreign key (anomalia_id) references anomalia(anomalia_id) on delete cascade,
    constraint fk_incidencia_item_id foreign key (item_id) references item(item_id) on delete cascade,
    constraint fk_incidencia_email foreign key (incidencia_email) references utilizador(email) on delete cascade
);

create table proposta_de_correcao (
    nro int not null unique,
    pdc_email varchar(255) not null,
    data_hora timestamp not null,
    texto text not null,
    constraint pk_proposta_de_correcao primary key (nro, pdc_email),
    constraint fk_proposta_de_correcao foreign key (pdc_email) references utilizador_qualificado(email) on delete cascade
);

create unique index pdcuk on proposta_de_correcao(nro, pdc_email);

create table correcao (
    nro int not null,
    pdc_email varchar(255) not null,
    anomalia_id int not null,
    constraint pk_correcao primary key (pdc_email, nro, anomalia_id),
    constraint fk_correcao_pdcuk foreign key (nro, pdc_email) references proposta_de_correcao(nro, pdc_email) on delete cascade,
    constraint fk_correcao_anomalia_id foreign key (anomalia_id) references incidencia(anomalia_id) on delete cascade
);