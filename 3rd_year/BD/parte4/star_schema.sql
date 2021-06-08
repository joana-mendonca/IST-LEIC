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

drop table if exists d_utilizador cascade;
drop table if exists d_tempo cascade;
drop table if exists d_local cascade;
drop table if exists d_lingua cascade;
drop table if exists f_anomalia cascade;

create table d_utilizador (
    id_utilizador serial not null unique,
    email varchar(255) not null unique,
    type char(1) not null
);

create table d_tempo (
    id_tempo serial not null unique,
    dia int not null,
    dia_da_semana varchar(9) not null,
    semana int not null,
    mes int not null,
    trimestre int not null,
    ano int not null
);

create table d_local (
    id_local serial not null unique,
    latitude numeric(8,6) not null,
    longitude numeric(9,6) not null,
    nome varchar(255) not null
);

create table d_lingua (
    id_lingua serial not null unique,
    lingua varchar(255) not null
);  

create table f_anomalia (
    id_utilizador int not null,
    id_tempo int not null,
    id_local int not null,
    id_lingua int not null,
    tipo_anomalia varchar(255) not null,
    com_proposta boolean not null
);
create index idx_f_anomalia ON f_anomalia(id_utilizador, id_tempo, id_local, id_lingua);

/* ------------------------------------------------------------------ */
/*                               INSERTS                              */
/* ------------------------------------------------------------------ */
/* transfers rows from utilizador to d_utilizador */
create or replace function insertUtilizadores()
    returns void as
$BODY$
declare
    t_row utilizador;
begin
    for t_row in (select * from utilizador) loop
        insert into d_utilizador values (default,t_row.email, t_row.type);
    end loop;
end;
$BODY$
LANGUAGE plpgsql;

/* transfers rows from local_publico to d_local */
create or replace function insertLocais()
    returns void as
$BODY$
declare
    t_row local_publico;
begin
    for t_row in (select * from local_publico) loop
        insert into d_local values (default, t_row.latitude, t_row.longitude, t_row.nome);
    end loop;
end;
$BODY$
LANGUAGE plpgsql;

/* transfers rows from anomalia+incidencia to f_anomalia */
create or replace function insertAnomalias()
    returns void as
$BODY$
declare
    t_row record;
    v_user d_utilizador;
    v_tempo d_tempo;
    v_local d_local;
    v_lingua d_lingua;
    v_proposta bool;
    v_tipo varchar;
begin
    for t_row in (select * from anomalia natural join incidencia natural join item natural join local_publico) loop
        select id_utilizador from d_utilizador where email = t_row.incidencia_email into v_user;
        select id_tempo from d_tempo where dia = extract(day from t_row.ts) and mes = extract(month from t_row.ts) and ano = extract(year from t_row.ts) into v_tempo;
        select id_local from d_local where nome = t_row.nome into v_local;
        select id_lingua from d_lingua where lingua = t_row.lingua into v_lingua;

        /* ver de que tipo é a anomalia */
        if t_row.tem_anomalia_redacao = FALSE then v_tipo := 'traducao';
        else v_tipo := 'redacao';
        end if;

        /* ver se tem uma proposta de correção */
        if exists(select 1 from correcao where correcao.anomalia_id = t_row.anomalia_id) then v_proposta := TRUE;
        else v_proposta := FALSE;
        end if;

        insert into f_anomalia values (v_user.id_utilizador, v_tempo.id_tempo, v_local.id_local, v_lingua.id_lingua, v_tipo, v_proposta);
    end loop;
end;
$BODY$
LANGUAGE plpgsql;

insert into d_lingua values (default,'akan'),(default,'alemão'),(default,'amárica'),(default,'assamês'),(default,'awadhi'),(default,'azeri'),(default,'balúchi'),(default,'bengali'),(default,'bhojpuri'),(default,'bielorrusso'),(default,'birmanês'),(default,'canarês'),(default,'cantonês'),(default,'cazaque'),(default,'cebuano'),(default,'chatgaya'),(default,'checo'),(default,'chhattisgarhi'),(default,'chona'),(default,'cingalês'),(default,'cinianja'),(default,'concani'),(default,'coreano'),(default,'crioulo haitiano'),(default,'curdo'),(default,'deccani'),(default,'dhundhari'),(default,'espanhol'),(default,'francês'),(default,'fulani'),(default,'gan'),(default,'grego'),(default,'guzerate'),(default,'hakka'),(default,'hariani'),(default,'haúça'),(default,'hiligaynon'),(default,'hindi'),(default,'hmong'),(default,'holandês'),(default,'húngaro'),(default,'igbo'),(default,'ilocano'),(default,'inglês'),(default,'iorubá'),(default,'italiano'),(default,'japonês'),(default,'javanês'),(default,'jin'),(default,'khmer'),(default,'kirundi'),(default,'madurês'),(default,'magahi'),(default,'maithili'),(default,'malaiala'),(default,'malaio'),(default,'malgaxe'),(default,'mandarim'),(default,'marati'),(default,'marvari'),(default,'min bei'),(default,'min dong'),(default,'min nan'),(default,'more'),(default,'nepalês'),(default,'oriá'),(default,'oromo'),(default,'panjabi'),(default,'pastó'),(default,'persa'),(default,'polaco'),(default,'português'),(default,'quiniaruanda'),(default,'quíchua'),(default,'romeno'),(default,'russo'),(default,'seraiki'),(default,'serbo-croata'),(default,'sindi'),(default,'somali'),(default,'sueco'),(default,'sundanês'),(default,'sylheti'),(default,'tagalo'),(default,'tailandês'),(default,'telugo'),(default,'turco'),(default,'turcomano'),(default,'tâmil'),(default,'ucraniano'),(default,'uigur'),(default,'urdu'),(default,'usbeque'),(default,'vietnamita'),(default,'xangainês'),(default,'xhosa'),(default,'xiang'),(default,'zhuang'),(default,'zulu'),(default,'árabe');
insert into d_tempo values (default,1,'Tuesday',01,1,1,2019),(default,2,'Wednesday',01,1,1,2019),(default,3,'Thursday',01,1,1,2019),(default,4,'Friday',01,1,1,2019),(default,5,'Saturday',01,1,1,2019),(default,6,'Sunday',01,1,1,2019),(default,7,'Monday',02,1,1,2019),(default,8,'Tuesday',02,1,1,2019),(default,9,'Wednesday',02,1,1,2019),(default,10,'Thursday',02,1,1,2019),(default,11,'Friday',02,1,1,2019),(default,12,'Saturday',02,1,1,2019),(default,13,'Sunday',02,1,1,2019),(default,14,'Monday',03,1,1,2019),(default,15,'Tuesday',03,1,1,2019),(default,16,'Wednesday',03,1,1,2019),(default,17,'Thursday',03,1,1,2019),(default,18,'Friday',03,1,1,2019),(default,19,'Saturday',03,1,1,2019),(default,20,'Sunday',03,1,1,2019),(default,21,'Monday',04,1,1,2019),(default,22,'Tuesday',04,1,1,2019),(default,23,'Wednesday',04,1,1,2019),(default,24,'Thursday',04,1,1,2019),(default,25,'Friday',04,1,1,2019),(default,26,'Saturday',04,1,1,2019),(default,27,'Sunday',04,1,1,2019),(default,28,'Monday',05,1,1,2019),(default,29,'Tuesday',05,1,1,2019),(default,30,'Wednesday',05,1,1,2019),(default,31,'Thursday',05,1,1,2019),(default,1,'Friday',05,2,1,2019),(default,2,'Saturday',05,2,1,2019),(default,3,'Sunday',05,2,1,2019),(default,4,'Monday',06,2,1,2019),(default,5,'Tuesday',06,2,1,2019),(default,6,'Wednesday',06,2,1,2019),(default,7,'Thursday',06,2,1,2019),(default,8,'Friday',06,2,1,2019),(default,9,'Saturday',06,2,1,2019),(default,10,'Sunday',06,2,1,2019),(default,11,'Monday',07,2,1,2019),(default,12,'Tuesday',07,2,1,2019),(default,13,'Wednesday',07,2,1,2019),(default,14,'Thursday',07,2,1,2019),(default,15,'Friday',07,2,1,2019),(default,16,'Saturday',07,2,1,2019),(default,17,'Sunday',07,2,1,2019),(default,18,'Monday',08,2,1,2019),(default,19,'Tuesday',08,2,1,2019),(default,20,'Wednesday',08,2,1,2019),(default,21,'Thursday',08,2,1,2019),(default,22,'Friday',08,2,1,2019),(default,23,'Saturday',08,2,1,2019),(default,24,'Sunday',08,2,1,2019),(default,25,'Monday',09,2,1,2019),(default,26,'Tuesday',09,2,1,2019),(default,27,'Wednesday',09,2,1,2019),(default,28,'Thursday',09,2,1,2019),(default,1,'Friday',09,3,1,2019),(default,2,'Saturday',09,3,1,2019),(default,3,'Sunday',09,3,1,2019),(default,4,'Monday',10,3,1,2019),(default,5,'Tuesday',10,3,1,2019),(default,6,'Wednesday',10,3,1,2019),(default,7,'Thursday',10,3,1,2019),(default,8,'Friday',10,3,1,2019),(default,9,'Saturday',10,3,1,2019),(default,10,'Sunday',10,3,1,2019),(default,11,'Monday',11,3,1,2019),(default,12,'Tuesday',11,3,1,2019),(default,13,'Wednesday',11,3,1,2019),(default,14,'Thursday',11,3,1,2019),(default,15,'Friday',11,3,1,2019),(default,16,'Saturday',11,3,1,2019),(default,17,'Sunday',11,3,1,2019),(default,18,'Monday',12,3,1,2019),(default,19,'Tuesday',12,3,1,2019),(default,20,'Wednesday',12,3,1,2019),(default,21,'Thursday',12,3,1,2019),(default,22,'Friday',12,3,1,2019),(default,23,'Saturday',12,3,1,2019),(default,24,'Sunday',12,3,1,2019),(default,25,'Monday',13,3,1,2019),(default,26,'Tuesday',13,3,1,2019),(default,27,'Wednesday',13,3,1,2019),(default,28,'Thursday',13,3,1,2019),(default,29,'Friday',13,3,1,2019),(default,30,'Saturday',13,3,1,2019),(default,31,'Sunday',13,3,1,2019),(default,1,'Monday',14,4,2,2019),(default,2,'Tuesday',14,4,2,2019),(default,3,'Wednesday',14,4,2,2019),(default,4,'Thursday',14,4,2,2019),(default,5,'Friday',14,4,2,2019),(default,6,'Saturday',14,4,2,2019),(default,7,'Sunday',14,4,2,2019),(default,8,'Monday',15,4,2,2019),(default,9,'Tuesday',15,4,2,2019),(default,10,'Wednesday',15,4,2,2019),(default,11,'Thursday',15,4,2,2019),(default,12,'Friday',15,4,2,2019),(default,13,'Saturday',15,4,2,2019),(default,14,'Sunday',15,4,2,2019),(default,15,'Monday',16,4,2,2019),(default,16,'Tuesday',16,4,2,2019),(default,17,'Wednesday',16,4,2,2019),(default,18,'Thursday',16,4,2,2019),(default,19,'Friday',16,4,2,2019),(default,20,'Saturday',16,4,2,2019),(default,21,'Sunday',16,4,2,2019),(default,22,'Monday',17,4,2,2019),(default,23,'Tuesday',17,4,2,2019),(default,24,'Wednesday',17,4,2,2019),(default,25,'Thursday',17,4,2,2019),(default,26,'Friday',17,4,2,2019),(default,27,'Saturday',17,4,2,2019),(default,28,'Sunday',17,4,2,2019),(default,29,'Monday',18,4,2,2019),(default,30,'Tuesday',18,4,2,2019),(default,1,'Wednesday',18,5,2,2019),(default,2,'Thursday',18,5,2,2019),(default,3,'Friday',18,5,2,2019),(default,4,'Saturday',18,5,2,2019),(default,5,'Sunday',18,5,2,2019),(default,6,'Monday',19,5,2,2019),(default,7,'Tuesday',19,5,2,2019),(default,8,'Wednesday',19,5,2,2019),(default,9,'Thursday',19,5,2,2019),(default,10,'Friday',19,5,2,2019),(default,11,'Saturday',19,5,2,2019),(default,12,'Sunday',19,5,2,2019),(default,13,'Monday',20,5,2,2019),(default,14,'Tuesday',20,5,2,2019),(default,15,'Wednesday',20,5,2,2019),(default,16,'Thursday',20,5,2,2019),(default,17,'Friday',20,5,2,2019),(default,18,'Saturday',20,5,2,2019),(default,19,'Sunday',20,5,2,2019),(default,20,'Monday',21,5,2,2019),(default,21,'Tuesday',21,5,2,2019),(default,22,'Wednesday',21,5,2,2019),(default,23,'Thursday',21,5,2,2019),(default,24,'Friday',21,5,2,2019),(default,25,'Saturday',21,5,2,2019),(default,26,'Sunday',21,5,2,2019),(default,27,'Monday',22,5,2,2019),(default,28,'Tuesday',22,5,2,2019),(default,29,'Wednesday',22,5,2,2019),(default,30,'Thursday',22,5,2,2019),(default,31,'Friday',22,5,2,2019),(default,1,'Saturday',22,6,2,2019),(default,2,'Sunday',22,6,2,2019),(default,3,'Monday',23,6,2,2019),(default,4,'Tuesday',23,6,2,2019),(default,5,'Wednesday',23,6,2,2019),(default,6,'Thursday',23,6,2,2019),(default,7,'Friday',23,6,2,2019),(default,8,'Saturday',23,6,2,2019),(default,9,'Sunday',23,6,2,2019),(default,10,'Monday',24,6,2,2019),(default,11,'Tuesday',24,6,2,2019),(default,12,'Wednesday',24,6,2,2019),(default,13,'Thursday',24,6,2,2019),(default,14,'Friday',24,6,2,2019),(default,15,'Saturday',24,6,2,2019),(default,16,'Sunday',24,6,2,2019),(default,17,'Monday',25,6,2,2019),(default,18,'Tuesday',25,6,2,2019),(default,19,'Wednesday',25,6,2,2019),(default,20,'Thursday',25,6,2,2019),(default,21,'Friday',25,6,2,2019),(default,22,'Saturday',25,6,2,2019),(default,23,'Sunday',25,6,2,2019),(default,24,'Monday',26,6,2,2019),(default,25,'Tuesday',26,6,2,2019),(default,26,'Wednesday',26,6,2,2019),(default,27,'Thursday',26,6,2,2019),(default,28,'Friday',26,6,2,2019),(default,29,'Saturday',26,6,2,2019),(default,30,'Sunday',26,6,2,2019),(default,1,'Monday',27,7,2,2019),(default,2,'Tuesday',27,7,2,2019),(default,3,'Wednesday',27,7,2,2019),(default,4,'Thursday',27,7,2,2019),(default,5,'Friday',27,7,2,2019),(default,6,'Saturday',27,7,2,2019),(default,7,'Sunday',27,7,2,2019),(default,8,'Monday',28,7,2,2019),(default,9,'Tuesday',28,7,2,2019),(default,10,'Wednesday',28,7,2,2019),(default,11,'Thursday',28,7,2,2019),(default,12,'Friday',28,7,2,2019),(default,13,'Saturday',28,7,2,2019),(default,14,'Sunday',28,7,2,2019),(default,15,'Monday',29,7,2,2019),(default,16,'Tuesday',29,7,2,2019),(default,17,'Wednesday',29,7,2,2019),(default,18,'Thursday',29,7,2,2019),(default,19,'Friday',29,7,2,2019),(default,20,'Saturday',29,7,2,2019),(default,21,'Sunday',29,7,2,2019),(default,22,'Monday',30,7,2,2019),(default,23,'Tuesday',30,7,2,2019),(default,24,'Wednesday',30,7,2,2019),(default,25,'Thursday',30,7,2,2019),(default,26,'Friday',30,7,2,2019),(default,27,'Saturday',30,7,2,2019),(default,28,'Sunday',30,7,2,2019),(default,29,'Monday',31,7,2,2019),(default,30,'Tuesday',31,7,2,2019),(default,31,'Wednesday',31,7,2,2019),(default,1,'Thursday',31,8,3,2019),(default,2,'Friday',31,8,3,2019),(default,3,'Saturday',31,8,3,2019),(default,4,'Sunday',31,8,3,2019),(default,5,'Monday',32,8,3,2019),(default,6,'Tuesday',32,8,3,2019),(default,7,'Wednesday',32,8,3,2019),(default,8,'Thursday',32,8,3,2019),(default,9,'Friday',32,8,3,2019),(default,10,'Saturday',32,8,3,2019),(default,11,'Sunday',32,8,3,2019),(default,12,'Monday',33,8,3,2019),(default,13,'Tuesday',33,8,3,2019),(default,14,'Wednesday',33,8,3,2019),(default,15,'Thursday',33,8,3,2019),(default,16,'Friday',33,8,3,2019),(default,17,'Saturday',33,8,3,2019),(default,18,'Sunday',33,8,3,2019),(default,19,'Monday',34,8,3,2019),(default,20,'Tuesday',34,8,3,2019),(default,21,'Wednesday',34,8,3,2019),(default,22,'Thursday',34,8,3,2019),(default,23,'Friday',34,8,3,2019),(default,24,'Saturday',34,8,3,2019),(default,25,'Sunday',34,8,3,2019),(default,26,'Monday',35,8,3,2019),(default,27,'Tuesday',35,8,3,2019),(default,28,'Wednesday',35,8,3,2019),(default,29,'Thursday',35,8,3,2019),(default,30,'Friday',35,8,3,2019),(default,31,'Saturday',35,8,3,2019),(default,1,'Sunday',35,9,3,2019),(default,2,'Monday',36,9,3,2019),(default,3,'Tuesday',36,9,3,2019),(default,4,'Wednesday',36,9,3,2019),(default,5,'Thursday',36,9,3,2019),(default,6,'Friday',36,9,3,2019),(default,7,'Saturday',36,9,3,2019),(default,8,'Sunday',36,9,3,2019),(default,9,'Monday',37,9,3,2019),(default,10,'Tuesday',37,9,3,2019),(default,11,'Wednesday',37,9,3,2019),(default,12,'Thursday',37,9,3,2019),(default,13,'Friday',37,9,3,2019),(default,14,'Saturday',37,9,3,2019),(default,15,'Sunday',37,9,3,2019),(default,16,'Monday',38,9,3,2019),(default,17,'Tuesday',38,9,3,2019),(default,18,'Wednesday',38,9,3,2019),(default,19,'Thursday',38,9,3,2019),(default,20,'Friday',38,9,3,2019),(default,21,'Saturday',38,9,3,2019),(default,22,'Sunday',38,9,3,2019),(default,23,'Monday',39,9,3,2019),(default,24,'Tuesday',39,9,3,2019),(default,25,'Wednesday',39,9,3,2019),(default,26,'Thursday',39,9,3,2019),(default,27,'Friday',39,9,3,2019),(default,28,'Saturday',39,9,3,2019),(default,29,'Sunday',39,9,3,2019),(default,30,'Monday',40,9,3,2019),(default,1,'Tuesday',40,10,3,2019),(default,2,'Wednesday',40,10,3,2019),(default,3,'Thursday',40,10,3,2019),(default,4,'Friday',40,10,3,2019),(default,5,'Saturday',40,10,3,2019),(default,6,'Sunday',40,10,3,2019),(default,7,'Monday',41,10,3,2019),(default,8,'Tuesday',41,10,3,2019),(default,9,'Wednesday',41,10,3,2019),(default,10,'Thursday',41,10,3,2019),(default,11,'Friday',41,10,3,2019),(default,12,'Saturday',41,10,3,2019),(default,13,'Sunday',41,10,3,2019),(default,14,'Monday',42,10,3,2019),(default,15,'Tuesday',42,10,3,2019),(default,16,'Wednesday',42,10,3,2019),(default,17,'Thursday',42,10,3,2019),(default,18,'Friday',42,10,3,2019),(default,19,'Saturday',42,10,3,2019),(default,20,'Sunday',42,10,3,2019),(default,21,'Monday',43,10,3,2019),(default,22,'Tuesday',43,10,3,2019),(default,23,'Wednesday',43,10,3,2019),(default,24,'Thursday',43,10,3,2019),(default,25,'Friday',43,10,3,2019),(default,26,'Saturday',43,10,3,2019),(default,27,'Sunday',43,10,3,2019),(default,28,'Monday',44,10,3,2019),(default,29,'Tuesday',44,10,3,2019),(default,30,'Wednesday',44,10,3,2019),(default,31,'Thursday',44,10,3,2019),(default,1,'Friday',44,11,3,2019),(default,2,'Saturday',44,11,3,2019),(default,3,'Sunday',44,11,3,2019),(default,4,'Monday',45,11,3,2019),(default,5,'Tuesday',45,11,3,2019),(default,6,'Wednesday',45,11,3,2019),(default,7,'Thursday',45,11,3,2019),(default,8,'Friday',45,11,3,2019),(default,9,'Saturday',45,11,3,2019),(default,10,'Sunday',45,11,3,2019),(default,11,'Monday',46,11,3,2019),(default,12,'Tuesday',46,11,3,2019),(default,13,'Wednesday',46,11,3,2019),(default,14,'Thursday',46,11,3,2019),(default,15,'Friday',46,11,3,2019),(default,16,'Saturday',46,11,3,2019),(default,17,'Sunday',46,11,3,2019),(default,18,'Monday',47,11,3,2019),(default,19,'Tuesday',47,11,3,2019),(default,20,'Wednesday',47,11,3,2019),(default,21,'Thursday',47,11,3,2019),(default,22,'Friday',47,11,3,2019),(default,23,'Saturday',47,11,3,2019),(default,24,'Sunday',47,11,3,2019),(default,25,'Monday',48,11,3,2019),(default,26,'Tuesday',48,11,3,2019),(default,27,'Wednesday',48,11,3,2019),(default,28,'Thursday',48,11,3,2019),(default,29,'Friday',48,11,3,2019),(default,30,'Saturday',48,11,3,2019),(default,1,'Sunday',48,12,4,2019),(default,2,'Monday',49,12,4,2019),(default,3,'Tuesday',49,12,4,2019),(default,4,'Wednesday',49,12,4,2019),(default,5,'Thursday',49,12,4,2019),(default,6,'Friday',49,12,4,2019),(default,7,'Saturday',49,12,4,2019),(default,8,'Sunday',49,12,4,2019),(default,9,'Monday',50,12,4,2019),(default,10,'Tuesday',50,12,4,2019),(default,11,'Wednesday',50,12,4,2019),(default,12,'Thursday',50,12,4,2019),(default,13,'Friday',50,12,4,2019),(default,14,'Saturday',50,12,4,2019),(default,15,'Sunday',50,12,4,2019),(default,16,'Monday',51,12,4,2019),(default,17,'Tuesday',51,12,4,2019),(default,18,'Wednesday',51,12,4,2019),(default,19,'Thursday',51,12,4,2019),(default,20,'Friday',51,12,4,2019),(default,21,'Saturday',51,12,4,2019),(default,22,'Sunday',51,12,4,2019),(default,23,'Monday',52,12,4,2019),(default,24,'Tuesday',52,12,4,2019),(default,25,'Wednesday',52,12,4,2019),(default,26,'Thursday',52,12,4,2019),(default,27,'Friday',52,12,4,2019),(default,28,'Saturday',52,12,4,2019),(default,29,'Sunday',52,12,4,2019),(default,30,'Monday',01,12,4,2019),(default,31,'Tuesday',01,12,4,2019);
select insertUtilizadores();
select insertLocais();
select insertAnomalias();

/* ------------------------------------------------------------------ */
/*                           DATA ANALYTICS                           */
/* ------------------------------------------------------------------ */

select tipo_anomalia, dia_da_semana, lingua, total_anomalias
from (
    /* 1- TIPO_ANOMALIA, DIA_DA_SEMANA, LINGUA */
    (select tipo_anomalia, dia_da_semana, lingua, count(*) as total_anomalias
    from f_anomalia natural join
        d_tempo natural join d_lingua
    group by tipo_anomalia, dia_da_semana, lingua
    order by tipo_anomalia, dia_da_semana, lingua)
    union all
    /* 2- TIPO_ANOMALIA, DIA_DA_SEMANA, lingua */
    (select tipo_anomalia, dia_da_semana, null, count(*) as total_anomalias
    from f_anomalia natural join
        d_tempo
    group by tipo_anomalia, dia_da_semana
    order by tipo_anomalia, dia_da_semana)
    union all
    /* 3- tipo_anomalia, DIA_DA_SEMANA, LINGUA */
    (select null, dia_da_semana, lingua, count(*) as total_anomalias
    from f_anomalia natural join
        d_tempo natural join d_lingua
    group by lingua, dia_da_semana
    order by dia_da_semana, lingua)
    union all
    /* 4- TIPO_ANOMALIA, dia_da_semana, LINGUA */
    (select tipo_anomalia, null, lingua, count(*) as total_anomalias
    from f_anomalia natural join
        d_lingua
    group by tipo_anomalia, lingua
    order by tipo_anomalia, lingua)
    union all
    /* 5- TIPO_ANOMALIA, dia_da_semana, lingua */
    (select tipo_anomalia, null, null, count(*) as total_anomalias
    from f_anomalia
    group by tipo_anomalia
    order by tipo_anomalia)
    union all
    /* 6- tipo_anomalia, DIA_DA_SEMANA, lingua */
    (select null, dia_da_semana, null, count(*) as total_anomalias
    from f_anomalia natural join
        d_tempo
    group by dia_da_semana
    order by dia_da_semana)
    union all
    /* 7- tipo_anomalia, dia_da_semana, LINGUA */
    (select null, null, lingua, count(*) as total_anomalias
    from f_anomalia natural join
        d_lingua
    group by lingua
    order by lingua)
    union all
    /* 8- tipo_anomalia, dia_da_semana, lingua */
    (select null, null, null, count(*) as total_anomalias
    from f_anomalia)
) as R;