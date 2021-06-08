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

create unique index coordenadas on local_publico(latitude, longitude);

create table item (
    item_id int not null unique,
    descricao text not null,
    /* localizacao ????? */
    latitude numeric(8,6) not null,
    longitude numeric(9,6) not null,
    constraint pk_item primary key (item_id),
    constraint fk_item_coordenadas foreign key (latitude, longitude) references local_publico(latitude, longitude)
);

create table anomalia (
    anomalia_id int not null unique,
    zona box not null,
    imagem bytea not null,
    lingua varchar(25) not null,
    ts timestamp not null,
    descricao text not null,
    tem_anomalia_redacao boolean not null,
    constraint pk_anomalia primary key (anomalia_id)
);

create table anomalia_traducao (
    anomalia_id int not null unique,
    zona2 box not null,
    lingua2 varchar(25) not null,
    constraint pk_anomalia_traducao primary key (anomalia_id),
    constraint fk_anomalia_traducao_id foreign key (anomalia_id) references anomalia(anomalia_id)
);

create table duplicado (
    item1_id int not null unique,
    item2_id int not null unique,
    constraint pk_duplicado primary key (item1_id, item2_id),
    constraint fk_duplicado_item1_id foreign key (item1_id) references item(item_id),
    constraint fk_duplicado_item2_id foreign key (item2_id) references item(item_id),
    constraint RI3 check (item1_id < item2_id) /* se fazemos duplicado (2,1), ele aborta ou reordena para (1, 2)? */
);

create table utilizador (
    email varchar(255) not null unique,
    password varchar(255) not null,
    constraint pk_utilizador primary key (email)
);

create table utilizador_qualificado (
    email varchar(255) not null unique,
    constraint fk_utilizador_qualificado_email foreign key (email) references utilizador(email),
    constraint pk_utilizador_qualificado primary key (email)
);

create table utilizador_regular (
    email varchar(255) not null unique,
    constraint fk_utilizador_regular_email foreign key (email) references utilizador(email),
    constraint pk_utilizador_regular primary key (email)
);

create table incidencia (
    anomalia_id int not null unique,
    item_id int not null,
    email varchar(255) not null,
    constraint pk_incidencia primary key (anomalia_id),
    constraint fk_incidencia_anomalia_id foreign key (anomalia_id) references anomalia(anomalia_id),
    constraint fk_incidencia_item_id foreign key (item_id) references item(item_id),
    constraint fk_incidencia_email foreign key (email) references utilizador(email)
);

create table proposta_de_correcao (
    email varchar(255) not null unique,
    nro int not null unique,
    data_hora timestamp not null,
    texto text not null,
    constraint pk_proposta_de_correcao primary key (email, nro),
    constraint fk_proposta_de_correcao foreign key (email) references utilizador_qualificado(email)
);

create table correcao (
    email varchar(255) not null,
    nro int not null,
    anomalia_id int not null,
    constraint pk_correcao primary key (email, nro, anomalia_id),
    constraint fk_correcao_email foreign key (email) references proposta_de_correcao(email),
    constraint fk_correcao_nro foreign key (nro) references proposta_de_correcao(nro),
    constraint fk_correcao_anomalia_id foreign key (anomalia_id) references incidencia(anomalia_id)
);

/* ------------------------------------------------------------------ */
/*                             FUNCTIONS                              */
/* ------------------------------------------------------------------ */
create or replace function doCheck()
    returns trigger as
$BODY$
begin
    if TG_TABLE_NAME = 'utilizador_qualificado' and
        exists(select 1 from utilizador_regular as ur where new.email = ur.email) then
        raise exception 'Erro a inserir utilizador_qualificado: key "%" já existe em utilizador_regular', new.email;
    end if;

    if TG_TABLE_NAME = 'utilizador_regular' and
        exists(select 1 from utilizador_qualificado as ur where new.email = ur.email) then
        raise exception 'Erro a inserir utilizador_regular: key "%" já existe em utilizador_qualificado', new.email;
    end if;
    
    return new;

end;
$BODY$
LANGUAGE plpgsql;

/* ------------------------------------------------------------------ */
/*                              TRIGGERS                              */
/* ------------------------------------------------------------------ */
/* enforces RI5 (email can't be present on utilizador_regular) */
create trigger check_utilizador_qualificado
    before insert on utilizador_qualificado
    for each row
    execute procedure doCheck();

/* enforces RI6 (email can't be present on utilizador_qualificado) */
create trigger check_utilizador_regular
    before insert on utilizador_regular
    for each row
    execute procedure doCheck();

/* ------------------------------------------------------------------ */
/*                              INSERTS                               */
/* ------------------------------------------------------------------ */
